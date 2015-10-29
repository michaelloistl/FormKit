//
//  FormManager.swift
//  FormKit
//
//  Created by Michael Loistl on 20/02/2015.
//  Copyright (c) 2015 MIchael LOistl. All rights reserved.
//

import Foundation
import UIKit

public class FormManager: NSObject {
    
    public var formCells: Array<Array<FormTableViewCell>>? {
        didSet {
            updateVisibleFormCells()
            updateAllFormCellValues()
        }
    }
    
    var visibleFormCells: Array<Array<FormTableViewCell>>?
    
    // MARK: - Initializers
    
    
    // MARK: - Methods
    
    public func updateAllFormCellValues() {
        for formCell in allFormCells() {
            formCell.setValue()
        }
    }
    
    public func updateVisibleFormCells() {
        var sections = Array<Array<FormTableViewCell>>()
        if let formCells = formCells {
            for section in formCells {
                var cells = Array<FormTableViewCell>()
                for cell in section {
                    if cell.visible {
                        cells.append(cell)
                    }
                }
                sections.append(cells)
            }
        }
        
        visibleFormCells = sections
    }
    
    public func allFormCells() -> Array<FormTableViewCell> {
        var allFormCells = Array<FormTableViewCell>()
        if let visibleFormCells = visibleFormCells {
            for section in visibleFormCells {
                allFormCells += section
            }
        }
        return allFormCells
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
    
    public func formCellWithIdentifier(identifier: String) -> UITableViewCell? {
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
                    var nextIndex = index + 1
                    
                    if nextIndex > (allFormCells.count - 1) {
                        nextIndex = 0
                    }
                    
                    return allFormCells[nextIndex]
                }
            }
        }

        return nil
    }
    
    // MARK: - Protocols
    
    // MARK: UITableViewDataSource
    
    func numberOfSections() -> Int {
        return visibleFormCells?.count ?? 0
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        return visibleFormCells?[section].count ?? 0
    }
    
    func cellForRowAtIndexPath(indexPath: NSIndexPath) -> FormTableViewCell {
        if let sections = visibleFormCells?[indexPath.section] {
            let cell = sections[indexPath.row]
            return cell
        }
        return FormTableViewCell(identifier: "")
    }
    
    // MARK: UITableViewDelegate
    
    func heightForRowAtIndexPath(indexPath: NSIndexPath) -> CGFloat {
        let formCell = cellForRowAtIndexPath(indexPath)
        return formCell.rowHeight() ?? 44.0
    }
}
