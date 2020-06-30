//
//  Etsy.swift
//  EtsyThingsBridge
//
//  Created by Emory Dunn on 09 December, 2018.
//

import Foundation
import OAuthSwift
import MapKit

public typealias OrdersResult = Result<OrdersDecoder, Error>
public typealias OrderTransactionsResult = Result<Order, Error>

extension Notification.Name {
    static let mapSearch = Notification.Name("MapSearch")
}

public struct AuthKeys: Codable {
    public let storeName: String
    public let consumerKey: String
    public let consumerSecret: String
    public let token: String
    public let tokenSecret: String
    
    public init(from url: URL) throws {
        let decoder = JSONDecoder()
        let data = try Data(contentsOf: url)
        
        self = try decoder.decode(AuthKeys.self, from: data)
    }
    
    public init(storeName: String, consumerKey: String, consumerSecret: String, token: String, tokenSecret: String) {
        self.storeName = storeName
        self.consumerKey = consumerKey
        self.consumerSecret = consumerSecret
        self.token = token
        self.tokenSecret = tokenSecret
    }
}

public class EtsyAuth {
    
    let keys: AuthKeys
    let oauth: OAuthSwift
    
    let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return decoder
    }()
    let queue = OperationQueue()
    
    let downloadDispatchQueue = DispatchQueue(label: "DownloadQueue")
    
    public init(keys: AuthKeys) {
        self.keys = keys
        
        self.oauth = OAuth1Swift(
            consumerKey: keys.consumerKey,
            consumerSecret: keys.consumerSecret,
            requestTokenUrl: "https://openapi.etsy.com/v2/oauth/request_token?scope=listings_r",
            authorizeUrl: "https://openapi.etsy.com/v2/oauth/authorize?scope=listings_r",
            accessTokenUrl: "https://openapi.etsy.com/v2/oauth/access_token?scope=listings_r"
        )
        
        oauth.client.credential.oauthToken = keys.token
        oauth.client.credential.oauthTokenSecret = keys.tokenSecret
        
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .background

    }
    
    public func fetchOpenOrders(fetchTransactions: Bool = true, limit: Int? = nil, offset: Int? = nil, _ callback: @escaping (OrdersResult) -> Void) {

        let url = "https://openapi.etsy.com/v2/shops/\(keys.storeName)/receipts"
        var components = URLComponents(string: url)
        components?.queryItems = []
        if let limit = limit {
            components?.queryItems?.append(URLQueryItem(name: "limit", value: "\(limit)"))
        }
        if let offset = offset {
            components?.queryItems?.append(URLQueryItem(name: "offset", value: "\(offset)"))
        }
        
        if components!.queryItems!.isEmpty {
            components?.queryItems = nil
        }
        
        print("Fetching orders at offset \(offset ?? 0)")
        let _ = oauth.client.get(components!.string!,
             success: { response in
                do {
                    let orders = try self.decoder.decode(OrdersDecoder.self, from: response.data)

                    if fetchTransactions {
                        let operations = orders.results.map { TransactionDownloadOperation(etsy: self, order: $0) }
                        self.downloadDispatchQueue.async {
                            self.queue.addOperations(operations, waitUntilFinished: true)
                            
                            callback(.success(orders))
                        }
                    } else {
                        callback(.success(orders))
                    }

                    
                    
                } catch {
                    callback(.failure(error))
                }

            }, failure: { error in
               callback(.failure(error))
            }
        )
        
    }
    
    public func fetchMapLocations(for orders: [Order], _ callback: @escaping ([MKMapItem]) -> Void) {
        print("Preparing to search for \(orders.count) addresses")
        
        var items = [MKMapItem]()
        
        let token = NotificationCenter.default.addObserver(forName: .mapSearch, object: nil, queue: nil) { notification in
            if let item = notification.object as? MKMapItem {
                items.append(item)
            }
            
        }
        
        
        self.downloadDispatchQueue.async {

            let operations = orders.map { MapSearchOperation(order: $0) }
            self.queue.addOperations(operations, waitUntilFinished: true)
            
            NotificationCenter.default.removeObserver(token)
            callback(items)
            
        }
        
        
    }
    
    public func fetchTransactions(for order: Order, _ callback: @escaping (OrderTransactionsResult) -> Void) {
        let url = "https://openapi.etsy.com/v2/receipts/\(order.receiptId)/transactions"
        
        print("Fetching transactions for \(order)")
        let _ = oauth.client.get(url,
             success: { response in

                do {
                    let transactions = try self.decoder.decode(TransactionDecoder.self, from: response.data)
                    order.transactions = transactions.results
                    callback(.success(order))
                } catch {
                    callback(.failure(error))
                }
                                    
            }, failure: { error in
                print("Failure for order \(order.receiptId)")
                callback(.failure(error))
            }
        )
    }
    
}
