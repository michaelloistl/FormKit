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
        _textField.returnKeyType = .Next
        
        return _textField
    }()
    
    // MARK: - Initializers
    
    required public init(identifier: String, dataSource: FormTableViewCellDataSource!, delegate: FormTableViewCellDelegate!) {
        super.init(identifier: identifier, dataSource: dataSource, delegate: delegate)
        
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
        
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let valueEdgeInsets = dataSource?.valueEdgeInsetsForFormCell(self, identifier: identifier) ?? UIEdgeInsetsZero
        
        // TextField
        let textFieldOriginX: CGFloat = valueEdgeInsets.left
        let textFieldOriginY: CGFloat = valueEdgeInsets.top
        let textFieldSizeWidth: CGFloat = CGRectGetWidth(bounds) - valueEdgeInsets.left - valueEdgeInsets.right
        let textFieldSizeHeight: CGFloat = CGRectGetHeight(bounds) - valueEdgeInsets.top - valueEdgeInsets.bottom
        
        textField.frame = CGRectMake(textFieldOriginX, textFieldOriginY, textFieldSizeWidth, textFieldSizeHeight)
        textField.userInteractionEnabled = isEditable
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
