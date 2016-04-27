//
//  FormManager.swift
//  FormKit
//
//  Created by Michael Loistl on 20/02/2015.
//  Copyright (c) 2015 MIchael LOistl. All rights reserved.
//

import Foundation
import UIKit

public protocol FormManagerDelegate {
    func formManagerDidSetFormSections(sender: FormManager)
    func formManagerShouldReloadForm(sender: FormManager)
}

public class FormManager: NSObject {
    
    public var delegate: FormManagerDelegate?
    
    public var formSectionTitles: [String]?
    
    public var formSections: [[FormTableViewCell]]? {
        didSet {
            setupAllFormCells()
            
            updateVisibleFormSections()

            delegate?.formManagerDidSetFormSections(self)
            
            setAllFormCellValues()
        }
    }
    
    public var visibleFormSections = [[FormTableViewCell]]()
    
    public var shouldResignFirstResponder = true
    
    public var shouldReloadAfterTransaction: Bool = false
    
    public var reloadTransaction: Bool = false {
        didSet {
            if reloadTransaction {
                shouldReloadAfterTransaction = false
            } else {
                if shouldReloadAfterTransaction {
                    shouldReloadAfterTransaction = false
                    delegate?.formManagerShouldReloadForm(self)
                }
            }
        }
    }
    
    // MARK: - Initializers
    
    // MARK: - Methods
    
    private func beginReloadTransaction() {
        reloadTransaction = true
    }
    
    private func endReloadTransaction() {
        reloadTransaction = false
    }
    
    public func allFormCells() -> [FormTableViewCell] {
        var allFormCells = [FormTableViewCell]()
        if let formSections = formSections {
            for section in formSections {
                allFormCells += section
            }
        }
        return allFormCells
    }
    
    public func allVisibleFormCells() -> [FormTableViewCell] {
        var allVisibleFormCells = [FormTableViewCell]()
        for section in visibleFormSections {
            allVisibleFormCells += section
        }
        return allVisibleFormCells
    }
    
    public func indexPathForCell(cell: FormTableViewCell) -> NSIndexPath? {
        for (index, section) in visibleFormSections.enumerate() {
            if let row = section.indexOf(cell) {
                return NSIndexPath(forRow: row, inSection: index)
            }
        }
        return nil
    }
    
    public func section(section: Int) -> AnyObject? {
        return visibleFormSections[section]
    }
    
    public func setupAllFormCells() {
        for formCell in allFormCells() {
            formCell.formManager = self
        }
    }
    
    public func setAllFormCellValues() {
        beginReloadTransaction()
        
        for formCell in allVisibleFormCells() {
            formCell.setValue()
        }
        
        endReloadTransaction()
    }
    
    public func writeAllFormCellValues() {
        for formCell in allFormCells() {
            formCell.writeObjectValue()
        }
    }
    
    public func writeAllVisibleFormCellValues() {
        for formCell in allVisibleFormCells() {
            formCell.writeObjectValue()
        }
    }
    
    public func updateVisibleFormSections() {
        var visibleFormSections = [[FormTableViewCell]]()
        if let formSections = formSections {
            for section in formSections {
                var formCells = [FormTableViewCell]()
                for formCell in section {
                    if formCell.visible {
                        formCells.append(formCell)
                    }
                }
                visibleFormSections.append(formCells)
            }
        }
        self.visibleFormSections = visibleFormSections
    }
    
    public func formIsValid(showErrorState: Bool = true) -> Bool {
        var isValid = true
        for formCell in allVisibleFormCells() {
            if formCell.isValid(showErrorState) == false {
                isValid = false
            }
        }
        return isValid
    }
    
    public func formCellWithIdentifier(identifier: String) -> FormTableViewCell? {
        for cell in allVisibleFormCells() {
            if cell.identifier == identifier {
                return cell
            }
        }
        return nil
    }
    
    public func formResignFirstResponder() {
        for cell in allVisibleFormCells() {
            cell.resignFirstResponder()
        }
    }
    
    public func setErrorState(errorState: Bool) {
        for formCell in allVisibleFormCells() {
            formCell.errorState = errorState
        }
    }
    
    public func nextFormTableViewCell() -> FormTableViewCell? {
        let allFormCells = self.allVisibleFormCells()
        var firstResponderCell: FormTableViewCell?
        for cell in allFormCells {
            if cell.isFirstResponder() {
                firstResponderCell = cell
                break
            }
        }
        
        if let firstResponderCell = firstResponderCell {
            if allFormCells.count > 1 {
                if let index = allFormCells.indexOf(firstResponderCell) {
                    var canBeFirstResponder = false
                    
                    var nextIndex = index
                    while !canBeFirstResponder {
                        nextIndex += 1
                        
                        if nextIndex > (allFormCells.count - 1) {
                            nextIndex = 0
                        }

                        let cell = allFormCells[nextIndex]
                        if cell.becomeFirstResponder() {
                            canBeFirstResponder = true
                        }
                    }
                    
                    return allFormCells[nextIndex]
                }
            }
        }

        return nil
    }
    
    // MARK: - Protocols
    
    // MARK: UITableViewDataSource
    
    public func numberOfSections() -> Int {
        return visibleFormSections.count
    }
    
    public func numberOfRowsInSection(section: Int) -> Int {
        return visibleFormSections[section].count
    }
    
    public func cellForRowAtIndexPath(indexPath: NSIndexPath) -> FormTableViewCell {
        let section = visibleFormSections[indexPath.section]
        let formCell = section[indexPath.row]
        return formCell
    }
    
    // MARK: UITableViewDelegate
    
    public func heightForRowAtIndexPath(indexPath: NSIndexPath) -> CGFloat {
        let formCell = cellForRowAtIndexPath(indexPath)
        return formCell.rowHeight() ?? 44.0
    }
}
