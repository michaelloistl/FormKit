//
//  FormDatePickerTableViewCell.swift
//  FormKit
//
//  Created by Michael Loistl on 14/11/2015.
//  Copyright © 2015 Aplo. All rights reserved.
//

import Foundation
import UIKit

open class FormDatePickerTableViewCell: FormTextFieldTableViewCell {
    
    open lazy var datePicker: UIDatePicker = {
        let _datePicker = UIDatePicker()
        _datePicker.addTarget(self, action: #selector(datePickerDidChangeValue(_:)), for: .valueChanged)
        
        return _datePicker
    }()
    
    open lazy var dateFormatter: DateFormatter = {
        let _dateFormatter = DateFormatter()
        _dateFormatter.dateStyle = .medium
        _dateFormatter.timeStyle = .none
        
        return _dateFormatter
    }()
    
    // MARK: Initializers
    
    required public init(labelText: String?, identifier: String? = nil, configurations: [FormCellConfiguration]? = nil, delegate: FormTableViewCellDelegate?) {
        super.init(labelText: labelText, identifier: identifier, configurations: configurations, delegate: delegate)
        
        selectionStyle = .none
        
        textField.inputView = datePicker
        textField.tintColor = UIColor.clear
        textField.inputAccessoryView = keyboardAccessoryView
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: IBACTION Methods
    
    override open func pickerClearButtonTouchedUpInside(_ sender: UIButton) {
        value = nil
    }
    
    override open func pickerDoneButtonTouchedUpInside(_ sender: UIButton) {
        let _ = textField.resignFirstResponder()
    }
    
    // MARK: Methods
        
    func datePickerDidChangeValue(_ datePicker: UIDatePicker) {
        value = datePicker.date as AnyObject?
    }
    
    // MARK: FormTableViewCellProtocol
    
    override open func updateUI() {
        if let dateValue = value as? Date {
            datePicker.date = dateValue
            textField.text = dateFormatter.string(from: dateValue)
        } else {
            textField.text = nil
        }
    }
    
    override open func isEmpty() -> Bool {
        if let textFieldText = textField.text {
            return textFieldText.characters.count == 0
        }
        return true
    }
}
