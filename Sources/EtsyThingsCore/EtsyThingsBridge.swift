import Foundation
import Cocoa
import ScriptingBridge

enum AppleScriptError: Error, LocalizedError {
    case runtimeError(NSDictionary)
    case invalidReturnType(NSAppleEventDescriptor?, expected: String)
    
    var errorDescription: String? {
        switch self {
        case .runtimeError(let error):
            return (error["NSAppleScriptErrorMessage"] as! String)
        case .invalidReturnType(let result, expected: let type):
            return "Expected \(type), received \(String(describing: result))"
        }
    }
}

public class EtsyThingsBridge {
    
    static let subroutines = """
    on projectExists(projectId)
        tell application "Things3"
            set p to projects whose notes contains projectId
            log "found " & (count of p)
            return (count of p) is not 0
        end tell
    end projectExists

    on toDoExists(toDoId)
        tell application "Things3"
            set p to to dos whose notes contains toDoId
            log "found " & (count of p)
            return (count of p) is not 0
        end tell
    end toDoExists

    on makeProject(projectName, areaName, projectNotes)
        log "Making project with id " & projectName
        if projectExists(projectNotes) then return
        
        tell application "Things3"
            set theArea to first area whose name is areaName
            make new project with properties {name:projectName, area:theArea, notes:projectNotes}
        end tell
        
        return true
    end makeProject

    on makeToDo(projectId, toDoName, ToDoNotes)
        log "Making to do with id " & toDoName
        if toDoExists(ToDoNotes) then return
        
        tell application "Things3"
            set theProject to first project whose notes contains projectId
            
            make new to do with properties {name:toDoName, notes:ToDoNotes, project:theProject}
        end tell
        
        
    end makeToDo

    """
    
    public static func makeProjects(for orders: [Order], in area: String) throws {
        
        try orders.forEach { order in
            try EtsyThingsBridge.makeProject(for: order, in: area)
            
            try order.transactions.forEach{ transaction in
                try EtsyThingsBridge.makeToDo(for: transaction)
            }

        }

    }

    public static func makeProject(for order: Order, in area: String) throws {
        print("Making project for \(order.name)")
        let scriptSource = EtsyThingsBridge.subroutines.appending(
            """
            makeProject("\(order.name)", "\(area)", "\(order.receiptId)")
            """
        )

        let script = NSAppleScript(source: scriptSource)

        var error: NSDictionary?
        let _ = script?.executeAndReturnError(&error)
        
        if error != nil {
            throw AppleScriptError.runtimeError(error!)
        }

    }

    
    public static func makeToDo(for transaction: Transaction) throws {
        
        let variations = transaction.variations.map { variation in
            variation.formattedValue
            }.joined(separator: ", ")
        
        let title = "\(transaction.title), \(variations)"
        
        
        
        let scriptSource = EtsyThingsBridge.subroutines.appending(
            """
            makeToDo("\(transaction.receiptId)", "\(title)", "\(transaction.transactionId)")
            """
        )
        
        for _ in 1...transaction.quantity {
            print("Making to do for \(title)")
            let script = NSAppleScript(source: scriptSource)
            
            var error: NSDictionary?
            let _ = script?.executeAndReturnError(&error)
            
            if error != nil {
                throw AppleScriptError.runtimeError(error!)
            }
        }

    }
    
    
}
