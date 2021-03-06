//
//  CoreDataHandler.swift
//  CodeMobile
//
//  Created by Louis Woods on 19/01/2017.
//  Copyright © 2017 Footsqueek. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

class CoreDataHandler {
    
    private var sessions: [NSManagedObject] = []
    
    // Recieve data from core data & store it into a array of NSManaged Object : Could be improved upon by using NSFetchedResultsViewController
    func recieveCoreData(entityNamed: String) -> [NSManagedObject]{
        
        sessions.removeAll()
        let managedContext = getContext()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityNamed)
        
        // Sort items by _
        if entityNamed == Entities.SCHEDULE{
            let sortorder = NSSortDescriptor(key: "sessionStartDateTime", ascending: true)
            fetchRequest.sortDescriptors=[sortorder]
        }
        if entityNamed == Entities.SPEAKERS{
            let sortorder = NSSortDescriptor(key: "firstname", ascending: true)
            fetchRequest.sortDescriptors=[sortorder]
        }
        
        do {
            
            let searchResults = try managedContext.fetch(fetchRequest)
            print("...Retrieved \(searchResults.count) tables for \(entityNamed) from Core Data!")
            for item in searchResults as [NSManagedObject] {
                // Store each item in entity searched for
                sessions.append(item)
            }
        } catch let error as NSError {
            print("Failed: Could not fetch. \(error), \(error.userInfo)")
        }
        
        return sessions
    }
    
    private func getContext() -> NSManagedObjectContext {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if #available(iOS 10.0, *) {
            return appDelegate.persistentContainer.viewContext
        } else { // Fallback on previous iOS versions
            return appDelegate.managedObjectContext
        }
    }
}



