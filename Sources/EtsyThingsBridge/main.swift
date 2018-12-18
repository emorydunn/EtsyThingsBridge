//
//  main.swift
//  EtsyThingsBridge
//
//  Created by Emory Dunn on 2018-12-11.
//

import Foundation
import EtsyThingsCore

if #available(OSX 10.12, *) {
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
    
    etsy.fetchOpenOrders { response in
        switch response {
        case .success(let orders):
            print("Received \(orders.count) orders")
            
            do {
                try EtsyThingsBridge.makeProjects(for: orders, in: "Etsy")
            } catch {
                print(error.localizedDescription)
                exit(EXIT_FAILURE)
            }
            
            print("Project creation complete")
            exit(EXIT_SUCCESS)
        case .error(let e):
            print(e)
            
            exit(EXIT_FAILURE)
        }
        
    }
    
    dispatchMain()

    
} else {
    print("EtsyThingsBridge is only available on macOS 10.12 and newer")
    exit(EXIT_FAILURE)
}
