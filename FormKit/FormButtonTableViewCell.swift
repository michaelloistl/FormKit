//
//  FormButtonTableViewCell.swift
//  FormKit
//
//  Created by Michael Loistl on 14/11/2015.
//  Copyright © 2015 Aplo. All rights reserved.
//

import Foundation
import UIKit

public class FormButtonTableViewCell: FormTableViewCell {
    
    public lazy var button: UIButton = {
        let _button = UIButton()
        _button.addTarget(self, action: Selector("buttonTouchedUpInside:"), forControlEvents: .TouchUpInside)
        _button.setTitleColor(UIColor.blackColor(), forState: .Normal)
        
        return _button
    }()
    
    
    // MARK: Initializers
    
    required public init(identifier: String, dataSource: FormTableViewCellDataSource!, delegate: FormTableViewCellDelegate!, configuration: FormTableViewCellConfiguration = FormTableViewCellConfiguration.defaultConfiguration()) {
        super.init(identifier: identifier, dataSource: dataSource, delegate: delegate, configuration: configuration)
        
        valueTextView.hidden = true
        
        contentView.addSubview(button)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Super
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let buttonEdgeInsets = dataSource?.buttonEdgeInsetsForFormCell(self, identifier: identifier) ?? UIEdgeInsetsZero
        
        // button
        let originX: CGFloat = buttonEdgeInsets.left
        let originY: CGFloat = buttonEdgeInsets.top
        let sizeWidth: CGFloat = CGRectGetWidth(bounds) - buttonEdgeInsets.left - buttonEdgeInsets.left
        let sizeHeight: CGFloat = CGRectGetHeight(bounds) - buttonEdgeInsets.top - buttonEdgeInsets.bottom
        
        button.frame = CGRectMake(originX, originY, sizeWidth, sizeHeight)
    }
    
    // MARK: - Methods
    
    override func configValue() {
        super.configValue()
        
        if let config = dataSource?.buttonConfigurationForFormCell(self, identifier: identifier) {
            for (key, value) in config {
                if button.respondsToSelector(Selector(key)) {
                    button.setValue(value, forKey: key)
                }
            }
        }
    }
    
    // MARK: Actions
    
    func buttonTouchedUpInside(sender: UIButton) {
        delegate?.formCell(self, identifier: identifier, didTouchUpInsideButton: sender)
    }
}