//
//  FormDatePickerTableViewCell.swift
//  FormKit
//
//  Created by Michael Loistl on 14/11/2015.
//  Copyright © 2015 Aplo. All rights reserved.
//

import Foundation
import UIKit

public class FormDatePickerTableViewCell: FormTextFieldTableViewCell {
    
    public lazy var datePicker: UIDatePicker = {
        let _datePicker = UIDatePicker()
        _datePicker.addTarget(self, action: #selector(datePickerDidChangeValue(_:)), forControlEvents: .ValueChanged)
        
        return _datePicker
    }()
    
    public lazy var dateFormatter: NSDateFormatter = {
        let _dateFormatter = NSDateFormatter()
        _dateFormatter.dateStyle = .MediumStyle
        _dateFormatter.timeStyle = .NoStyle
        
        return _dateFormatter
    }()
    
    // MARK: Initializers
    
    required public init(labelText: String?, identifier: String? = nil, configurations: [FormCellConfiguration]? = nil, delegate: FormTableViewCellDelegate?) {
        super.init(labelText: labelText, identifier: identifier, configurations: configurations, delegate: delegate)
        
        selectionStyle = .None
        
        textField.inputView = datePicker
        textField.tintColor = UIColor.clearColor()
        textField.inputAccessoryView = keyboardAccessoryView
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: IBACTION Methods
    
    override public func pickerClearButtonTouchedUpInside(sender: UIButton) {
        value = nil
    }
    
    override public func pickerDoneButtonTouchedUpInside(sender: UIButton) {
        textField.resignFirstResponder()
    }
    
    // MARK: Methods
        
    func datePickerDidChangeValue(datePicker: UIDatePicker) {
        value = datePicker.date
    }
    
    // MARK: FormTableViewCellProtocol
    
    override public func updateUI() {
        if let dateValue = value as? NSDate {
            datePicker.date = dateValue
            textField.text = dateFormatter.stringFromDate(dateValue)
        } else {
            textField.text = nil
        }
    }
    
    override public func isEmpty() -> Bool {
        if let textFieldText = textField.text {
            return textFieldText.characters.count == 0
        }
        return true
    }
}
