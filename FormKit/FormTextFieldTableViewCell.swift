//
//  FormTextFieldTableViewCell.swift
//  FormKit
//
//  Created by Michael Loistl on 14/11/2015.
//  Copyright © 2015 Aplo. All rights reserved.
//

import Foundation
import UIKit

public class FormTextFieldTableViewCell: FormTextInputTableViewCell, UITextFieldDelegate, FormTextFieldDataSource {
    
    public var returnKeyAction: FormCellAction?
    
    public lazy var textField: FormTextField = {
        let _textField = FormTextField(forAutoLayout: ())
        _textField.delegate = self
        _textField.dataSource = self
        _textField.addTarget(self, action: Selector("textFieldDidChange:"), forControlEvents: .EditingChanged)
        _textField.backgroundColor = UIColor.clearColor()
        _textField.returnKeyType = .Next
        
        return _textField
    }()
    
    lazy var textFieldTopConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.textField, attribute: .Top, relatedBy: .Equal, toItem: self.contentView, attribute: .Top, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()
    
    lazy var textFieldLeftConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.textField, attribute: .Left, relatedBy: .Equal, toItem: self.contentView, attribute: .Left, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()
    
    lazy var textFieldBottomConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.textField, attribute: .Bottom, relatedBy: .Equal, toItem: self.contentView, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        _constraint.priority = 750
        
        return _constraint
    }()
    
    lazy var textFieldRightConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.textField, attribute: .Right, relatedBy: .Equal, toItem: self.contentView, attribute: .Right, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()
    
    // MARK: - Initializers
    
    required public init(identifier: String, delegate: FormTableViewCellDelegate!) {
        super.init(identifier: identifier, delegate: delegate)
        
        contentView.insertSubview(textField, atIndex: 0)
        
        contentView.addConstraints([textFieldTopConstraint, textFieldLeftConstraint, textFieldBottomConstraint, textFieldRightConstraint])
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Super
    
    override public func isFirstResponder() -> Bool {
        return textField.isFirstResponder()
    }
    
    override public func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
    
    override public func resignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }
    
    public override func updateConstraints() {
        
        textFieldTopConstraint.constant = valueViewInsets.top
        textFieldLeftConstraint.constant = valueViewInsets.left
        textFieldBottomConstraint.constant = -valueViewInsets.bottom
        textFieldRightConstraint.constant = -valueViewInsets.right
        
        super.updateConstraints()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()

        textField.userInteractionEnabled = editable
    }
    
    // MARK: - Methods
    
    override public func valueView() -> UIView {
        return textField
    }
    
    override public func updateUI() {
        textField.text = value as? String
    }
    
    override public func isEmpty() -> Bool {
        if let textFieldText = textField.text {
            return textFieldText.characters.count == 0
        }
        return true
    }
    
    // MARK: - Protocols
    
    // MARK: UITextFieldDelegate
    
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.returnKeyType == .Next {
            nextFormTableViewCell()
        } else {
            returnKeyAction?.closure(value: value)
        }
        
        return true
    }
    
    public func textFieldDidChange(textField: UITextField) {
        value = textField.text
        updateCharacterLabelWithCharacterCount(textField.text?.characters.count ?? 0)
    }
    
    public func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return editable
    }
    
    public func textFieldDidBeginEditing(textField: UITextField) {
        errorState = false
        delegate?.formCell?(self, identifier: identifier, didBecomeFirstResponder: textField)
    }
    
    public func textFieldDidEndEditing(textField: UITextField) {
        delegate?.formCell?(self, identifier: identifier, didResignFirstResponder: textField)
    }
    
    // MARK: FormTextFieldDataSource
    
    public func formTextFieldShouldResignFirstResponder(sender: FormTextField) -> Bool {
        return delegate?.formCellShouldResignFirstResponder?(self) ?? true
    }
}
