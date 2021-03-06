//
//  SpeakersViewController.swift
//  CodeMobile
//
//  Created by Louis Woods on 27/01/2017.
//  Copyright © 2017 Footsqueek. All rights reserved.
//

import UIKit
import CoreData

class SpeakersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISplitViewControllerDelegate  {
    
    // MARK: - Properties
    private let coreData = CoreDataHandler()
    private var sessions: [NSManagedObject] = []
    private var speakers: [NSManagedObject] = []
    
    @IBOutlet weak var speakersTableView: UITableView!
    
    // MARK: - View Controller Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        
        speakersTableView.reloadData()
    }
    
    override func viewDidLoad() {
        
        recieveCoreData()
        setupSplitView()
        speakersTableView.tableFooterView = UIView()
    }
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return speakers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let speaker = speakers[indexPath.row]
        let cell = self.speakersTableView.dequeueReusableCell(withIdentifier: "SpeakerCell", for: indexPath) as! SpeakerCell
        // Name
        let firstName = speaker.value(forKey: "firstname") as! String
        let lastName = speaker.value(forKey: "surname") as! String
        cell.speakerNameLbl.text = firstName + " " + lastName
        // Thumbnail
        cell.thumbnailImageView.setRadius(radius: cell.thumbnailImageView.frame.size.height / 2)
        
        if let photoURL = speaker.value(forKey: "photoURL") as? String {
            let url = URL(string: "\(Commands.SITE_URL)\(photoURL)")
            cell.thumbnailImageView.kf.setImage(with: url)
        } else {
            cell.thumbnailImageView.image = nil
        
        }
        // Session titles
        for session in sessions {
            // Find speakerId in speaker array and collect relevent information to match session
            if session.value(forKey: "speakerId") as! Int == speaker.value(forKey: "speakerId") as! Int{
                
                cell.sessionTitlesLbl.text = session.value(forKey: "SessionTitle") as! String?
            }
        }
        
        cell.sessionTitlesLbl.text = speaker.value(forKey: "organisation") as? String
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.performSegue(withIdentifier: "showSpeakerDetail", sender: self)
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showSpeakerDetail" {
            let index = self.speakersTableView.indexPathForSelectedRow! as NSIndexPath
            let nav = segue.destination as! UINavigationController
            let vc = nav.viewControllers[0] as! DetailViewController
            let speaker = speakers[index.row]
            vc.extendedLayoutIncludesOpaqueBars = true
            let firstName = speaker.value(forKey: "firstname") as! String
            let lastName = speaker.value(forKey: "surname") as! String
            vc.fullname = firstName + " " + lastName
            vc.title = firstName + " " + lastName
            vc.twitterURL = speaker.value(forKey: "twitter") as? String
            
            if let photoURL = speaker.value(forKey: "photoURL") as? String {
                let url = URL(string: "\(Commands.SITE_URL)\(photoURL)")
                vc.speakerImageURL = url
            }
            vc.company = speaker.value(forKey: "organisation") as! String
            vc.profile = speaker.value(forKey: "profile") as! String
            vc.viewIsHidden = false
            var talkArray = [sessionDetail]()
            
            for item in sessions{
                
                if item.value(forKey: "speakerId") as! Int == speaker.value(forKey: "speakerId") as! Int {
                    
                
                    let talkDesc = item.value(forKey: "sessionDescription") as! String
                    let buildingName = item.value(forKey: "sessionLocationName") as! String!
                    let sesTitle = item.value(forKey: "sessionTitle") as! String!
                    vc.profileViewSelected = true
                    
                    let startTime = Date().formatDate(dateToFormat: item.value(forKey: "sessionStartDateTime") as! String!)
                    let timeStart = Date().wordedDate(Date: startTime)
                    talkArray.append(sessionDetail(title: sesTitle!, timeStarted: timeStart, buildingName: buildingName!, talkDescription: talkDesc))
                    
                    
                
                }
            }
            
            vc.talks = talkArray
            
            
            self.speakersTableView.deselectRow(at: index as IndexPath, animated: true)
        }
    }
    
    // MARK: - SplitView
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        
        return true
    }
    
    private func setupSplitView(){
        
        self.splitViewController?.delegate = self
        self.splitViewController?.preferredDisplayMode = UISplitViewControllerDisplayMode.allVisible
    }
    
    // MARK: - Core Data
    private func recieveCoreData() {
        
        speakers = coreData.recieveCoreData(entityNamed: Entities.SPEAKERS)
        sessions = coreData.recieveCoreData(entityNamed: Entities.SCHEDULE)
        // Remove breaks
        for (i,num) in speakers.enumerated().reversed() {
            if num.value(forKey: "firstname") as! String == "Break"{
                speakers.remove(at: i)
            }
        }
    }
}

// MARK: - Speaker TableViewCell Controller
class SpeakerCell: UITableViewCell {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var speakerNameLbl: UILabel!
    @IBOutlet weak var sessionTitlesLbl: UILabel!
}
