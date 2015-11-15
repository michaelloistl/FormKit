//
//  FormSelectionTableViewCell.swift
//  FormKit
//
//  Created by Michael Loistl on 14/11/2015.
//  Copyright © 2015 Aplo. All rights reserved.
//

import Foundation
import UIKit

public class FormSelectionTableViewCell: FormTableViewCell {
    
    public var allowsMultipleSelection = false
    
    public var selectionTitle: String?
    public var selectionValues = [String]()
    
    public var selectionViewControllerClass: UIViewController.Type?
    
    // MARK: - Initializers
    
    required public init(identifier: String, dataSource: FormTableViewCellDataSource!, delegate: FormTableViewCellDelegate!, configuration: FormTableViewCellConfiguration = FormTableViewCellConfiguration.defaultConfiguration()) {
        super.init(identifier: identifier, dataSource: dataSource, delegate: delegate, configuration: configuration)
        
        accessoryType = .DisclosureIndicator
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Super
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        accessoryType = (isEditable) ? .DisclosureIndicator : .None
    }
}