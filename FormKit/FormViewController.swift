//
//  FormViewController.swift
//  loopd-ios
//
//  Created by Michael Loistl on 26/02/2015.
//  Copyright (c) 2015 Loopd.life. All rights reserved.
//

import Foundation

public class FormViewController: UITableViewController, FormTableViewCellDataSource, FormTableViewCellDelegate, FormSelectionTableViewControllerDelegate {
    
    public let formManager = FormManager()
    
    var visibleTableViewRect: CGRect {
        var _visibleTableViewRect = tableView.bounds
        _visibleTableViewRect.size.height = CGRectGetHeight(tableView.bounds) - tableView.contentInset.bottom
        
        return _visibleTableViewRect
    }
    
    // MARK: - Initializers
    
    public override init(style: UITableViewStyle) {
        super.init(style: style)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Super
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
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
        } else if let formSelectionCell = sender as? FormSelectionTableViewCell {
            let viewController = FormSelectionTableViewController()
            viewController.selectionValues = formSelectionCell.selectionValues
            viewController.allowsMultipleSelection = formSelectionCell.allowsMultipleSelection
            viewController.formTableViewCellIdentifier = identifier
            viewController.delegate = self
            
            if let formCellValues = formSelectionCell.value as? [String] {
                viewController.selectedValues = formCellValues
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
        
    // MARK: FormTableViewCellDataSource
    
    public func labelEdgeInsetsForFormCell(sender: FormTableViewCell, withIdentifier identifier: String) -> UIEdgeInsets {
        if let _ = sender as? FormButtonTableViewCell {
            return UIEdgeInsetsZero
        }
        
        return UIEdgeInsetsMake(0, 16, 0, 16)
    }
    
    public func labelConfigurationForFormCell(sender: FormTableViewCell, withIdentifier identifier: String) -> [String: AnyObject] {
        return [String: AnyObject]()
    }

    public func valueForFormCell(sender: FormTableViewCell, withIdentifier identifier: String) -> AnyObject? {
        return nil
    }
    
    public func valueEdgeInsetsForFormCell(sender: FormTableViewCell, withIdentifier identifier: String) -> UIEdgeInsets {
        return UIEdgeInsetsMake(11, 120, 11, 16)
    }
    
    public func valueConfigurationForFormCell(sender: FormTableViewCell, withIdentifier identifier: String) -> [String: AnyObject] {
        return [String: AnyObject]()
    }
    
    // MARK: FormTableViewCellDelegate
    
    public func formCell(sender: FormTableViewCell, withIdentifier identifier: String, didBecomeFirstResponder firstResponder: UIView?) {
        if let indexPath = tableView.indexPathForCell(sender) {
            let cellRect = tableView.rectForRowAtIndexPath(indexPath)
            
            let completelyVisible = visibleTableViewRect.contains(cellRect)

            if !completelyVisible {
                tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
            }
        }
    }
    
    public func formCell(sender: FormTableViewCell, withIdentifier identifier: String, didChangeValue value: AnyObject?, forObjectType objectType:AnyClass?, valueKeyPath: String?) {
        
    }
    
    public func formCell(sender: FormTableViewCell, withIdentifier identifier: String, didChangeRowHeight rowHeight: CGFloat) {

    }
    
    public func formCell(sender: FormTableViewCell, withIdentifier identifier: String, didChangeRowVisibility visible: Bool) {
//        if isViewLoaded() && view.window != nil {
            formManager.updateVisibleFormCells()
            tableView.reloadData()
//        }
    }
    
    public func formCellDidRequestNextFormTableViewCell(sender: FormTableViewCell, withIdentifier identifier: String) {
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
    
    public func formCell(sender: FormTableViewCell, withIdentifier identifier: String, shouldValidateWithIdentifier validationIdentifier: String) -> Bool {
        return true
    }
    
    // MARK: FormSelectionTableViewControllerDelegate
    
    public func formSelectionTableViewController(sender: FormSelectionTableViewController, didSelectValues values: [String], withFormTableViewCellIdentifier identifier: String?) {
        if let identifier = identifier, formCell = formManager.formCellWithIdentifier(identifier) {
            formCell.value = values
        }
    }
    
    // MARK: FormValueTransformer
    
    func formValueTransformerForKeyPath(keyPath: String!) -> NSValueTransformer! {
        return nil
    }
    
}