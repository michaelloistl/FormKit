//
//  FormSelectionTableViewController.swift
//  loopd-ios
//
//  Created by Michael Loistl on 27/03/2015.
//  Copyright (c) 2015 Loopd.life. All rights reserved.
//

import Foundation
//import RealmSwift

//protocol FormSelectionTableViewControllerDelegate {
//    func formSelectionTableViewController(sender: FormSelectionTableViewController, didSelectRealmObjects objects: [RealmObject], withFormTableViewCellIdentifier identifier: String?)
//}

class FormSelectionTableViewController: UITableViewController {

//    let defaultTableViewCellIdentifier = "defaultTableViewCellIdentifier"
//    
//    var delegate: FormSelectionTableViewControllerDelegate?
//    
//    var formTableViewCellIdentifier: String?
//    var objectType: RealmObject.Type?
//    var valueKeyPath: String?
//    var sortDescriptors: [SortDescriptor]?
//    var realmResults: Results<RealmObject>? {
//        didSet {
//            tableView.reloadData()
//        }
//    }
//    
//    lazy var clearBarButtonItem: UIBarButtonItem = {
//        let _clearBarButtonItem = UIBarButtonItem(title: "Clear", style: .Plain, target: self, action: Selector("clearBarButtonItemSelected:"))
//        
//        return _clearBarButtonItem
//    }()
//    
//    // MARK: Override UIViewController Functions
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        title = "Select"
//        
//        navigationItem.rightBarButtonItem = clearBarButtonItem
//        
//        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: defaultTableViewCellIdentifier)
//        
//        if let objectType = objectType {
//            let realmResults = App.realm()?.objects(objectType)
//            
//            if let sortDescriptors = sortDescriptors {
//                realmResults?.sorted(sortDescriptors)
//            }
//            
//            self.realmResults = realmResults
//        }
//    }
//    
//    override func viewWillDisappear(animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        var selectedObjects = [RealmObject]()
//        
//        if let indexPathsForSelectedRows = tableView.indexPathsForSelectedRows {
//            for indexPath in indexPathsForSelectedRows {
//                if let realmResults = realmResults {
//                    let realmObject = realmResults[indexPath.row]
//                    selectedObjects.append(realmObject)
//                }
//            }
//        }
//        
//        delegate?.formSelectionTableViewController(self, didSelectRealmObjects: selectedObjects, withFormTableViewCellIdentifier: formTableViewCellIdentifier)
//    }
//    
//    // MARK: IBAction Functions
//    
//    func clearBarButtonItemSelected(sender: UIBarButtonItem) {
//        
//    }
//    
//    // MARK: Functions
//    
//    // MARK: UITableViewDataSource
//    
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if let realmResults = realmResults {
//            return Int(realmResults.count)
//        }
//        return 0
//    }
//    
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let tableViewCell = tableView.dequeueReusableCellWithIdentifier(defaultTableViewCellIdentifier, forIndexPath: indexPath) 
//
//        if let realmObject = realmResults?[indexPath.row] {
//            if let valueKeyPath = valueKeyPath , stringValue = realmObject.valueForKeyPath(valueKeyPath) as? String {
//                tableViewCell.textLabel?.text = stringValue
//            }
//        }
//        
//        return tableViewCell
//    }
//    
//    // MARK: UITableViewDelegate
    
    
}