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

    on makeProject(projectName, areaName, projectNotes, deadline)
        log "Making project with id " & projectName
        if projectExists(projectNotes) then return false
        
        tell application "Things3"
            set theArea to first area whose name is areaName
            make new project with properties {name:projectName, area:theArea, notes:projectNotes, due date:deadline}
        end tell
        
        return true
    end makeProject

    on makeToDo(projectId, toDoName, ToDoNotes)
        log "Making to do with id " & toDoName
        if toDoExists(ToDoNotes) then return false
        
        tell application "Things3"
            set theProject to first project whose notes contains projectId
            
            make new to do with properties {name:toDoName, notes:ToDoNotes, project:theProject}
        end tell
        
        return true
        
    end makeToDo

    """
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        return formatter
    }()
    
    public static func makeProjects(for orders: [Order], in area: String) throws {
        
        try orders.forEach { order in
            try EtsyThingsBridge.makeProject(for: order, in: area)
            
            try order.transactions.forEach{ transaction in
                try EtsyThingsBridge.makeToDo(for: transaction)
            }

        }

    }

    public static func makeProject(for order: Order, in area: String) throws {
        
        let dateString = dateFormatter.string(from: order.dueDate)
        let scriptSource = EtsyThingsBridge.subroutines.appending(
            """
            makeProject("\(order.name)", "\(area)", "\(order.receiptId)", date "\(dateString)")
            """
        )
        

        let script = NSAppleScript(source: scriptSource)

        var error: NSDictionary?
        let result = script?.executeAndReturnError(&error)
        
        if error != nil {
            throw AppleScriptError.runtimeError(error!)
        }
        if result?.booleanValue ?? false {
            print("Made project for \(order.name)")
        }
        

    }

    
    public static func makeToDo(for transaction: Transaction) throws {
        NSLog("Making to do for \(transaction)")
        let variations = transaction.variations.map { variation in
            variation.formattedValue
            }.joined(separator: ", ")
        
        let title = "\(transaction.title), \(variations)"
        
        
        for index in 1...transaction.quantity {
            let scriptSource = EtsyThingsBridge.subroutines.appending(
                """
                makeToDo("\(transaction.receiptId)", "\(title)", "\(transaction.transactionId) \(index)")
                """
            )

            let script = NSAppleScript(source: scriptSource)
            
            var error: NSDictionary?
            let result = script?.executeAndReturnError(&error)
            
            if error != nil {
                throw AppleScriptError.runtimeError(error!)
            }
            
            if result?.booleanValue ?? false {
                print("Made to do for \(title)")
            }
        }

    }
    
    
}
