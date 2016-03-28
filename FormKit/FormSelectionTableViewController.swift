//
//  FormSelectionTableViewController.swift
//  loopd-ios
//
//  Created by Michael Loistl on 27/03/2015.
//  Copyright (c) 2015 Loopd.life. All rights reserved.
//

import Foundation

public protocol FormSelectable {
    func stringValue() -> String
    func identifier() -> String
}

public protocol FormSelectionTableViewControllerDelegate {
    func formSelectionTableViewController(sender: FormSelectionTableViewController, didSelectObjects objects: [AnyObject], withFormTableViewCellIdentifier identifier: String?)
    func formSelectionTableViewController(sender: FormSelectionTableViewController,  tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
}

public class FormSelectionTableViewController: UITableViewController {

    let CellIdentifier = "com.michaelloistl.CellIdentifier"
    
    public var allowsMultipleSelection = true
    
    public var selectionObjects = [FormSelectable]()
    public var selectedObjects = [FormSelectable]() {
        didSet {
            clearBarButtonItem.enabled = selectedObjects.count > 0
        }
    }
    
    public var formTableViewCellIdentifier: String?
    
    public var delegate: FormSelectionTableViewControllerDelegate?
    
    lazy var clearBarButtonItem: UIBarButtonItem = {
        let _barButtonItem = UIBarButtonItem(title: "Clear", style: .Plain, target: self, action: #selector(FormSelectionTableViewController.clearBarButtonItemTouchedUpInside(_:)))
        _barButtonItem.enabled = false

        return _barButtonItem
    }()
    
    // MARK: - Super

    override public func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: CellIdentifier)
        
        navigationItem.rightBarButtonItem = clearBarButtonItem
//        if allowsMultipleSelection {
//        }
    }

    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        var selectedAnyObjects = [AnyObject]()
        for object in selectedObjects {
            if let object = object as? AnyObject {
                selectedAnyObjects.append(object)
            }
        }
        
        delegate?.formSelectionTableViewController(self, didSelectObjects: selectedAnyObjects, withFormTableViewCellIdentifier: formTableViewCellIdentifier)
    }
    
    // MARK: - Methods
    
    // MARK: Actions
    
    func clearBarButtonItemTouchedUpInside(sender: UIBarButtonItem) {
        selectedObjects.removeAll()
        tableView.reloadData()

        if !allowsMultipleSelection {
            navigationController?.popViewControllerAnimated(true)
        }
    }
    
    // MARK: - Protocols
    
    // MARK: UITableViewDataSource
    
    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectionObjects.count
    }
    
    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let tableViewCell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath: indexPath)

        let selectionObject = selectionObjects[indexPath.row]
        tableViewCell.textLabel?.text = selectionObject.stringValue()
        tableViewCell.selectionStyle = (allowsMultipleSelection) ? .None : .Default
        tableViewCell.accessoryType = (selectedObjects.indexOf({ $0.identifier() == selectionObject.identifier()}) == nil) ? .None : .Checkmark
        
        return tableViewCell
    }
    
    // MARK: UITableViewDelegate
    
    override public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectionObject = selectionObjects[indexPath.row]
        if let index = selectedObjects.indexOf({ $0.identifier() == selectionObject.identifier()}) {
            selectedObjects.removeAtIndex(index)
        } else {
            if !allowsMultipleSelection {
                selectedObjects.removeAll()
            }
            
            selectedObjects.append(selectionObject)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if allowsMultipleSelection {
            clearBarButtonItem.enabled = selectedObjects.count > 0
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        } else {
            navigationController?.popViewControllerAnimated(true)
        }
    }
    
    override public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.formSelectionTableViewController(self, tableView: tableView, willDisplayCell: cell, forRowAtIndexPath: indexPath)
    }

}