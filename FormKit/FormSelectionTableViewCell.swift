//
//  FormSelectionTableViewCell.swift
//  FormKit
//
//  Created by Michael Loistl on 14/11/2015.
//  Copyright © 2015 Aplo. All rights reserved.
//

import Foundation
import UIKit

/**
A structure that contains closures to provide an array of selectable as well as selected objects used by `FormSelectionTableViewController`

- SeeAlso: `FormSelectionTableViewCell.selectionDataSource: FormSelectionCellDataSource?`
- SeeAlso: `FormSelectionTableViewController.selectionObjects: [FormSelectable]`
- SeeAlso: `FormSelectionTableViewController.selectedObjects: [FormSelectable]`

- Parameter selectionObjectsClosure: A closure object returning an array of objects conforming `FormSelectable` that are set as `FormSelectionTableViewController.selectionObjects`
- Parameter selectionObjectsClosure.value: The cell's value
- Parameter selectedObjectsClosure: A closure object returning an array of objects conforming `FormSelectable` that are set as `FormSelectionTableViewController.selectedObjects`
- Parameter selectedObjectsClosure.value: The cell's value

- Returns: selectionObjectsClosure: An array of selectable objects conforming to `FormSelectable`, selectedObjectsClosure: An array of selected objects conforming to `FormSelectable`
*/
public struct FormSelectionCellDataSource {
    
    public typealias SetFormCellSelectionObjectsClosure = (value: AnyObject?) -> [FormSelectable]
    public typealias SetFormCellSelectedObjectsClosure = (value: AnyObject?) -> [FormSelectable]
    
    public let selectionObjectsClosure: SetFormCellSelectionObjectsClosure
    public let selectedObjectsClosure: SetFormCellSelectedObjectsClosure
    
    // MARK: - Initializers
    
    public init(selectionObjectsClosure: SetFormCellSelectionObjectsClosure, selectedObjectsClosure: SetFormCellSelectedObjectsClosure) {
        self.selectionObjectsClosure = selectionObjectsClosure
        self.selectedObjectsClosure = selectedObjectsClosure
    }
    
    /**
    Helper method to convert `value: AnyObject?` into array conforming to **FormSelectable**
     
     - Parameter value: optional AnyObject
     
     - Returns: Array<FormSelectable>
    */
    public static func selectableObjectsFromValue(value: AnyObject?) -> [FormSelectable] {
        var selectedObjects = [FormSelectable]()
        
        if let valueArray = value as? [AnyObject] {
            for value in valueArray {
                if let value = value as? FormSelectable {
                    selectedObjects.append(value)
                }
            }
        }
        
        return selectedObjects
    }
}

public class FormSelectionTableViewCell: FormTableViewCell {

    public var selectionDataSource: FormSelectionCellDataSource!
    
    public var allowsMultipleSelection = false
    
    public var selectionTitle: String?
    
    public var selectionViewControllerClass: UIViewController.Type?
    
    // MARK: - Initializers
    
    required public init(identifier: String, delegate: FormTableViewCellDelegate!, selectionObjectsClosure: FormSelectionCellDataSource.SetFormCellSelectionObjectsClosure, selectedObjectsClosure: FormSelectionCellDataSource.SetFormCellSelectedObjectsClosure) {

        self.selectionDataSource = FormSelectionCellDataSource(selectionObjectsClosure: selectionObjectsClosure, selectedObjectsClosure: selectedObjectsClosure)
        
        super.init(identifier: identifier, delegate: delegate)
        
        accessoryType = .DisclosureIndicator
    }

    required public init(identifier: String, delegate: FormTableViewCellDelegate!) {
        super.init(identifier: identifier, delegate: delegate)
        
        accessoryType = .DisclosureIndicator
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}