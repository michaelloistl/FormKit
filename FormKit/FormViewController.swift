//
//  FormViewController.swift
//  loopd-ios
//
//  Created by Michael Loistl on 26/02/2015.
//  Copyright (c) 2015 Loopd.life. All rights reserved.
//

import Foundation

public class FormViewController: UITableViewController, FormManagerDelegate, FormTableViewCellDelegate, FormSelectionTableViewControllerDelegate {
    
    public var animateRowHeightChanges = true
    public var animateRowVisibilityChanges = true
    
    var visibleTableViewRect: CGRect {
        var _visibleTableViewRect = tableView.bounds
        _visibleTableViewRect.size.height = CGRectGetHeight(tableView.bounds) - tableView.contentInset.bottom
        
        return _visibleTableViewRect
    }
    
    public lazy var formManager: FormManager = {
        let _formManager = FormManager()
        _formManager.delegate = self
        
        return _formManager
        }()
    
    // MARK: - Initializers
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Super
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        
        setupForm()
    }
    
    // MARK: - Methods
    
    // MARK: Setup
    
    public func setupForm() {

    }
    
    func didSelectFormCell(sender: FormTableViewCell, withIdentifier identifier: String) {
        if sender.actions.count > 0 {
            for action in sender.actions {
                action.closure(value: sender.value)
            }
        } else if let formSelectionCell = sender as? FormSelectionTableViewCell where formSelectionCell.editable {
            let viewController = FormSelectionTableViewController()
            viewController.allowsMultipleSelection = formSelectionCell.allowsMultipleSelection
            viewController.formTableViewCellIdentifier = identifier
            viewController.delegate = self

            viewController.selectionObjects = formSelectionCell.selectionDataSource.selectionObjectsClosure(value: formSelectionCell.value)
            viewController.selectedObjects = formSelectionCell.selectionDataSource.selectedObjectsClosure(value: formSelectionCell.value)
            
            if let title = formSelectionCell.selectionTitle {
                viewController.title = title
            } else if let label = formSelectionCell.label.text {
                viewController.title = "Select \(label)"
            }
            
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    // MARK: - Protocols
    
    // MARK: UITableViewDataSource
    
    override public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return formManager.numberOfSections()
    }
    
    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return formManager.numberOfRowsInSection(section)
    }
    
    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let formCell = formManager.cellForRowAtIndexPath(indexPath) {
            return formCell
        }
        return UITableViewCell()
    }
    
    // MARK: UITableViewDelegate
    
    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let formCell = tableView.cellForRowAtIndexPath(indexPath) as? FormTableViewCell {
            didSelectFormCell(formCell, withIdentifier: formCell.identifier)
        }

        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.separatorInset = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    override public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return formManager.heightForRowAtIndexPath(indexPath) ?? 44
    }
    
    // MARK: FormManagerDelegate {
    
    public func formManagerDidSetFormSections(sender: FormManager) {
        tableView.reloadData()
    }
    
    // MARK: FormTableViewCellDelegate
    
    public func formCell(sender: FormTableViewCell, identifier: String, didBecomeFirstResponder firstResponder: UIView?) {
        if let indexPath = tableView.indexPathForCell(sender) {
            let cellRect = tableView.rectForRowAtIndexPath(indexPath)
            
            let completelyVisible = visibleTableViewRect.contains(cellRect)

            if !completelyVisible {
                tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
            }
        }
    }
    
    public func formCell(sender: FormTableViewCell, identifier: String, didChangeValue value: AnyObject?) {
        
    }
    
    public func formCell(sender: FormTableViewCell, identifier: String, didChangeRowHeightFrom from: CGFloat, to: CGFloat) {
        if animateRowHeightChanges {
            tableView.beginUpdates()
            tableView.endUpdates()
        } else {
            tableView.reloadData()
        }
    }
    
    public func formCell(sender: FormTableViewCell, identifier: String, didChangeRowVisibilityAtIndexPath from: NSIndexPath?, to: NSIndexPath?) {
        if animateRowVisibilityChanges {
            tableView.beginUpdates()
            
            // Insert
            if from == nil {
                if let indexPath = to {
                    tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                }
            }
                
                // Remove
            else if to == nil {
                if let indexPath = from {
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                }
            }
            
            tableView.endUpdates()
        } else {
            tableView.reloadData()
        }
    }
    
    public func formCellDidRequestNextFormTableViewCell(sender: FormTableViewCell, identifier: String) {
        if let nextFormCell = formManager.nextFormTableViewCell() {
            if let indexPath = tableView.indexPathForCell(nextFormCell) {
                let cellRect = tableView.rectForRowAtIndexPath(indexPath)
                
                let completelyVisible = visibleTableViewRect.contains(cellRect)
                
                nextFormCell.becomeFirstResponder()

                if !completelyVisible {
                    tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
                }
            }
        }
    }
    
    public func formCell(sender: FormTableViewCell, identifier: String, shouldValidateWithIdentifier validationIdentifier: String) -> Bool {
        return true
    }
    
    public func formCell(sender: FormTableViewCell, identifier: String, didTouchUpInsideButton button: UIButton) {
        
    }
    
    // MARK: FormSelectionTableViewControllerDelegate
    
    public func formSelectionTableViewController(sender: FormSelectionTableViewController, didSelectObjects objects: [AnyObject], withFormTableViewCellIdentifier identifier: String?) {
        if let identifier = identifier, formCell = formManager.formCellWithIdentifier(identifier) {
            formCell.value = objects
        }
    }
}