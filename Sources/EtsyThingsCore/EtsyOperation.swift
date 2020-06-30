//
//  EtsyOperation.swift
//  EtsyThingsBridge
//
//  Created by Emory Dunn on 09 December, 2018.
//

import Foundation
import MapKit

/// From https://agostini.tech/2017/07/30/understanding-operation-and-operationqueue-in-swift/
public class EtsyOperation: Operation {
    
    private var _executing = false {
        willSet {
            willChangeValue(forKey: "isExecuting")
        }
        didSet {
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    public override var isExecuting: Bool {
        return _executing
    }
    
    private var _finished = false {
        willSet {
            willChangeValue(forKey: "isFinished")
        }
        
        didSet {
            didChangeValue(forKey: "isFinished")
        }
    }
    
    public override var isFinished: Bool {
        return _finished
    }
    
    func executing(_ executing: Bool) {
        _executing = executing
    }
    
    func finish(_ finished: Bool) {
        _finished = finished
    }
    
}

class TransactionDownloadOperation: EtsyOperation {
    let etsy: EtsyAuth
    let order: Order
    
    init(etsy: EtsyAuth, order: Order) {
        self.etsy = etsy
        self.order = order
    }
    
    override func main() {
        guard isCancelled == false else {
            finish(true)
            return
        }
        executing(true)

        etsy.fetchTransactions(for: order) { result in
            
            switch result {
            case .success(_):
                break
            case .failure(let error):
                print(error.localizedDescription)
            }
            self.executing(false)
            self.finish(true)
        }
        
    }
}

class MapSearchOperation: EtsyOperation {
    let order: Order
    
    init(order: Order) {
        self.order = order
         
    }
    
    func makeSearch() -> MKLocalSearch {
        let addressComponents = order.formattedAddress.components(separatedBy: "\n").dropFirst()
        let address = addressComponents.joined(separator: "\n")
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = address
        return MKLocalSearch(request: request)
    }
    
    override func main() {
        guard isCancelled == false else {
            finish(true)
            return
        }
        executing(true)
        
        let search = makeSearch()
    
        search.start { (response, error) in
            print("Search for order \(self.order.receiptId) has finished")
            if let e = error {
                print(e)
            } else if let response = response {
                NotificationCenter.default.post(name: .mapSearch, object: response.mapItems.first)
            }
            
            sleep(1)
            self.executing(false)
            self.finish(true)
            
        }
//        print("Searching map for order \(self.order.receiptId)")

    }
}
