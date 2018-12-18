//
//  Config.swift
//  EtsyThingsBridge
//
//  Created by Emory Dunn on 16 December, 2018.
//

import Foundation

@available(OSX 10.12, *)
public struct Config {
    
    public let configFile: URL
    
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    
    public init() {
        // Set up config dir
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        let configDir = homeDir.appendingPathComponent(".config").appendingPathComponent("EtsyThingsBridge")
        
        self.configFile = configDir.appendingPathComponent("keys.json")
    }
    
    public init(config location: URL) {
        self.configFile = location
    }
    
    public func loadKeys() throws -> EtsyAuth {
        let keys = try AuthKeys(from: configFile)
        
        return EtsyAuth(keys: keys)
    }
    
    public func writeConfig() throws -> URL {
        
        do {
            try makeConfigDirectory()
        } catch {
            print(error)
            
        }
        
        let keys = AuthKeys(storeName: "", consumerKey: "", consumerSecret: "", token: "", tokenSecret: "")
        encoder.outputFormatting = .prettyPrinted
        
        let data = try encoder.encode(keys)
        
        try data.write(to: configFile)
        return configFile
    }
    
    func makeConfigDirectory() throws {
        try FileManager.default.createDirectory(at: configFile.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
    }
    
}
