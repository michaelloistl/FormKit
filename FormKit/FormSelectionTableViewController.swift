//
//  FormSelectionTableViewController.swift
//  loopd-ios
//
//  Created by Michael Loistl on 27/03/2015.
//  Copyright (c) 2015 Loopd.life. All rights reserved.
//

import Foundation

public protocol FormSelectionTableViewControllerDelegate {
    func formSelectionTableViewController(_ sender: FormSelectionTableViewController, didSelectObjects objects: [AnyObject], withFormTableViewCellIdentifier identifier: String?)
    func formSelectionTableViewController(_ sender: FormSelectionTableViewController,  tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: IndexPath)
}

open class FormSelectionTableViewController: UITableViewController  {

    let CellIdentifier = "com.michaelloistl.CellIdentifier"
    
    open weak var formSelectionTableViewCell: FormSelectionTableViewCell?

    var selectedIndexPath = [IndexPath]()
    
    open var allowsMultipleSelection = true
    
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
        let _barButtonItem = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearBarButtonItemTouchedUpInside(_:)))
        _barButtonItem.isEnabled = false

        return _barButtonItem
    }()
    
    // MARK: - Super

    override open func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellIdentifier)
        tableView.tableFooterView = UIView()
        
        if allowsMultipleSelection {
            navigationItem.rightBarButtonItem = clearBarButtonItem
        }
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        selectedIndexPath = formSelectionTableViewCell?.getSelectedClosure?() as [IndexPath]? ?? [IndexPath]()
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        formSelectionTableViewCell?.setSelectedClosure?(selectedIndexPath)
    }
    
    // MARK: - Methods
    
    // MARK: Actions
    
    func clearBarButtonItemTouchedUpInside(_ sender: UIBarButtonItem) {
        selectedIndexPath.removeAll()
        tableView.reloadData()

        if !allowsMultipleSelection {
            let _ = navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - Protocols
    
    // MARK: UITableViewDataSource
    
    override open func numberOfSections(in tableView: UITableView) -> Int {
        return formSelectionTableViewCell?.dataSourceClosure?().count ?? 0
    }
    
    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return formSelectionTableViewCell?.dataSourceClosure?()[section].count ?? 0
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath)
        tableViewCell.textLabel?.text = formSelectionTableViewCell?.dataSourceClosure?()[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        tableViewCell.selectionStyle = (allowsMultipleSelection) ? .none : .default
        tableViewCell.accessoryType = (selectedIndexPath.contains(indexPath)) ? .checkmark : .none

        return tableViewCell
    }
    
    // MARK: UITableViewDelegate
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let index = selectedIndexPath.index(where: { $0 == indexPath}) {
            selectedIndexPath.remove(at: index)
        } else {
            if !allowsMultipleSelection {
                selectedIndexPath.removeAll()
            }
            
            selectedIndexPath.append(indexPath)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if allowsMultipleSelection {
            clearBarButtonItem.isEnabled = selectedIndexPath.count > 0
            tableView.reloadRows(at: [indexPath], with: .none)
        } else {
            let _ = navigationController?.popViewController(animated: true)
        }
    }
    
//    override public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//        delegate?.formSelectionTableViewController(self, tableView: tableView, willDisplayCell: cell, forRowAtIndexPath: indexPath)
//    }

}
