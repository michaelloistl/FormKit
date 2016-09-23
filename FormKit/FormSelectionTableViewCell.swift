//
//  FormSelectionTableViewCell.swift
//  FormKit
//
//  Created by Michael Loistl on 14/11/2015.
//  Copyright © 2015 Aplo. All rights reserved.
//

import Foundation
import UIKit

//protocol FormSelectionProtocol {
//    var dataSourceClosure: FormSelectionTableViewCell.DataSourceClosure? { get set }
//    var selectedClosure: FormSelectionTableViewCell.SelectedClosure? { get set }
//}

public class FormSelectionTableViewCell: FormTableViewCell {

//    FormCellDataSource
    
    public typealias DataSourceClosure = () -> [[String]]
    public typealias GetSelectedClosure = () -> [NSIndexPath]
    public typealias SetSelectedClosure = ([NSIndexPath]) -> Void
    
    public var dataSourceClosure: DataSourceClosure?
    public var getSelectedClosure: GetSelectedClosure?
    public var setSelectedClosure: SetSelectedClosure?
    
    public var allowsMultipleSelection = false
    
    public var title: String?
    
    // MARK: - Initializers
    
    required public init(labelText: String?, identifier: String? = nil, configurations: [FormCellConfiguration]? = nil, delegate: FormTableViewCellDelegate?, dataSource: DataSourceClosure?, getSelected: GetSelectedClosure?, setSelected: SetSelectedClosure?) {

        self.dataSourceClosure = dataSource
        self.getSelectedClosure = getSelected
        self.setSelectedClosure = setSelected
        
        super.init(labelText: labelText, identifier: identifier, configurations: configurations, delegate: delegate)
        
        accessoryType = .DisclosureIndicator
    }

    required public init(labelText: String?, identifier: String?, configurations: [FormCellConfiguration]?, delegate: FormTableViewCellDelegate?) {
        super.init(labelText: labelText, identifier: identifier, configurations: configurations, delegate: delegate)
        
        accessoryType = .DisclosureIndicator
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}