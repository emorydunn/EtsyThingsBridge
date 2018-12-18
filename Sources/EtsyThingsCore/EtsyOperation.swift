//
//  EtsyOperation.swift
//  EtsyThingsBridge
//
//  Created by Emory Dunn on 09 December, 2018.
//

import Foundation

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
            case .error(let error):
                print(error.localizedDescription)
            }
            self.executing(false)
            self.finish(true)
        }
        
    }
}
