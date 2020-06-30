import XCTest
import Foundation
@testable import EtsyThingsCore

final class EtsyThingsBridge2Tests: XCTestCase {
    func testExample() {
        
        let keys = AuthKeys(
            storeName: "",
            consumerKey: "",
            consumerSecret: "",
            token: "",
            tokenSecret: ""
        )
        
        let orderExpectation = expectation(description: "Orders")
        let etsy = EtsyAuth(keys: keys)
    
        etsy.fetchOpenOrders { response in
            switch response {
            case .success(let orders):
                print("Received \(orders.count) orders")

                do {
                    try EtsyThingsBridge.makeProjects(for: orders.results, in: "Etsy")
                } catch {
                    print(error.localizedDescription)
                }
                

                orderExpectation.fulfill()
            case .failure(let e):
                print(e)
                orderExpectation.fulfill()
            }
            
        }
        
        wait(for: [orderExpectation], timeout: 30)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
