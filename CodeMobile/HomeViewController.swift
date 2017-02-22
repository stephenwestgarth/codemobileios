//
//  HomeViewController.swift
//  CodeMobile
//
//  Created by Louis Woods on 20/01/2017.
//  Copyright © 2017 Footsqueek. All rights reserved.
//

import UIKit
import CoreData
import TwitterKit

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Properties
    
    private let api = ApiHandler()
    private let coreData = CoreDataHandler()
    private var sessions: [NSManagedObject] = []
    private var speakers: [NSManagedObject] = []
    
    @IBOutlet weak var tweetsCollectionView: UICollectionView!
    @IBOutlet weak var scheduleCollectionView: UICollectionView!
    @IBOutlet weak var bannerBackground: UIView!
    @IBOutlet weak var scheduleSpinner: UIActivityIndicatorView!
    @IBOutlet weak var twitterSpinner: UIActivityIndicatorView!
    
    // MARK: - View Controller Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        
        scheduleCollectionView.reloadData()
        tweetsCollectionView.reloadData()
    }
    
    override func viewDidLoad() {
        
        setupUI()
        // User cannot switch tabs until data has been retrieved
        self.tabBarController?.tabBar.isUserInteractionEnabled = false
        setupAndRecieveCoreData()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        if UIDevice.current.orientation.isLandscape { print("Landscape") } else { print("Portrait") }
    }
    
    // MARK: - CollectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return sessions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == scheduleCollectionView { // Schedule Collection View
            
            let item = sessions[indexPath.row]
            let cell = scheduleCollectionView.dequeueReusableCell(withReuseIdentifier: "CurrentlyOn", for: indexPath) as! SessionCollectionCell
            cell.sessionTitleLbl.text = item.value(forKey: "SessionTitle") as! String?
            cell.speakerImageView.setRadius(radius: 20.0)
            let startTime = Date().formatDate(dateToFormat: item.value(forKey: "SessionStartDateTime")! as! String)
            let endTime = Date().formatDate(dateToFormat: item.value(forKey: "SessionEndDateTime")! as! String)
            
            if Date().isBetweeen(date: startTime, andDate: endTime) {
                //Session is on
                cell.liveInWhichBuildingLbl.text = "On Now - \(item.value(forKey: "sessionLocationName")! as! String)"
                cell.liveInWhichBuildingLbl.textColor = UIColor.red
            } else {
                //Session is off
                cell.liveInWhichBuildingLbl.textColor = UIColor.blue
                cell.liveInWhichBuildingLbl.text = Date().wordedDate(Date: startTime)
            }
            
            for speaker in speakers {
                
                if speaker.value(forKey: "speakerId") as! Int == item.value(forKey: "speakerId") as! Int{
                    let firstName = speaker.value(forKey: "firstname") as! String
                    let lastName = speaker.value(forKey: "surname") as! String
                    cell.speakerNameLbl.text = firstName + " " + lastName
                    let url = URL(string: speaker.value(forKey: "photoURL") as! String)
                    cell.speakerImageView.kf.setImage(with: url)
                }
            }
            return cell
        } else { // Tweets Collection View
            
            let cell = tweetsCollectionView.dequeueReusableCell(withReuseIdentifier: "TweetCell", for: indexPath) as! TweetCollectionCell
            cell.setRadius(radius: 5.0)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == tweetsCollectionView {
            return CGSize(width: 320 , height: 60)
        }
        return CGSize(width: 170 , height: scheduleCollectionView.frame.size.height)
    }
    
    // MARK: - Core Data
    
    private func setupAndRecieveCoreData() {
        
        // SPEAKERS
        // Recieve speaker data from core data
        speakers = coreData.recieveCoreData(entityNamed: Entities.SPEAKERS)
        // Check if data contains data, if not retrieve data from the API then store the data into speaker array.
        if speakers.isEmpty{
            print("Speakers core data is empty, storing speakers data...")
            api.storeSpeakers(updateData: { () -> Void in
                // When data has been successfully stored
                self.speakers = self.coreData.recieveCoreData(entityNamed: Entities.SPEAKERS)
                self.scheduleCollectionView.reloadData()
                self.tweetsCollectionView.reloadData()
            })
        } else {print("Speakers core data is not empty")}
        // Repeat for other tables
        
        // SESSIONS
        sessions = coreData.recieveCoreData(entityNamed: Entities.SCHEDULE)
        scheduleSpinner.startAnimating()
        twitterSpinner.startAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        if sessions.isEmpty{
            print("Schedule core data is empty, storing schedule data...")
            api.storeSchedule(updateData: { () -> Void in
                self.sessions = self.coreData.recieveCoreData(entityNamed: Entities.SCHEDULE)
                for (i,num) in self.sessions.enumerated().reversed() {
                    // Remove past sessions
                    let endTime = Date().formatDate(dateToFormat: num.value(forKey: "SessionEndDateTime")! as! String)
                    if endTime < Date() {
                        self.sessions.remove(at: i)
                    }// Remove breaks
                    else if num.value(forKey: "SessionTitle") as! String == "Break"{
                        self.sessions.remove(at: i)
                    }
                }
                self.scheduleCollectionView.reloadData()
                self.tweetsCollectionView.reloadData()
                self.scheduleSpinner.stopAnimating()
                self.twitterSpinner.stopAnimating()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.tabBarController?.tabBar.isUserInteractionEnabled = true
                
            })
        } else {
            print("Schedule core data is not empty")
            
            for (i,num) in self.sessions.enumerated().reversed() {
                // Remove past sessions
                let endTime = Date().formatDate(dateToFormat: num.value(forKey: "SessionEndDateTime")! as! String)
                if endTime < Date() {
                    self.sessions.remove(at: i)
                }// Remove breaks
                else if num.value(forKey: "SessionTitle") as! String == "Break"{
                    self.sessions.remove(at: i)
                }
            }
            self.scheduleSpinner.stopAnimating()
            self.twitterSpinner.stopAnimating()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.tabBarController?.tabBar.isUserInteractionEnabled = true
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func seeAllTweets(_ sender: Any) {
        
        showTimeline()
    }
    @IBAction func seeFullSchedule(_ sender: Any) {
        
        tabBarController?.selectedIndex = 1
    }
    
    // MARK: - Twitter
    
    private func showTimeline() {
        
        // Create an API client and data source to fetch Tweets for the timeline
        let client = TWTRAPIClient()
        // Replace with your collection id or a different data source
        let dataSource = TWTRUserTimelineDataSource(screenName: "Codemobileuk", apiClient: client)
        // Create the timeline view controller
        let timelineViewControlller = TWTRTimelineViewController(dataSource: dataSource)
        // Create done button to dismiss the view controller
        let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissTimeline))
        timelineViewControlller.navigationItem.leftBarButtonItem = button
        // Create a navigation controller to hold the
        let navigationController = UINavigationController(rootViewController: timelineViewControlller)
        
        showDetailViewController(navigationController, sender: self)
    }
    
    @objc private func dismissTimeline() {
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UI
    
    private func setupUI() {
        
        scheduleSpinner.hidesWhenStopped = true
        twitterSpinner.hidesWhenStopped = true
    }
}

// MARK: - Schedule CollectionViewCell Controller

class SessionCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var speakerImageView: UIImageView!
    @IBOutlet weak var liveInWhichBuildingLbl: UILabel!
    @IBOutlet weak var speakerNameLbl: UILabel!
    @IBOutlet weak var sessionTitleLbl: UILabel!
}
// MARK: - Tweet CollectionViewCell Controller

class TweetCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var tweetTextView: UITextView!
    @IBOutlet weak var twitterUserLbl: UILabel!
}
