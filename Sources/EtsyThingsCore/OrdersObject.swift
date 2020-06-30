//
//  OrdersObject.swift
//  EtsyThingsBridge
//
//  Created by Emory Dunn on 09 December, 2018.
//

import Foundation

public struct OrdersDecoder: Decodable, CustomStringConvertible {
    public let count: Int
    public let results: [Order]
    
    public var description: String {
        return "Orders count \(count)"
    }
}

public class Order: Codable, CustomStringConvertible {
    public let name: String
    public let receiptId: Int
    public let messageFromBuyer: String?
    public let shippedDate: TimeInterval
    
    // Location Support
    public let formattedAddress: String
    public let firstLine: String
    public let secondLine: String?
    public let city: String
    public let state: String
    public let zip: String
    public let countryId: Int
    
    
    public var dueDate: Date {
        return Date(timeIntervalSince1970: shippedDate)
    }
    
    public var transactions: [Transaction] = []
    
    public var description: String {
        return "Order \(receiptId)"
    }
    
    enum CodingKeys: String, CodingKey {
        case name, receiptId, messageFromBuyer
        case formattedAddress, shippedDate, firstLine, secondLine, city, state, zip, countryId
    }
}

struct TransactionDecoder: Decodable, CustomStringConvertible {
    let count: Int
    let results: [Transaction]
    
    var description: String {
        return "Transaction count \(count)"
    }
}

public struct Transaction: Codable, CustomStringConvertible {
    public let title: String
    public let receiptId: Int
    public let transactionId: Int
    public let variations: [ListingVariation]
    public let quantity: Int
    
    public var description: String {
        return "Transaction \(transactionId): \(quantity)x \(title)"
    }
}

public struct ListingVariation: Codable {
    public let formattedName: String
    public let formattedValue: String
}
