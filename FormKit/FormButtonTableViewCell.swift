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
        let _button = UIButton(forAutoLayout: ())
        _button.addTarget(self, action: #selector(buttonTouchedUpInside(_:)), forControlEvents: .TouchUpInside)
        _button.setTitleColor(UIColor.blackColor(), forState: .Normal)
        
        return _button
    }()
    
    lazy var buttonTopConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.button, attribute: .Top, relatedBy: .Equal, toItem: self.contentView, attribute: .Top, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()
    
    lazy var buttonLeftConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.button, attribute: .Left, relatedBy: .Equal, toItem: self.contentView, attribute: .Left, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()
    
    lazy var buttonBottomConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.button, attribute: .Bottom, relatedBy: .Equal, toItem: self.contentView, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()
    
    lazy var buttonRightConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.button, attribute: .Right, relatedBy: .Equal, toItem: self.contentView, attribute: .Right, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()
    
    // MARK: Initializers
    
    required public init(labelText: String?, identifier: String? = nil, configurations: [FormCellConfiguration]? = nil, delegate: FormTableViewCellDelegate?) {
        super.init(labelText: labelText, identifier: identifier, configurations: configurations, delegate: delegate)
        
        valueTextView.hidden = true
        selectionStyle = .None
        
        contentView.addSubview(button)
        
        contentView.addConstraints([buttonTopConstraint, buttonLeftConstraint, buttonBottomConstraint, buttonRightConstraint])
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Super
    
    public override func updateConstraints() {
        
        buttonTopConstraint.constant = buttonInsets.top
        buttonLeftConstraint.constant = buttonInsets.left
        buttonBottomConstraint.constant = -buttonInsets.bottom
        buttonRightConstraint.constant = -buttonInsets.right
        
        super.updateConstraints()
    }
    
    // MARK: - Methods
    
    override public func valueView() -> UIView {
        return button
    }
    
    // MARK: Actions
    
    func buttonTouchedUpInside(sender: UIButton) {
        delegate?.formCell?(self, didTouchUpInsideButton: sender)
        
        if let action = action {
            action(cell: self, value: value)
        }
    }
}