//
//  FormTextFieldTableViewCell.swift
//  FormKit
//
//  Created by Michael Loistl on 14/11/2015.
//  Copyright © 2015 Aplo. All rights reserved.
//

import Foundation
import UIKit

public class FormTextFieldTableViewCell: FormTextInputTableViewCell, UITextFieldDelegate {
    
    public lazy var textField: UITextField = {
        let _textField = UITextField()
        _textField.delegate = self
        _textField.addTarget(self, action: Selector("textFieldDidChange:"), forControlEvents: .EditingChanged)
        _textField.backgroundColor = UIColor.clearColor()
        
        return _textField
    }()
    
    // MARK: - Initializers
    
    required public init(identifier: String, dataSource: FormTableViewCellDataSource!, delegate: FormTableViewCellDelegate!, configuration: FormTableViewCellConfiguration = FormTableViewCellConfiguration.defaultConfiguration()) {
        super.init(identifier: identifier, dataSource: dataSource, delegate: delegate, configuration: configuration)
        
        contentView.insertSubview(textField, atIndex: 0)
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
    
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        becomeFirstResponder()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let valueEdgeInsets = dataSource?.valueEdgeInsetsForFormCell(self, identifier: identifier) ?? UIEdgeInsetsZero
        
        // TextField
        let textFieldOriginX: CGFloat = valueEdgeInsets.left
        let textFieldOriginY: CGFloat = valueEdgeInsets.top
        let textFieldSizeWidth: CGFloat = CGRectGetWidth(bounds) - valueEdgeInsets.left - valueEdgeInsets.right
        let textFieldSizeHeight: CGFloat = CGRectGetHeight(bounds) - valueEdgeInsets.top - valueEdgeInsets.bottom
        
        textField.frame = CGRectMake(textFieldOriginX, textFieldOriginY, textFieldSizeWidth, textFieldSizeHeight)
        
    }
    
    // MARK: - Methods
    
    override func configValue() {
        super.configValue()
        
        textField.textColor = (isEditable) ? UIColor.blackColor() : UIColor.grayColor()
        
        if let config = dataSource?.valueConfigurationForFormCell(self, identifier: identifier) {
            for (key, value) in config {
                if textField.respondsToSelector(Selector(key)) {
                    textField.setValue(value, forKey: key)
                }
            }
        }
    }
    
    override func updateUI() {
        textField.text = value as? String
    }
    
    override func isEmpty() -> Bool {
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
        }
        
        return true
    }
    
    public func textFieldDidChange(textField: UITextField) {
        value = textField.text
        updateCharacterLabelWithCharacterCount(textField.text?.characters.count ?? 0)
    }
    
    public func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return isEditable
    }
    
    public func textFieldDidBeginEditing(textField: UITextField) {
        errorState = false
        delegate?.formCell(self, identifier: identifier, didBecomeFirstResponder: textField)
    }
    
    public func textFieldDidEndEditing(textField: UITextField) {
        
    }
}