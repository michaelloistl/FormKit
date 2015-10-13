//
//  FormSelectionTableViewController.swift
//  loopd-ios
//
//  Created by Michael Loistl on 27/03/2015.
//  Copyright (c) 2015 Loopd.life. All rights reserved.
//

import Foundation

protocol FormSelectionTableViewControllerDelegate {
    func formSelectionTableViewController(sender: FormSelectionTableViewController, didSelectRealmObjects objects: Array<RLMObject>, withFormTableViewCellIdentifier identifier: String?)
}

class FormSelectionTableViewController: UITableViewController {

    let defaultTableViewCellIdentifier = "defaultTableViewCellIdentifier"
    
    var delegate: FormSelectionTableViewControllerDelegate?
    
    var formTableViewCellIdentifier: String?
    var objectType: RLMObject.Type?
    var valueKeyPath: String?
    var sortDescriptors: Array<RLMSortDescriptor>?
    var realmResults: RLMResults? {
        didSet {
            tableView.reloadData()
        }
    }
    
    lazy var clearBarButtonItem: UIBarButtonItem = {
        let _clearBarButtonItem = UIBarButtonItem(title: "Clear", style: .Plain, target: self, action: Selector("clearBarButtonItemSelected:"))
        
        return _clearBarButtonItem
    }()
    
    // MARK: Override UIViewController Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Select"
        
        navigationItem.rightBarButtonItem = clearBarButtonItem
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: defaultTableViewCellIdentifier)
        
        if let objectType = objectType {
            var realmResults = objectType.allObjects()
            
            if let sortDescriptors = sortDescriptors {
                realmResults = realmResults.sortedResultsUsingDescriptors([sortDescriptors])
            }
            
            self.realmResults = realmResults
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        var selectedObjects = Array<RLMObject>()
        
        if let indexPathsForSelectedRows = tableView.indexPathsForSelectedRows {
            for indexPath in indexPathsForSelectedRows {
                if let realmResults = realmResults {
                    if let realmObject = realmResults[UInt(indexPath.row)] as? RLMObject {
                        selectedObjects.append(realmObject)
                    }
                }
            }
        }
        
        delegate?.formSelectionTableViewController(self, didSelectRealmObjects: selectedObjects, withFormTableViewCellIdentifier: formTableViewCellIdentifier)
    }
    
    // MARK: IBAction Functions
    
    func clearBarButtonItemSelected(sender: UIBarButtonItem) {
        
    }
    
    // MARK: Functions
    
    // MARK: UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let realmResults = realmResults {
            return Int(realmResults.count)
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let tableViewCell = tableView.dequeueReusableCellWithIdentifier(defaultTableViewCellIdentifier, forIndexPath: indexPath) 

        if let realmResults = realmResults {
            if let realmObject = realmResults[UInt(indexPath.row)] as? RLMObject {
                if let valueKeyPath = valueKeyPath , stringValue = realmObject.valueForKeyPath(valueKeyPath) as? String {
                    tableViewCell.textLabel?.text = stringValue
                }
            }
        }
        
        return tableViewCell
    }
    
    // MARK: UITableViewDelegate
    
    
}