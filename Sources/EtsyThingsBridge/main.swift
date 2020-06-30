//
//  main.swift
//  EtsyThingsBridge
//
//  Created by Emory Dunn on 2018-12-11.
//

import Foundation
import EtsyThingsCore
import MapKit


let config = Config()

var etsy: EtsyAuth!
do {
    etsy = try config.loadKeys()
} catch {
    print(error.localizedDescription)
    
    do {
        let url = try config.writeConfig()
        print("Writing empty keys file to \(url.path)")
        
    } catch {
        print(error.localizedDescription)
    }
    
    exit(EXIT_FAILURE)
}

var allOrders: [Order] = []

/// Download all order, repeating as necessary for pages
/// - Parameters:
///   - fetchTransactions: Fetch transactions for each order
///   - limit: Paging limit
///   - offset: Paging offset
func downloadOrders(fetchTransactions: Bool = true, limit: Int? = nil, offset: Int? = nil) {
    
    etsy.fetchOpenOrders(fetchTransactions: false, limit: limit, offset: offset) { response in
        switch response {
        case .success(let orders):
            
            allOrders.append(contentsOf: orders.results)
            
            print("Received \(allOrders.count) orders of \(orders.count)")
            
            
            
            if allOrders.count < orders.count {
                let newOffset: Int?
                if let limit = limit, let offset = offset {
                    newOffset = limit + offset
                } else {
                    newOffset = nil
                }
                downloadOrders(fetchTransactions: fetchTransactions, limit: limit, offset: newOffset)
            } else {
                print("All orders downloaded: \(allOrders.count)")
                
                do {
                    try saveOrders()
                    openInMaps()
                } catch {
                    print(error)
                }

            }
            
            
        
        case .failure(let e):
            print(e)
            
            exit(EXIT_FAILURE)
        }
        
    }
}

func openInMaps() {
    etsy.fetchMapLocations(for: allOrders) { items in
        print("Opening \(items.count) in Maps")
        MKMapItem.openMaps(with: items, launchOptions: nil)
        exit(EXIT_SUCCESS)
    }
}

func saveOrders() throws {
    let encoder = JSONEncoder()
    let data = try encoder.encode(allOrders)
    
    try data.write(to: URL(fileURLWithPath: "/Users/emorydunn/Desktop/Orders.json"))
}

func loadOrders() throws {
    let decoder = JSONDecoder()
    let data = try Data(contentsOf: URL(fileURLWithPath: "/Users/emorydunn/Desktop/Orders.json"))
    allOrders = try decoder.decode([Order].self, from: data)
}


//downloadOrders(fetchTransactions: false, limit: 100, offset: 0)

do {
    try loadOrders()
    openInMaps()
} catch {
    print(error)
}







dispatchMain()
