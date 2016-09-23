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

open class FormSelectionTableViewCell: FormTableViewCell {

//    FormCellDataSource
    
    public typealias DataSourceClosure = () -> [[String]]
    public typealias GetSelectedClosure = () -> [IndexPath]
    public typealias SetSelectedClosure = ([IndexPath]) -> Void
    
    open var dataSourceClosure: DataSourceClosure?
    open var getSelectedClosure: GetSelectedClosure?
    open var setSelectedClosure: SetSelectedClosure?
    
    open var allowsMultipleSelection = false
    
    open var title: String?
    
    // MARK: - Initializers
    
    required public init(labelText: String?, identifier: String? = nil, configurations: [FormCellConfiguration]? = nil, delegate: FormTableViewCellDelegate?, dataSource: DataSourceClosure?, getSelected: GetSelectedClosure?, setSelected: SetSelectedClosure?) {

        self.dataSourceClosure = dataSource
        self.getSelectedClosure = getSelected
        self.setSelectedClosure = setSelected
        
        super.init(labelText: labelText, identifier: identifier, configurations: configurations, delegate: delegate)
        
        accessoryType = .disclosureIndicator
    }

    required public init(labelText: String?, identifier: String?, configurations: [FormCellConfiguration]?, delegate: FormTableViewCellDelegate?) {
        super.init(labelText: labelText, identifier: identifier, configurations: configurations, delegate: delegate)
        
        accessoryType = .disclosureIndicator
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
