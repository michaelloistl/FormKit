//
//  FormViewController.swift
//  loopd-ios
//
//  Created by Michael Loistl on 26/02/2015.
//  Copyright (c) 2015 Loopd.life. All rights reserved.
//

import Foundation

open class FormViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FormManagerDelegate, FormTableViewCellDelegate, FormSelectionTableViewControllerDelegate {
    
    open var tableViewStyle: UITableViewStyle = .grouped
    
    open var animateRowHeightChanges = false
    open var animateRowVisibilityChanges = false
    
    open var isVisible: Bool {
        return isViewLoaded && view?.window != nil
    }
    
    var visibleTableViewRect: CGRect {
        var _visibleTableViewRect = tableView.bounds
        _visibleTableViewRect.size.height = tableView.bounds.height - tableView.contentInset.bottom
        
        return _visibleTableViewRect
    }
    
    open lazy var formManager: FormManager = {
        let _formManager = FormManager()
        _formManager.delegate = self
        
        return _formManager
        }()
    
    open lazy var tableView: UITableView = {
        let _tableView = UITableView(frame: CGRect.zero, style: self.tableViewStyle)
        _tableView.translatesAutoresizingMaskIntoConstraints = false
        
        _tableView.dataSource = self
        _tableView.delegate = self
        _tableView.scrollsToTop = true

        _tableView.tableFooterView = UIView()
        _tableView.rowHeight = UITableViewAutomaticDimension
        
        _tableView.restorationIdentifier = "TableView"
        
        return _tableView
    }()
    
    // MARK: - Initializers
    
    public convenience init(style: UITableViewStyle) {
        self.init(nibName: nil, bundle: nil)
        
        self.tableViewStyle = style
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Super
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        
        tableView.autoPinEdgesToSuperviewEdges()
        
        setupForm()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animateRowHeightChanges = true
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        animateRowHeightChanges = false
    }
    
    // MARK: - Methods
    
    open func reloadTableView() {
        formManager.shouldResignFirstResponder = false
        
        tableView.reloadData()
        
        formManager.shouldResignFirstResponder = true
    }
    
    // MARK: Setup
    
    open func setupForm() {

    }
    
    open func didSelectFormCell(_ sender: FormTableViewCell) {
        if let action = sender.action {
            action(sender, sender.value)
        } else if let formSelectionCell = sender as? FormSelectionTableViewCell , formSelectionCell.editable {
            let viewController = FormSelectionTableViewController()
            viewController.allowsMultipleSelection = formSelectionCell.allowsMultipleSelection
            viewController.formSelectionTableViewCell = formSelectionCell
            
            if let title = formSelectionCell.title {
                viewController.title = title
            } else if let label = formSelectionCell.label.text {
                viewController.title = "Select \(label)"
            }
            
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    // MARK: - Protocols
    
    // MARK: UITableViewDataSource
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return formManager.numberOfSections()
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return formManager.numberOfRowsInSection(section)
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return formManager.cellForRowAtIndexPath(indexPath)
    }
    
    open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let formSectionTitles = formManager.formSectionTitles {
            if formSectionTitles.count > section {
                return formSectionTitles[section]
            }
        }
        return nil
    }
    
    // MARK: UITableViewDelegate
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let formCell = tableView.cellForRow(at: indexPath) as? FormTableViewCell {
            didSelectFormCell(formCell)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsets.zero
    }
    
    open func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return formManager.heightForRowAtIndexPath(indexPath)
    }
    
    // MARK: FormManagerDelegate {
    
    open func formManagerDidSetFormSections(_ sender: FormManager) {
        reloadTableView()
    }
    
    open func formManagerShouldReloadForm(_ sender: FormManager) {
        reloadTableView()
    }
    
    // MARK: FormTableViewCellDelegate
    
    open func formCell(_ sender: FormTableViewCell, didBecomeFirstResponder firstResponder: UIView?) {
        if let indexPath = tableView.indexPath(for: sender) {
            let cellRect = tableView.rectForRow(at: indexPath)
            
            let completelyVisible = visibleTableViewRect.contains(cellRect)
            
            if !completelyVisible {
                tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
    
    open func formCell(_ sender: FormTableViewCell, didResignFirstResponder firstResponder: UIView?) {
        
    }
    
    open func formCell(_ sender: FormTableViewCell, didChangeValue value: Any?) {
        
    }
    
    open func formCell(_ sender: FormTableViewCell, isValid: Bool, errors: [String]) {
        
    }
    
    open func formCell(_ sender: FormTableViewCell, didChangeRowHeightFrom from: CGFloat, to: CGFloat) {
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
    
    open func formCell(_ sender: FormTableViewCell, didChangeRowVisibilityAtIndexPath from: IndexPath?, to: IndexPath?) {
        if formManager.reloadTransaction {
            formManager.shouldReloadAfterTransaction = true
        } else {
            if animateRowVisibilityChanges {
                tableView.beginUpdates()
                
                // Insert
                if from == nil {
                    if let indexPath = to {
                        tableView.insertRows(at: [indexPath], with: .middle)
                    }
                }
                    
                // Remove
                else if to == nil {
                    if let indexPath = from {
                        tableView.deleteRows(at: [indexPath], with: .middle)
                    }
                }
                
                tableView.endUpdates()
            } else {
                reloadTableView()
            }
        }
    }
    
    open func formCellDidRequestNextFormTableViewCell(_ sender: FormTableViewCell) {
        if let nextFormCell = formManager.nextFormTableViewCell() {
            if let indexPath = tableView.indexPath(for: nextFormCell) {
                let cellRect = tableView.rectForRow(at: indexPath)
                
                let completelyVisible = visibleTableViewRect.contains(cellRect)
                
                let _ = nextFormCell.becomeFirstResponder()
                
                if !completelyVisible {
                    tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }
        }
    }
    
    open func formCell(_ sender: FormTableViewCell, didTouchUpInsideButton button: UIButton) {
        
    }
    
    open func formCellShouldResignFirstResponder(_ sender: FormTableViewCell) -> Bool {
        return formManager.shouldResignFirstResponder
    }
    
    open func formCell(_ sender: FormTableViewCell, shouldValidateWithIdentifier validationIdentifier: String?) -> Bool {
        return true
    }
    
    open func formCell(_ sender: FormTextFieldTableViewCell, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    // MARK: FormSelectionTableViewControllerDelegate
    
    open func formSelectionTableViewController(_ sender: FormSelectionTableViewController, didSelectObjects objects: [Any], withFormTableViewCellIdentifier identifier: String?) {
        if let identifier = identifier, let formCell = formManager.formCellWithIdentifier(identifier) {
            formCell.value = objects as Any
        }
    }
    
    open func formSelectionTableViewController(_ sender: FormSelectionTableViewController,  tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: IndexPath) {
        
    }
}
