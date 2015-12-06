//
//  FormManager.swift
//  FormKit
//
//  Created by Michael Loistl on 20/02/2015.
//  Copyright (c) 2015 MIchael LOistl. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

public protocol FormManagerDelegate {
    func formManagerDidSetFormSections(sender: FormManager)
}

public class FormManager: NSObject {
    
    public var delegate: FormManagerDelegate?
    
    public var formSections: [AnyObject]? {
        didSet {
            updateVisibleFormSections()

            delegate?.formManagerDidSetFormSections(self)
            
            updateAllFormCellValues()
        }
    }
    
    var visibleFormSections: [AnyObject]?
    
    // MARK: - Initializers
    
    
    // MARK: - Methods
    
    public func allFormCells() -> [FormTableViewCell] {
        var allFormCells = [FormTableViewCell]()
        if let visibleFormSections = visibleFormSections {
            for section in visibleFormSections {
                if let formCellArray = section as? [FormTableViewCell] {
                    allFormCells += formCellArray
                }
            }
        }
        return allFormCells
    }
    
    public func indexPathForCell(cell: FormTableViewCell) -> NSIndexPath? {
        if let visibleFormSections = visibleFormSections {
            for (index, section) in visibleFormSections.enumerate() {
                if let formCellArray = section as? [FormTableViewCell] {
                    if let row = formCellArray.indexOf(cell) {
                        return NSIndexPath(forRow: row, inSection: index)
                    }
                }
            }
        }
        return nil
    }
    
    public func section(section: Int) -> AnyObject? {
        return visibleFormSections?[section]
    }
    
    public func updateAllFormCellValues() {
        for formCell in allFormCells() {
            formCell.setValue()
        }
    }
    
    public func updateVisibleFormSections() {
        var visibleFormSections = [AnyObject]()
        if let formSections = formSections {
            for section in formSections {
                if let formCellSection = section as? [FormTableViewCell] {
                    var formCells = [FormTableViewCell]()
                    for formCell in formCellSection {
                        if formCell.visible {
                            formCells.append(formCell)
                        }
                    }
                    visibleFormSections.append(formCells)
                } else if let resultsSection = section as? Results {
                    visibleFormSections.append(resultsSection)
                }
            }
        }
        
        self.visibleFormSections = visibleFormSections
    }
    
    public func formIsValid(showErrorState: Bool = true) -> Bool {
        var isValid = true
        for formCell in allFormCells() {
            if formCell.isValid(showErrorState) == false {
                isValid = false
            }
        }
        return isValid
    }
    
    public func formCellWithIdentifier(identifier: String) -> FormTableViewCell? {
        for cell in allFormCells() {
            if cell.identifier == identifier {
                return cell
            }
        }
        return nil
    }
    
    public func formResignFirstResponder() {
        for cell in allFormCells() {
            cell.resignFirstResponder()
        }
    }
    
    public func setErrorState(errorState: Bool) {
        for formCell in allFormCells() {
            formCell.errorState = errorState
        }
    }
    
    public func nextFormTableViewCell() -> FormTableViewCell? {
        let allFormCells = self.allFormCells()
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
                        nextIndex++
                        
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
        return visibleFormSections?.count ?? 0
    }
    
    public func numberOfRowsInSection(section: Int) -> Int {
        if let formCellSection = visibleFormSections?[section] as? [FormTableViewCell] {
            return formCellSection.count
        } else if let resultsSection = visibleFormSections?[section] as? Results {
            return resultsSection.count
        }
        
        return 0
    }
    
    public func cellForRowAtIndexPath(indexPath: NSIndexPath) -> FormTableViewCell? {
        if let formCellSection = visibleFormSections?[indexPath.section] as? [FormTableViewCell] {
            let formCell = formCellSection[indexPath.row]
            return formCell
        }
        return nil
    }
    
    // MARK: UITableViewDelegate
    
    public func heightForRowAtIndexPath(indexPath: NSIndexPath) -> CGFloat? {
        if let formCell = cellForRowAtIndexPath(indexPath) {
            return formCell.rowHeight() ?? 44.0
        }
        return nil
    }
}
