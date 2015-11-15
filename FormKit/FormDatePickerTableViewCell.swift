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
        _datePicker.addTarget(self, action: Selector("datePickerDidChangeValue:"), forControlEvents: .ValueChanged)
        
        return _datePicker
    }()
    
    public lazy var dateFormatter: NSDateFormatter = {
        let _dateFormatter = NSDateFormatter()
        _dateFormatter.dateStyle = .MediumStyle
        _dateFormatter.timeStyle = .NoStyle
        
        return _dateFormatter
    }()
    
    // MARK: Initializers
    
    required public init(identifier: String, dataSource: FormTableViewCellDataSource!, delegate: FormTableViewCellDelegate!, configuration: FormTableViewCellConfiguration = FormTableViewCellConfiguration.defaultConfiguration()) {
        super.init(identifier: identifier, dataSource: dataSource, delegate: delegate, configuration: configuration)
        
        selectionStyle = .None
        
        textField.inputView = datePicker
        textField.tintColor = UIColor.clearColor()
        textField.inputAccessoryView = keyboardAccessoryView
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: IBACTION Methods
    
    override func pickerClearButtonTouchedUpInside(sender: UIButton) {
        value = nil
    }
    
    override func pickerDoneButtonTouchedUpInside(sender: UIButton) {
        textField.resignFirstResponder()
    }
    
    // MARK: Methods
    
    func datePickerDidChangeValue(datePicker: UIDatePicker) {
        value = datePicker.date
    }
    
    // MARK: FormTableViewCellProtocol
    
    override func updateUI() {
        if let dateValue = value as? NSDate {
            textField.text = dateFormatter.stringFromDate(dateValue)
        } else {
            textField.text = nil
        }
    }
    
    override func isEmpty() -> Bool {
        if let textFieldText = textField.text {
            return textFieldText.characters.count == 0
        }
        return true
    }
}
