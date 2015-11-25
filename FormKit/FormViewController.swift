//
//  FormViewController.swift
//  loopd-ios
//
//  Created by Michael Loistl on 26/02/2015.
//  Copyright (c) 2015 Loopd.life. All rights reserved.
//

import Foundation

public class FormViewController: UITableViewController, FormManagerDelegate, FormTableViewCellDataSource, FormTableViewCellDelegate, FormSelectionTableViewControllerDelegate {
    
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
    
    public override init(style: UITableViewStyle) {
        super.init(style: style)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        } else if let formSelectionCell = sender as? FormSelectionTableViewCell where formSelectionCell.isEditable {
            let viewController = FormSelectionTableViewController()
            viewController.selectionValues = formSelectionCell.selectionValues
            viewController.allowsMultipleSelection = formSelectionCell.allowsMultipleSelection
            viewController.formTableViewCellIdentifier = identifier
            viewController.delegate = self
            
            // TODO: Support AnyObject value type
            
            if let formCellValues = formSelectionCell.value as? [String] {
                viewController.selectedValues = formCellValues
            } else if let formCellValue = formSelectionCell.value as? String {
                viewController.selectedValues = [formCellValue]
            }
            
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
        let tableViewCell = formManager.cellForRowAtIndexPath(indexPath) as FormTableViewCell
        return tableViewCell
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
        return formManager.heightForRowAtIndexPath(indexPath)
    }
    // MARK: FormManagerDelegate {
    
    public func formManagerDidSetFormCells(sender: FormManager) {
        tableView.reloadData()
    }
    
    // MARK: FormTableViewCellDataSource
    
    public func defaultConfigurationForFormCell(sender: FormTableViewCell, identifier: String) -> FormTableViewCellConfiguration? {
        return FormTableViewCellConfiguration.defaultConfiguration()
    }
    
    public func formManagerForFormCell(sender: FormTableViewCell, identifier: String) -> FormManager? {
        return formManager
    }
    
    public func labelEdgeInsetsForFormCell(sender: FormTableViewCell, identifier: String) -> UIEdgeInsets {
        if let _ = sender as? FormButtonTableViewCell {
            return UIEdgeInsetsZero
        }
        
        return UIEdgeInsetsMake(0, 16, 0, 16)
    }
    
    public func valueEdgeInsetsForFormCell(sender: FormTableViewCell, identifier: String) -> UIEdgeInsets {
        return UIEdgeInsetsMake(11, 120, 11, 16)
    }
    
    public func buttonEdgeInsetsForFormCell(sender: FormTableViewCell, identifier: String) -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }

    public func bottomLineEdgeInsetsForFormCell(sender: FormTableViewCell, identifier: String) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 16, 0, 0)
    }
    
    public func bottomLineWidthForFormCell(sender: FormTableViewCell, identifier: String) -> CGFloat {
        return 0
    }

    public func valueForFormCell(sender: FormTableViewCell, identifier: String) -> AnyObject? {
        return nil
    }
    
    public func valueTransformerForKey(key: String!, identifier: String?) -> NSValueTransformer! {
        return nil
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
    
    public func formCell(sender: FormTableViewCell, identifier: String, didChangeValue value: AnyObject?, valueKeyPath: String?) {
        
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
    
    public func formSelectionTableViewController(sender: FormSelectionTableViewController, didSelectValues values: [String], withFormTableViewCellIdentifier identifier: String?) {
        if let identifier = identifier, formCell = formManager.formCellWithIdentifier(identifier) {
            formCell.value = values
        }
    }
    
}