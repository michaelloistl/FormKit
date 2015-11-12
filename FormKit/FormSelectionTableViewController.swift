//
//  FormSelectionTableViewController.swift
//  loopd-ios
//
//  Created by Michael Loistl on 27/03/2015.
//  Copyright (c) 2015 Loopd.life. All rights reserved.
//

import Foundation

public protocol FormSelectionTableViewControllerDelegate {
    func formSelectionTableViewController(sender: FormSelectionTableViewController, didSelectValues values: [String], withFormTableViewCellIdentifier identifier: String?)
}

public class FormSelectionTableViewController: UITableViewController {

    let CellIdentifier = "com.michaelloistl.CellIdentifier"
    
    public var allowsMultipleSelection = true
    
    public var selectionValues = [String]()
    public var selectedValues = [String]() {
        didSet {
            clearBarButtonItem.enabled = selectedValues.count > 0
        }
    }
    
    public var formTableViewCellIdentifier: String?
    
    public var delegate: FormSelectionTableViewControllerDelegate?
    
    lazy var clearBarButtonItem: UIBarButtonItem = {
        let _barButtonItem = UIBarButtonItem(title: "Clear", style: .Plain, target: self, action: Selector("clearBarButtonItemTouchedUpInside:"))
        _barButtonItem.enabled = false

        return _barButtonItem
    }()
    
    // MARK: - Super

    override public func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: CellIdentifier)
        
        if allowsMultipleSelection {
            navigationItem.rightBarButtonItem = clearBarButtonItem
        }
    }

    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        delegate?.formSelectionTableViewController(self, didSelectValues: selectedValues, withFormTableViewCellIdentifier: formTableViewCellIdentifier)
    }
    
    // MARK: - Methods
    
    // MARK: Actions
    
    func clearBarButtonItemTouchedUpInside(sender: UIBarButtonItem) {
        selectedValues.removeAll()
        tableView.reloadData()
    }
    
    // MARK: - Protocols
    
    // MARK: UITableViewDataSource
    
    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectionValues.count
    }
    
    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let tableViewCell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath: indexPath)

        let selectionValue = selectionValues[indexPath.row]
        tableViewCell.textLabel?.text = selectionValue
        tableViewCell.selectionStyle = (allowsMultipleSelection) ? .None : .Default
        
        if allowsMultipleSelection {
            tableViewCell.accessoryType = (selectedValues.indexOf(selectionValue) == nil) ? .None : .Checkmark
        }
        
        return tableViewCell
    }
    
    // MARK: UITableViewDelegate
    
    override public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectionValue = selectionValues[indexPath.row]
        if let index = selectedValues.indexOf(selectionValue) {
            selectedValues.removeAtIndex(index)
        } else {
            selectedValues.append(selectionValue)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        NSLog("selectedValues: \(selectedValues)")
        
        if allowsMultipleSelection {
            clearBarButtonItem.enabled = selectedValues.count > 0
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        } else {
            navigationController?.popViewControllerAnimated(true)
        }
    }
    
}