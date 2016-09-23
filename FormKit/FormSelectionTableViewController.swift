//
//  FormSelectionTableViewController.swift
//  loopd-ios
//
//  Created by Michael Loistl on 27/03/2015.
//  Copyright (c) 2015 Loopd.life. All rights reserved.
//

import Foundation

public protocol FormSelectionTableViewControllerDelegate {
    func formSelectionTableViewController(sender: FormSelectionTableViewController, didSelectObjects objects: [AnyObject], withFormTableViewCellIdentifier identifier: String?)
    func formSelectionTableViewController(sender: FormSelectionTableViewController,  tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
}

public class FormSelectionTableViewController: UITableViewController  {

    let CellIdentifier = "com.michaelloistl.CellIdentifier"
    
    public weak var formSelectionTableViewCell: FormSelectionTableViewCell?

    var selectedIndexPath = [NSIndexPath]()
    
    public var allowsMultipleSelection = true
    
//    // FormSelectionProtocol
//    public var dataSourceClosure: FormSelectionTableViewCell.DataSourceClosure?
//    public var selectedClosure: FormSelectionTableViewCell.SelectionClosure?

    
//    public var selectionObjects = [FormSelectable]()
//    public var selectedObjects = [FormSelectable]() {
//        didSet {
//            clearBarButtonItem.enabled = selectedObjects.count > 0
//        }
//    }
    
//s    public var formTableViewCellIdentifier: String?
    
//    public var delegate: FormSelectionTableViewControllerDelegate?
    
    lazy var clearBarButtonItem: UIBarButtonItem = {
        let _barButtonItem = UIBarButtonItem(title: "Clear", style: .Plain, target: self, action: #selector(clearBarButtonItemTouchedUpInside(_:)))
        _barButtonItem.enabled = false

        return _barButtonItem
    }()
    
    // MARK: - Super

    override public func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: CellIdentifier)
        tableView.tableFooterView = UIView()
        
        if allowsMultipleSelection {
            navigationItem.rightBarButtonItem = clearBarButtonItem
        }
    }

    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        selectedIndexPath = formSelectionTableViewCell?.getSelectedClosure?() ?? [NSIndexPath]()
    }
    
    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        formSelectionTableViewCell?.setSelectedClosure?(selectedIndexPath)
    }
    
    // MARK: - Methods
    
    // MARK: Actions
    
    func clearBarButtonItemTouchedUpInside(sender: UIBarButtonItem) {
        selectedIndexPath.removeAll()
        tableView.reloadData()

        if !allowsMultipleSelection {
            navigationController?.popViewControllerAnimated(true)
        }
    }
    
    // MARK: - Protocols
    
    // MARK: UITableViewDataSource
    
    override public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return formSelectionTableViewCell?.dataSourceClosure?().count ?? 0
    }
    
    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return formSelectionTableViewCell?.dataSourceClosure?()[section].count ?? 0
    }
    
    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let tableViewCell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath: indexPath)
        tableViewCell.textLabel?.text = formSelectionTableViewCell?.dataSourceClosure?()[indexPath.section][indexPath.row]
        tableViewCell.selectionStyle = (allowsMultipleSelection) ? .None : .Default
        tableViewCell.accessoryType = (selectedIndexPath.contains(indexPath)) ? .Checkmark : .None

        return tableViewCell
    }
    
    // MARK: UITableViewDelegate
    
    override public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let index = selectedIndexPath.indexOf({ $0 == indexPath}) {
            selectedIndexPath.removeAtIndex(index)
        } else {
            if !allowsMultipleSelection {
                selectedIndexPath.removeAll()
            }
            
            selectedIndexPath.append(indexPath)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if allowsMultipleSelection {
            clearBarButtonItem.enabled = selectedIndexPath.count > 0
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        } else {
            navigationController?.popViewControllerAnimated(true)
        }
    }
    
//    override public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//        delegate?.formSelectionTableViewController(self, tableView: tableView, willDisplayCell: cell, forRowAtIndexPath: indexPath)
//    }

}