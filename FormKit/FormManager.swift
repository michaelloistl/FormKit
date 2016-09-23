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
    func formManagerDidSetFormSections(_ sender: FormManager)
    func formManagerShouldReloadForm(_ sender: FormManager)
}

open class FormManager: NSObject {
    
    open var delegate: FormManagerDelegate?
    
    open var formSectionTitles: [String]?
    
    open var formSections: [[FormTableViewCell]]? {
        didSet {
            setupAllFormCells()
            
            updateVisibleFormSections()

            delegate?.formManagerDidSetFormSections(self)
            
            setAllFormCellValues()
        }
    }
    
    open var visibleFormSections = [[FormTableViewCell]]()
    
    open var shouldResignFirstResponder = true
    
    open var shouldReloadAfterTransaction: Bool = false
    
    open var reloadTransaction: Bool = false {
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
    
    open var firstResponderCell: FormTableViewCell? {
        var firstResponderCell: FormTableViewCell?
        
        for cell in allFormCells() {
            if cell.isFirstResponder {
                firstResponderCell = cell
                break
            }
        }
        
        return firstResponderCell
    }
    
    // MARK: - Initializers
    
    // MARK: - Methods
    
    fileprivate func beginReloadTransaction() {
        reloadTransaction = true
    }
    
    fileprivate func endReloadTransaction() {
        reloadTransaction = false
    }
    
    open func allFormCells() -> [FormTableViewCell] {
        var allFormCells = [FormTableViewCell]()
        if let formSections = formSections {
            for section in formSections {
                allFormCells += section
            }
        }
        return allFormCells
    }
    
    open func allVisibleFormCells() -> [FormTableViewCell] {
        var allVisibleFormCells = [FormTableViewCell]()
        for section in visibleFormSections {
            allVisibleFormCells += section
        }
        return allVisibleFormCells
    }
    
    open func indexPathForCell(_ cell: FormTableViewCell) -> IndexPath? {
        for (index, section) in visibleFormSections.enumerated() {
            if let row = section.index(of: cell) {
                return IndexPath(row: row, section: index)
            }
        }
        return nil
    }
    
    open func section(_ section: Int) -> AnyObject? {
        return visibleFormSections[section] as AnyObject?
    }
    
    open func setupAllFormCells() {
        for formCell in allFormCells() {
            formCell.formManager = self
        }
    }
    
    open func setAllFormCellValues() {
        beginReloadTransaction()
        
        for formCell in allVisibleFormCells() {
            formCell.setValue()
        }
        
        endReloadTransaction()
    }
    
    open func writeAllFormCellValues() {
        for formCell in allFormCells() {
            formCell.writeObjectValue()
        }
    }
    
    open func writeAllVisibleFormCellValues() {
        for formCell in allVisibleFormCells() {
            formCell.writeObjectValue()
        }
    }
    
    open func updateVisibleFormSections() {
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
    
    open func formIsValid(_ showErrorState: Bool = true) -> Bool {
        var isValid = true
        for formCell in allVisibleFormCells() {
            if formCell.isValid(showErrorState) == false {
                isValid = false
            }
        }
        return isValid
    }
    
    open func formCellWithIdentifier(_ identifier: String) -> FormTableViewCell? {
        for cell in allVisibleFormCells() {
            if cell.identifier == identifier {
                return cell
            }
        }
        return nil
    }
    
    open func formResignFirstResponder() {
        for cell in allVisibleFormCells() {
            cell.resignFirstResponder()
        }
    }
    
    open func setErrorState(_ errorState: Bool) {
        for formCell in allVisibleFormCells() {
            formCell.errorState = errorState
        }
    }
    
    open func nextFormTableViewCell() -> FormTableViewCell? {
        let allFormCells = self.allVisibleFormCells()
        var firstResponderCell: FormTableViewCell?
        for cell in allFormCells {
            if cell.isFirstResponder {
                firstResponderCell = cell
                break
            }
        }
        
        if let firstResponderCell = firstResponderCell {
            if allFormCells.count > 1 {
                if let index = allFormCells.index(of: firstResponderCell) {
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
    
    open func numberOfSections() -> Int {
        return visibleFormSections.count
    }
    
    open func numberOfRowsInSection(_ section: Int) -> Int {
        return visibleFormSections[section].count
    }
    
    open func cellForRowAtIndexPath(_ indexPath: IndexPath) -> FormTableViewCell {
        let section = visibleFormSections[(indexPath as NSIndexPath).section]
        let formCell = section[(indexPath as NSIndexPath).row]
        return formCell
    }
    
    // MARK: UITableViewDelegate
    
    open func heightForRowAtIndexPath(_ indexPath: IndexPath) -> CGFloat {
        let formCell = cellForRowAtIndexPath(indexPath)
        return formCell.rowHeight() ?? 44.0
    }
}
