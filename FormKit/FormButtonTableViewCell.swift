//
//  FormButtonTableViewCell.swift
//  FormKit
//
//  Created by Michael Loistl on 14/11/2015.
//  Copyright © 2015 Aplo. All rights reserved.
//

import Foundation
import UIKit

open class FormButtonTableViewCell: FormTableViewCell {
    
    open lazy var button: UIButton = {
        let _button = UIButton(forAutoLayout: ())
        _button.addTarget(self, action: #selector(buttonTouchedUpInside(_:)), for: .touchUpInside)
        _button.setTitleColor(UIColor.black, for: UIControlState())
        
        return _button
    }()
    
    lazy var buttonTopConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.button, attribute: .top, relatedBy: .equal, toItem: self.contentView, attribute: .top, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()
    
    lazy var buttonLeftConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.button, attribute: .left, relatedBy: .equal, toItem: self.contentView, attribute: .left, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()
    
    lazy var buttonBottomConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.button, attribute: .bottom, relatedBy: .equal, toItem: self.contentView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()
    
    lazy var buttonRightConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.button, attribute: .right, relatedBy: .equal, toItem: self.contentView, attribute: .right, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()
    
    // MARK: Initializers
    
    required public init(labelText: String?, identifier: String? = nil, configurations: [FormCellConfiguration]? = nil, delegate: FormTableViewCellDelegate?) {
        super.init(labelText: labelText, identifier: identifier, configurations: configurations, delegate: delegate)
        
        valueTextView.isHidden = true
        selectionStyle = .none
        
        contentView.addSubview(button)
        
        contentView.addConstraints([buttonTopConstraint, buttonLeftConstraint, buttonBottomConstraint, buttonRightConstraint])
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Super
    
    open override func updateConstraints() {
        
        buttonTopConstraint.constant = buttonInsets.top
        buttonLeftConstraint.constant = buttonInsets.left
        buttonBottomConstraint.constant = -buttonInsets.bottom
        buttonRightConstraint.constant = -buttonInsets.right
        
        super.updateConstraints()
    }
    
    // MARK: - Methods
    
    override open func valueView() -> UIView {
        return button
    }
    
    // MARK: Actions
    
    func buttonTouchedUpInside(_ sender: UIButton) {
        delegate?.formCell?(self, didTouchUpInsideButton: sender)
        
        if let action = action {
            action(self, value)
        }
    }
}
