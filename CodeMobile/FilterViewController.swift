//
//  FilterViewController.swift
//  CodeMobile
//
//  Created by Louis Woods on 08/02/2017.
//  Copyright © 2017 Footsqueek. All rights reserved.
//

import UIKit
import CoreData

class FilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    private let coreData = CoreDataHandler()
    private var filterItems = [Int]()
    private var lastChecked = UITableViewCell()
    private var tags: [NSManagedObject] = []
    private let sortedSections = ["Days", "Tags"]
    private var sortedTags = [String:[TagData]]()
    private var completedTags = [String]()
    
    @IBOutlet weak var filterTableView: UITableView!
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filterTableView.tableFooterView = UIView()
        filterTableView.tableFooterView?.backgroundColor = UIColor.groupTableViewBackground
        recieveCoreData()
    }
    
    // MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if sortedTags.isEmpty == false {
            return sortedTags[sortedSections[section]]!.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tableSection = sortedTags[sortedSections[indexPath.section]]
        let tableItem = tableSection![indexPath.row]
        let cell = self.filterTableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath) as! FilterCell
        cell.filterTitleLabel.text = tableItem.tagTitle
        cell.selectionStyle = .none
        cell.backgroundColor = Colours.codeMobileGrey
        
        if TagsStruct.date == "2019-04-02" && cell.filterTitleLabel.text == "Tuesday 2nd April" {
            lastChecked.accessoryType = .none
            cell.accessoryType = .checkmark
            lastChecked = cell
        } else if TagsStruct.date == "2019-04-03" && cell.filterTitleLabel.text == "Wednesday 3rd April" {
            lastChecked.accessoryType = .none
            cell.accessoryType = .checkmark
            lastChecked = cell
        } else if TagsStruct.date == "2019-04-04" && cell.filterTitleLabel.text == "Thursday 4th April" {
            lastChecked.accessoryType = .none
            cell.accessoryType = .checkmark
            lastChecked = cell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return sortedSections[section]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let index = self.filterTableView.indexPathForSelectedRow! as NSIndexPath
        let tableSection = sortedTags[sortedSections[index.section]]
        let tableItem = tableSection![index.row]
        // Days Section
        if indexPath.section == 0 {
            
            if let cell = filterTableView.cellForRow(at: indexPath) {
                
                if cell.accessoryType == .none {
                    
                    cell.accessoryType = .checkmark
                    lastChecked.accessoryType = .none
                    lastChecked = cell
                    
                    switch (tableItem.tagTitle){
                    case "Tuesday 2nd April" :  TagsStruct.date = "2019-04-02"
                    case "Wednesday 3rd April" :  TagsStruct.date = "2019-04-03"
                    case "Thursday 4th April" :  TagsStruct.date = "2019-04-04"
                    default : TagsStruct.date = "2019-04-02"
                    }
                     NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateTags"), object: nil)
                    //self.revealViewController().frontViewController.loadView()
                    
                }
            }
        }
        // Tags Section
        if indexPath.section == 1 {
            if let cell = filterTableView.cellForRow(at: indexPath) {
                
               if cell.accessoryType == .none {
                    cell.accessoryType = .checkmark
                    filterItems.append(tableItem.tagId)
                    TagsStruct.tagsArray = filterItems
                    TagsStruct.userIsFiltering = true
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateTags"), object: nil)
                    //self.revealViewController().frontViewController.loadView()
                    if tableItem.tagTitle == "Favourites" {
                        TagsStruct.userIsFilteringByFavourites = true
                    }
                }
                else {
                    cell.accessoryType = .none
                    filterItems = filterItems.filter() {$0 != tableItem.tagId}
                    TagsStruct.tagsArray = filterItems
                    TagsStruct.userIsFiltering = true
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateTags"), object: nil)
                    //self.revealViewController().frontViewController.loadView()
                    if tableItem.tagTitle == "Favourites" {
                        TagsStruct.userIsFilteringByFavourites = false
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        let cell = filterTableView.cellForRow(at: indexPath)
        cell?.backgroundColor = Colours.codeMobileGrey
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        view.tintColor = Colours.darkerCodeMobileGrey
        self.filterTableView.separatorColor = Colours.darkerCodeMobileGrey
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let nav = segue.destination as! UINavigationController
        
        let vc = nav.viewControllers[0] as! ScheduleViewController
        
        vc.filterItems = filterItems
        vc.userIsFiltering = true
        vc.scheduleTableView.reloadData()
        
    }
    
    // MARK: - Core Data
    private func recieveCoreData() {
        
        tags = coreData.recieveCoreData(entityNamed: Entities.TAGS)
        sortTags()
    }
    
    private func sortTags() {
        
        sortedTags["Days"] = [TagData(tagId: 0, tagTitle: "Tuesday 2nd April")]
        sortedTags["Days"]?.append(TagData(tagId: 0, tagTitle: "Wednesday 3rd April"))
        sortedTags["Days"]?.append(TagData(tagId: 0, tagTitle: "Thursday 4th April"))
        for item in tags {
            
            if self.sortedTags.index(forKey:"Tags") == nil {
                sortedTags["Tags"] = [TagData(tagId: item.value(forKey: "tagId") as! Int, tagTitle: item.value(forKey: "tag") as! String)]
                completedTags.append(item.value(forKey: "tag") as! String)
            } else {
                if completedTags.contains(item.value(forKey: "tag") as! String) == false {
                    sortedTags["Tags"]?.append(TagData(tagId: item.value(forKey: "tagId") as! Int, tagTitle: item.value(forKey: "tag") as! String))
                    completedTags.append(item.value(forKey: "tag") as! String)
                }
            }
        }
        
        //sortedTags["Tags"]?.append(TagData(tagId: 100, tagTitle:"Favourites"))
        filterTableView.reloadData()
        completedTags = completedTags.sorted {$0 < $1}
       
   
    }
    
   }


// MARK: - Filter TableViewCell Controller
class FilterCell : UITableViewCell {
    
    @IBOutlet weak var filterTitleLabel: UILabel!
}

// MARK: - Tag Data Model
struct TagData {
    
    var tagId = Int()
    var tagTitle = String()
}

// MARK: - Filtering Model
struct TagsStruct {
    
    static var userIsFiltering = false
    static var userIsFilteringByFavourites = false
    static var tagsArray = [Int]()
    static var date = "2019-04-02"
}
