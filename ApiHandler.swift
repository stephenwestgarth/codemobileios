//
//  ApiHandler.swift
//  CodeMobile
//
//  Created by Louis Woods on 19/01/2017.
//  Copyright © 2017 Footsqueek. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import CoreData
// TODO: Comment class
class ApiHandler {
    
    var sessions: [NSManagedObject] = []
    
    func storeSchedule(updateData: @escaping () -> Void) {
        
        let managedContext = getContext()
        
        Alamofire.request(Commands.API_URL + Commands.SCHEDULE).responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                
                let swiftyJsonVar = JSON(responseData.result.value!)
                let entity = NSEntityDescription.entity(forEntityName: "Schedule", in: managedContext)!
               
                for item in swiftyJsonVar {
                    
                    let session = NSManagedObject(entity: entity, insertInto: managedContext)
                    session.setValue(item.1["SessionId"].int, forKeyPath: "sessionId")
                    session.setValue(item.1["SessionTitle"].string, forKeyPath: "sessionTitle")
                    session.setValue(item.1["SessionDescription"].string, forKeyPath: "sessionDescription")
                    session.setValue(item.1["SessionStartDateTime"].string, forKeyPath: "sessionStartDateTime")
                    session.setValue(item.1["SessionEndDateTime"].string, forKeyPath: "sessionEndDateTime")
                    session.setValue(item.1["Speaker"]["SpeakerId"].int, forKeyPath: "speakerId")
                    session.setValue(item.1["SessionLocation"]["LocationName"].string, forKeyPath: "sessionLocationName")
                }
                
                do {
                    print("Saved schedule data!")
                    try managedContext.save()
                    updateData()
                } catch let error as NSError {
                    print("Failed: Could not save. \(error), \(error.userInfo)")
                }
            }
        }
    }
    
    func storeSpeakers(updateData: @escaping () -> Void) {
        
        let managedContext = getContext()
        
        Alamofire.request(Commands.API_URL + Commands.SPEAKERS).responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                
                let swiftyJsonVar = JSON(responseData.result.value!)
                let entity = NSEntityDescription.entity(forEntityName: "Speaker", in: managedContext)!
               
                for item in swiftyJsonVar {
                    
                    let speaker = NSManagedObject(entity: entity, insertInto: managedContext)
                    speaker.setValue(item.1["SpeakerId"].int, forKeyPath: "speakerId")
                    speaker.setValue(item.1["Firstname"].string, forKeyPath: "firstname")
                    speaker.setValue(item.1["Surname"].string, forKeyPath: "surname")
                    speaker.setValue(item.1["Twitter"].string, forKeyPath: "twitter")
                    speaker.setValue(item.1["Organisation"].string, forKeyPath: "organisation")
                    speaker.setValue(item.1["Profile"].string, forKeyPath: "profile")
                    speaker.setValue(item.1["PhotoURL"].string, forKeyPath: "photoURL")
                    speaker.setValue(item.1["FullName"].string, forKeyPath: "fullName")
                }
                
                do {
                    try managedContext.save()
                    print("Saved speakers data!")
                    updateData()
                } catch let error as NSError {
                    print("Failed: Could not save. \(error), \(error.userInfo)")
                }
            }
        }
    }
    
    func storeLocations(updateData: @escaping () -> Void) {
        
        let managedContext = getContext()
        
        Alamofire.request(Commands.API_URL + Commands.LOCATIONS).responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                
                let swiftyJsonVar = JSON(responseData.result.value!)
                let entity = NSEntityDescription.entity(forEntityName: "SessionLocation", in: managedContext)!
                let location = NSManagedObject(entity: entity, insertInto: managedContext)
                
                for item in swiftyJsonVar {
                    
                    location.setValue(item.1["LocationName"].string, forKeyPath: "locationName")
                    location.setValue(item.1["Longitude"].double, forKeyPath: "longitude")
                    location.setValue(item.1["Latitude"].double, forKeyPath: "latitude")
                    location.setValue(item.1["Description"].string, forKeyPath: "locationDescription")
                }
                
                do {
                    try managedContext.save()
                    print("Saved location data!")
                    updateData()
                } catch let error as NSError {
                    print("Failed: Could not save. \(error), \(error.userInfo)")
                }
            }
        }
    }
    
    func getContext() -> NSManagedObjectContext {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
}



