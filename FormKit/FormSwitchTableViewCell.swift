//
//  FormSwitchTableViewCell.swift
//  FormKit
//
//  Created by Michael Loistl on 14/11/2015.
//  Copyright © 2015 Aplo. All rights reserved.
//

import Foundation
import UIKit

public class FormSwitchTableViewCell: FormTableViewCell {
    
    public lazy var switchView: UISwitch = {
        let _switchView = UISwitch()
        _switchView.addTarget(self, action: Selector("switchDidChangeValue:"), forControlEvents: .ValueChanged)
        
        return _switchView
    }()
    
    // MARK: Initializers
    
    required public init(identifier: String, dataSource: FormTableViewCellDataSource!, delegate: FormTableViewCellDelegate!, configuration: FormTableViewCellConfiguration = FormTableViewCellConfiguration.defaultConfiguration()) {
        super.init(identifier: identifier, dataSource: dataSource, delegate: delegate, configuration: configuration)
        
        selectionStyle = .None
        
        contentView.addSubview(switchView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Super
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let valueEdgeInsets = dataSource?.valueEdgeInsetsForFormCell(self, identifier: identifier) ?? UIEdgeInsetsZero
        
        // Switch
        switchView.sizeToFit()
        let switchOriginX: CGFloat = CGRectGetWidth(bounds) - CGRectGetWidth(switchView.bounds) - valueEdgeInsets.right
        let switchOriginY: CGFloat = (CGRectGetHeight(bounds) - CGRectGetHeight(switchView.bounds)) / 2.0
        let switchSizeWidth: CGFloat = CGRectGetWidth(switchView.bounds)
        let switchSizeHeight: CGFloat = CGRectGetHeight(switchView.bounds)
        
        switchView.frame = CGRectMake(switchOriginX, switchOriginY, switchSizeWidth, switchSizeHeight)
    }
    
    // MARK: Functions
    
    func switchDidChangeValue(sender: UISwitch) {
        value = sender.on
    }
    
    // MARK: FormTableViewCellProtocol
    
    override func updateUI() {
        switchView.on = value as? Bool ?? false
    }
    
    override func isEmpty() -> Bool {
        return false
    }
}