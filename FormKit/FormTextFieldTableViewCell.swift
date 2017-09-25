//
//  FormTextFieldTableViewCell.swift
//  FormKit
//
//  Created by Michael Loistl on 14/11/2015.
//  Copyright © 2015 Aplo. All rights reserved.
//

import Foundation

open class FormTextFieldTableViewCell: FormTextInputTableViewCell, UITextFieldDelegate, FormTextFieldDataSource {
    
    open var returnKeyAction: FormCellActionClosure?
    
    open lazy var textField: FormTextField = {
        let _textField = FormTextField(forAutoLayout: ())
        _textField.delegate = self
        _textField.dataSource = self
        _textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        _textField.backgroundColor = .clear
        _textField.returnKeyType = .next
        
        return _textField
    }()
    
    lazy var textFieldTopConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.textField, attribute: .top, relatedBy: .equal, toItem: self.contentView, attribute: .top, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()
    
    lazy var textFieldLeftConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.textField, attribute: .left, relatedBy: .equal, toItem: self.contentView, attribute: .left, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()
    
    lazy var textFieldBottomConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.textField, attribute: .bottom, relatedBy: .equal, toItem: self.contentView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        _constraint.priority = 750
        
        return _constraint
    }()
    
    lazy var textFieldRightConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.textField, attribute: .right, relatedBy: .equal, toItem: self.contentView, attribute: .right, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()
    
    // MARK: - Initializers
    
    required public init(labelText: String?, identifier: String? = nil, configurations: [FormCellConfiguration]? = nil, delegate: FormTableViewCellDelegate?) {
        super.init(labelText: labelText, identifier: identifier, configurations: configurations, delegate: delegate)
        
        contentView.insertSubview(textField, at: 0)
        
        contentView.addConstraints([textFieldTopConstraint, textFieldLeftConstraint, textFieldBottomConstraint, textFieldRightConstraint])
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Super
    
    override open var isFirstResponder : Bool {
        return textField.isFirstResponder
    }
    
    @discardableResult
    override open func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
    
    @discardableResult
    override open func resignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }
    
    open override func updateConstraints() {
        
        textFieldTopConstraint.constant = valueViewInsets.top
        textFieldLeftConstraint.constant = valueViewInsets.left
        textFieldBottomConstraint.constant = -valueViewInsets.bottom
        textFieldRightConstraint.constant = -valueViewInsets.right
        
        super.updateConstraints()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()

        textField.isUserInteractionEnabled = editable
    }
    
    // MARK: - Methods
    
    override open func valueView() -> UIView {
        return textField
    }
    
    override open func updateUI() {
        textField.text = value as? String
    }
    
    override open func isEmpty() -> Bool {
        if let textFieldText = textField.text {
            return textFieldText.characters.count == 0
        }
        return true
    }
    
    // MARK: - Protocols
    
    // MARK: UITextFieldDelegate
    
    open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .next {
            nextFormTableViewCell()
        } else {
            returnKeyAction?(self, value)
        }
        
        return true
    }
    
    open func textFieldDidChange(_ textField: UITextField) {
        value = textField.text as Any?
        updateCharacterLabelWithCharacterCount(textField.text?.characters.count ?? 0)
    }
    
    open func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return editable
    }
    
    open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return delegate?.formCell?(self, shouldChangeCharactersInRange: range, replacementString: string) ?? true
    }
    
    open func textFieldDidBeginEditing(_ textField: UITextField) {
        errorState = false
        delegate?.formCell?(self, didBecomeFirstResponder: textField)
    }
    
    open func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.formCell?(self, didResignFirstResponder: textField)
    }
    
    // MARK: FormTextFieldDataSource
    
    open func formTextFieldShouldResignFirstResponder(_ sender: FormTextField) -> Bool {
        return delegate?.formCellShouldResignFirstResponder?(self) ?? true
    }
}
