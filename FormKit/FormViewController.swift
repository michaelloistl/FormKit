//
//  FormViewController.swift
//  loopd-ios
//
//  Created by Michael Loistl on 26/02/2015.
//  Copyright (c) 2015 Loopd.life. All rights reserved.
//

import Foundation

class FormViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FormTableViewCellDataSource, FormTableViewCellDelegate {
    
    let formManager = FormManager()
    
    lazy var tableView: UITableView = {
        let _tableView = UITableView(frame: CGRectZero, style: .Grouped)
        _tableView.translatesAutoresizingMaskIntoConstraints = false
        _tableView.tableFooterView = UIView()
        _tableView.separatorInset = UIEdgeInsetsZero
        _tableView.dataSource = self
        _tableView.delegate = self
        
        return _tableView
        }()
    
    // MARK: Override UIViewController Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        
        tableView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero)
        
        setupForm()
    }
    
    // MARK: Setup Functions
    
    func setupForm() {
        
    }
    
    // MARK: Functions
    
    // MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return formManager.numberOfSections()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return formManager.numberOfRowsInSection(section)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let tableViewCell = formManager.cellForRowAtIndexPath(indexPath) as FormTableViewCell
        return tableViewCell
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.separatorInset = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return formManager.heightForRowAtIndexPath(indexPath)
    }
        
    // MARK: FormTableViewCellDataSource
    
    func valueForFormCell(sender: UITableViewCell, withIdentifier identifier: String) -> AnyObject? {
        return nil
    }
    
    func valueInputEdgeInsetsForFormCell(sender: UITableViewCell, withIdentifier identifier: String) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 120, 0, 11)
    }
    
    func labelEdgeInsetsForFormCell(sender: UITableViewCell, withIdentifier identifier: String) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 19, 0, 0)
    }
    
    // MARK: FormTableViewCellDelegate
    
    func formCell(sender: UITableViewCell, withIdentifier identifier: String, didBecomeFirstResponder firstResponder: UIView?) {
        
    }
    
    func formCell(sender: UITableViewCell, withIdentifier identifier: String, didChangeValue value: AnyObject?, forObjectType objectType:AnyClass?, valueKeyPath: String?) {
        
    }
    
    func formCell(sender: UITableViewCell, withIdentifier identifier: String, didChangeRowHeight rowHeight: CGFloat) {
        
    }
    
    func formCell(sender: UITableViewCell, withIdentifier identifier: String, didChangeRowVisibility visible: Bool) {
//        if isViewLoaded() && view.window != nil {
            formManager.updateVisibleFormCells()
            tableView.reloadData()
//        }
    }
    
    func formCell(sender: UITableViewCell, withIdentifier identifier: String, shouldValidateWithIdentifier validationIdentifier: String) -> Bool {
        return true
    }
    
    // MARK: FormValueTransformer
    
    func formValueTransformerForKeyPath(keyPath: String!) -> NSValueTransformer! {
        return nil
    }
    
}