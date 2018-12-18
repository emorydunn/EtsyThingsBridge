//
//  OrdersObject.swift
//  EtsyThingsBridge
//
//  Created by Emory Dunn on 09 December, 2018.
//

import Foundation

struct OrdersDecoder: Decodable, CustomStringConvertible {
    let count: Int
    let results: [Order]
    
    var description: String {
        return "Orders count \(count)"
    }
}

public class Order: Codable, CustomStringConvertible {
    public let name: String
    public let receiptId: Int
    public let messageFromBuyer: String?
    public let shippedDate: TimeInterval
    
    public var transactions: [Transaction] = []
    
    public var description: String {
        return "Order \(receiptId)"
    }
    
    enum CodingKeys: String, CodingKey {
        case name, receiptId, messageFromBuyer, shippedDate
    }
}

struct TransactionDecoder: Decodable, CustomStringConvertible {
    let count: Int
    let results: [Transaction]
    
    var description: String {
        return "Transaction count \(count)"
    }
}

public struct Transaction: Codable {
    public let title: String
    public let receiptId: Int
    public let transactionId: Int
    public let variations: [ListingVariation]
    public let quantity: Int
}

public struct ListingVariation: Codable {
    public let formattedName: String
    public let formattedValue: String
}
