//
//  FormViewController.swift
//  loopd-ios
//
//  Created by Michael Loistl on 26/02/2015.
//  Copyright (c) 2015 Loopd.life. All rights reserved.
//

import Foundation

public class FormViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FormManagerDelegate, FormTableViewCellDelegate, FormSelectionTableViewControllerDelegate {
    
    private var tableViewStyle: UITableViewStyle = .Grouped
    
    public var animateRowHeightChanges = false
    public var animateRowVisibilityChanges = false
    
    public var isVisible: Bool {
        return isViewLoaded() && view?.window != nil
    }
    
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
    
    public lazy var tableView: UITableView! = {
        let _tableView = UITableView(frame: CGRect.zero, style: self.tableViewStyle)
        _tableView.translatesAutoresizingMaskIntoConstraints = false
        
        _tableView.dataSource = self
        _tableView.delegate = self
        _tableView.scrollsToTop = true

        _tableView.tableFooterView = UIView()
        _tableView.rowHeight = UITableViewAutomaticDimension
        
        return _tableView
    }()
    
    // MARK: - Initializers
    
    public convenience init(style: UITableViewStyle) {
        self.init(nibName: nil, bundle: nil)
        
        self.tableViewStyle = style
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Super
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        
        tableView.autoPinEdgesToSuperviewEdges()
        
        setupForm()
    }
    
    // MARK: - Methods
    
    public func reloadTableView() {
        
        formManager.shouldResignFirstResponder = false
        
        tableView.reloadData()
        
        formManager.shouldResignFirstResponder = true
    }
    
    // MARK: Setup
    
    public func setupForm() {

    }
    
    public func didSelectFormCell(sender: FormTableViewCell, withIdentifier identifier: String) {
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
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return formManager.numberOfSections()
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return formManager.numberOfRowsInSection(section)
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let formCell = formManager.cellForRowAtIndexPath(indexPath) {
            return formCell
        }
        return UITableViewCell()
    }
    
    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let formSectionTitles = formManager.formSectionTitles {
            if formSectionTitles.count > section {
                return formSectionTitles[section]
            }
        }
        return nil
    }
    
    // MARK: UITableViewDelegate
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let formCell = tableView.cellForRowAtIndexPath(indexPath) as? FormTableViewCell {
            didSelectFormCell(formCell, withIdentifier: formCell.identifier)
        }

        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.separatorInset = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    public func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return formManager.heightForRowAtIndexPath(indexPath) ?? 44
    }
    
    // MARK: FormManagerDelegate {
    
    public func formManagerDidSetFormSections(sender: FormManager) {
        reloadTableView()
    }
    
    public func formManagerShouldReloadForm(sender: FormManager) {
        reloadTableView()
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
    
    public func formCell(sender: FormTableViewCell, identifier: String, didResignFirstResponder firstResponder: UIView?) {
        
    }
    
    public func formCell(sender: FormTableViewCell, identifier: String, didChangeValue value: AnyObject?) {
        
    }
    
    public func formCell(sender: FormTableViewCell, identifier: String, didChangeRowHeightFrom from: CGFloat, to: CGFloat) {
        if formManager.reloadTransaction {
            formManager.shouldReloadAfterTransaction = true
        } else {
            if animateRowHeightChanges {
                tableView.beginUpdates()
                tableView.endUpdates()
            } else {
                reloadTableView()
            }
        }
    }
    
    public func formCell(sender: FormTableViewCell, identifier: String, didChangeRowVisibilityAtIndexPath from: NSIndexPath?, to: NSIndexPath?) {
        if formManager.reloadTransaction {
            formManager.shouldReloadAfterTransaction = true
        } else {
            if animateRowVisibilityChanges {
                tableView.beginUpdates()
                
                // Insert
                if from == nil {
                    if let indexPath = to {
                        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Middle)
                    }
                }
                    
                    // Remove
                else if to == nil {
                    if let indexPath = from {
                        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Middle)
                    }
                }
                
                tableView.endUpdates()
            } else {
                reloadTableView()
            }
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
    
    public func formCellShouldResignFirstResponder(sender: FormTableViewCell) -> Bool {
        return formManager.shouldResignFirstResponder
    }
    
    // MARK: FormSelectionTableViewControllerDelegate
    
    public func formSelectionTableViewController(sender: FormSelectionTableViewController, didSelectObjects objects: [AnyObject], withFormTableViewCellIdentifier identifier: String?) {
        if let identifier = identifier, formCell = formManager.formCellWithIdentifier(identifier) {
            formCell.value = objects
        }
    }
    
    public func formSelectionTableViewController(sender: FormSelectionTableViewController,  tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}