//
//  FilterViewController.swift
//  CodeMobile
//
//  Created by Louis Woods on 08/02/2017.
//  Copyright © 2017 Footsqueek. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var filterTableView: UITableView!
    
    struct Filters {
        var sectionName : String!
        var sectionFilters : [String]!
    }
    
    var filtersArray = [Filters]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        filtersArray = [Filters(sectionName:"Days", sectionFilters: ["Tuesday 18th April", "Wednesday 19th April", "Thursday 20th April"]),Filters(sectionName:"Tags", sectionFilters: ["iOS", "Android", "Design", "Security", "Other"]),]
       
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return filtersArray.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtersArray[section].sectionFilters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.filterTableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath) as! FilterCell
        cell.filterTitleLabel.text = filtersArray[indexPath.section].sectionFilters[indexPath.row]
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return filtersArray[section].sectionName
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
         if let cell = filterTableView.cellForRow(at: indexPath) {
            
            if cell.accessoryType == .none {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = filterTableView.cellForRow(at: indexPath)
        cell?.backgroundColor = UIColor(red: 51.0/255, green: 51.0/255, blue: 51.0/255, alpha: 1.0)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor(red: 45.0/255, green: 45.0/255, blue: 45.0/255, alpha: 1.0)
        self.filterTableView.separatorColor = UIColor(red: 45.0/255, green: 45.0/255, blue: 45.0/255, alpha: 1.0)
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
    }
    
}

class FilterCell : UITableViewCell {
    
    @IBOutlet weak var filterTitleLabel: UILabel!
}
