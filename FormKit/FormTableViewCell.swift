//
//  FormTableViewCell.swift
//  FormKit
//
//  Created by Michael Loistl on 20/02/2015.
//  Copyright (c) 2015 MIchael LOistl. All rights reserved.
//

import Foundation
import UIKit

//@objc protocol FormTableViewCellProtocol {
//
//    var identifier: String {get set}
//    var objectType: AnyClass? {get set}
//    var valueKeyPath: String? {get set}
//    var value: AnyObject? {get set}
//    var errorState: Bool {get set}
//    var visible: Bool {get set}
//    
//    func setValue()
//    func updateUI()
//    func isEmpty() -> Bool
//    func isValid() -> Bool
//    
//    func rowHeight() -> CGFloat
//}

protocol FormTableViewCellDataSource {
    func valueForFormCell(sender: UITableViewCell, withIdentifier identifier: String) -> AnyObject?
    func valueInputEdgeInsetsForFormCell(sender: UITableViewCell, withIdentifier identifier: String) -> UIEdgeInsets
    func labelEdgeInsetsForFormCell(sender: UITableViewCell, withIdentifier identifier: String) -> UIEdgeInsets
}

protocol FormTableViewCellDelegate {
    func formCell(sender: UITableViewCell, withIdentifier identifier: String, didBecomeFirstResponder firstResponder: UIView?)
    
    func formCell(sender: UITableViewCell, withIdentifier identifier: String, didChangeValue value: AnyObject?, forObjectType objectType:AnyClass?, valueKeyPath: String?)
    func formCell(sender: UITableViewCell, withIdentifier identifier: String, didChangeRowHeight rowHeight: CGFloat)
    func formCell(sender: UITableViewCell, withIdentifier identifier: String, didChangeRowVisibility visible: Bool)
    
    func formCell(sender: UITableViewCell, withIdentifier identifier: String, shouldValidateWithIdentifier validationIdentifier: String) -> Bool
}

class FormTableViewCell: UITableViewCell {
    
    struct Validation {
        let closure: (value: AnyObject?) -> Bool
        let errorMessage: String
        let identifier: String
    }
    
    var identifier: String
    
    var objectType: AnyClass?
    
    var valueKeyPath: String?

    var value: AnyObject? {
        didSet {
            updateUI()
            delegate?.formCell(self, withIdentifier: identifier, didChangeValue: value, forObjectType: objectType, valueKeyPath: valueKeyPath)
        }
    }
    
    var validate = true

    var isEditable = true
    
    var validations = Array<Validation>()

    var dataSource: FormTableViewCellDataSource?
    var delegate: FormTableViewCellDelegate?
    
    var visible: Bool = true {
        didSet {
            if visible != oldValue {

                // Resign first responder
                resignFirstResponder()
                delegate?.formCell(self, withIdentifier: identifier, didChangeRowVisibility: visible)
            }
        }
    }
    
    var errorState: Bool = false {
        didSet {
            contentView.backgroundColor = (errorState) ? UIColor.redColor().colorWithAlphaComponent(0.1) : UIColor.whiteColor()
        }
    }
    
    var minRowHeight: CGFloat = 44.0
    var maxRowHeight: CGFloat = 44.0
    
    lazy var keyboardAccessoryView: KeyboardAccessoryView = {
        let _keyboardAccessoryView = KeyboardAccessoryView(frame: CGRectMake(0, 0, CGRectGetWidth(self.contentView.bounds), 44))
        _keyboardAccessoryView.addSubview(self.pickerClearButton)
        _keyboardAccessoryView.addSubview(self.pickerDoneButton)
        
        return _keyboardAccessoryView
        }()
    
    lazy var pickerDoneButton: UIButton = {
        let _pickerDoneButton = UIButton(type: .System)
        _pickerDoneButton.translatesAutoresizingMaskIntoConstraints = false
        _pickerDoneButton.setTitle("Done", forState: .Normal)
        _pickerDoneButton.addTarget(self, action: Selector("pickerDoneButtonTouchedUpInside:"), forControlEvents: .TouchUpInside)
        
        return _pickerDoneButton
        }()
    
    lazy var pickerClearButton: UIButton = {
        let _pickerClearButton = UIButton(type: .System)
        _pickerClearButton.translatesAutoresizingMaskIntoConstraints = false
        _pickerClearButton.setTitle("Clear", forState: .Normal)
        _pickerClearButton.addTarget(self, action: Selector("pickerClearButtonTouchedUpInside:"), forControlEvents: .TouchUpInside)
        
        return _pickerClearButton
        }()
    
    lazy var label: UILabel = {
        let _label = UILabel(frame: CGRectZero)
        _label.font = UIFont.monoFontOfSize(12)
        
        return _label
        }()
    
    // BottomSeparatorView
    lazy var bottomSeparatorView: UIView = {
        let _bottomSeparatorView = UIView()
        _bottomSeparatorView.backgroundColor = UIColor.RGB230Color()
        
        return _bottomSeparatorView
        }()
    
    // MARK: Initializers
    
    required init(identifier: String) {
        self.identifier = identifier
        super.init(style: .Default, reuseIdentifier: "")
        
        contentView.addSubview(bottomSeparatorView)
        contentView.addSubview(label)
        
        // KeyboardAccessoryView
        pickerClearButton.autoAlignAxis(.Horizontal, toSameAxisOfView: keyboardAccessoryView)
        pickerClearButton.autoPinEdge(.Left, toEdge: .Left, ofView: keyboardAccessoryView, withOffset: 16)
        pickerDoneButton.autoAlignAxis(.Horizontal, toSameAxisOfView: keyboardAccessoryView)
        pickerDoneButton.autoPinEdge(.Right, toEdge: .Right, ofView: keyboardAccessoryView, withOffset: -16)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        let labelEdgeInsets = dataSource?.labelEdgeInsetsForFormCell(self, withIdentifier: identifier) ?? UIEdgeInsetsZero
        let valueInputEdgeInsets = dataSource?.valueInputEdgeInsetsForFormCell(self, withIdentifier: identifier) ?? UIEdgeInsetsZero
        
        // Label
        let labelOriginX: CGFloat = labelEdgeInsets.left
        let labelOriginY: CGFloat = labelEdgeInsets.top
        let labelSizeWidth: CGFloat = valueInputEdgeInsets.left - labelOriginX
        let labelSizeHeight: CGFloat = CGRectGetHeight(bounds) - labelEdgeInsets.top - labelEdgeInsets.bottom
        
        label.frame = CGRectMake(labelOriginX, labelOriginY, labelSizeWidth, labelSizeHeight)
        
        // BottomSeparatorView
        let bottomSeparatorViewOriginX: CGFloat = 19
        let bottomSeparatorViewOriginY: CGFloat = CGRectGetHeight(bounds) - 1
        let bottomSeparatorViewWidth: CGFloat = CGRectGetWidth(bounds) - (19 * 2)
        let bottomSeparatorViewHeight: CGFloat = 1
        
        bottomSeparatorView.frame = CGRectMake(bottomSeparatorViewOriginX, bottomSeparatorViewOriginY, bottomSeparatorViewWidth, bottomSeparatorViewHeight)
    }
    
    // MARK: Override UIResponder Functions
    
    override func becomeFirstResponder() -> Bool {
        errorState = false
        return false
    }
    
    override func resignFirstResponder() -> Bool {
        return false
    }
    
    // MARK: Validation Methods
    
    func validateValue() -> Array<Validation>? {
        var failedValidations = Array<Validation>()
        for validation in validations {
            let shouldValidate = delegate?.formCell(self, withIdentifier: identifier, shouldValidateWithIdentifier: validation.identifier) ?? true
            if shouldValidate {
                if validation.closure(value: value) == false {
                    failedValidations.append(validation)
                }
            }
        }
        
        return (failedValidations.count > 0) ? failedValidations : nil
    }
    
    func addValidation(validation: (value: AnyObject?) -> Bool, withErrorMessage errorMessage: String, identifier: String = "") {
        let validation = Validation(closure: validation, errorMessage: errorMessage, identifier: identifier)
        validations.append(validation)
    }
    
    func addValidationForTypeEmailWithIdentifier(identifier: String) {
        addValidation({ (value) -> Bool in
            if let stringValue = value as? String {
                return stringValue.isValidEmail()
            }
            return false
        }, withErrorMessage: "Invalid email address", identifier: identifier)
    }
    
    func addValidationForNotNilValueWithIdentifier(identifier: String) {
        addValidation({ (value) -> Bool in
            return value != nil
        }, withErrorMessage: "Value must be not nil", identifier: identifier)
    }

    func addValidationForTypeStringWithMinLength(length: Int, identifier: String) {
        let characterString = (length > 1) ? "characters" : "character"
        addValidation({ (value) -> Bool in
            if let stringValue = value as? String {
                return stringValue.characters.count >= length
            }
            return false
        }, withErrorMessage: "Must be at least \(length) \(characterString)", identifier: identifier)
    }
    
    func addValidationForTypeStringWithMaxLength(length: Int, identifier: String) {
        let characterString = (length > 1) ? "characters" : "character"
        addValidation({ (value) -> Bool in
            if let stringValue = value as? String {
                return stringValue.characters.count <= length
            }
            return false
            }, withErrorMessage: "Must be at most \(length) \(characterString)", identifier: identifier)
    }
    
    func addValidationForTypeNumericWithMinNumber(number: Double, identifier: String) {
        addValidation({ (value) -> Bool in
            if let doubleValue = value?.doubleValue {
                return doubleValue >= number
            }
            return false
        }, withErrorMessage: "Must be at least \(number)", identifier: identifier)
    }
    
    func addValidationForTypeNumericWithMaxNumber(number: Double, identifier: String) {
        addValidation({ (value) -> Bool in
            if let doubleValue = value?.doubleValue {
                return doubleValue <= number
            }
            return false
            }, withErrorMessage: "Must be at least \(number)", identifier: identifier)
    }
    
    // MARK: - IBACTION Methods
    
    func pickerClearButtonTouchedUpInside(sender: UIButton) {

    }
    
    func pickerDoneButtonTouchedUpInside(sender: UIButton) {

    }
    
    // MARK: FormTableViewCellProtocol
    
    func setValue() {

    }
    
    func updateUI() {
        
    }
    
    func isEmpty() -> Bool {
        return value == nil
    }
    
    func isValid() -> Bool {
        if validate {
            let isValid = validateValue() == nil
            errorState = !isValid
            return isValid
        }
        
        return true
    }
    
    func rowHeight() -> CGFloat {
        return minRowHeight
    }
}

// MARK: - FormTextInputTableViewCell

class FormTextInputTableViewCell: FormTableViewCell {
    
    var characterlimit: Int = 0
    
//    lazy var 
    
}

// MARK: - FormTextFieldTableViewCell

class FormTextFieldTableViewCell: FormTextInputTableViewCell, UITextFieldDelegate {
    
    lazy var textField: UITextField = {
        let _textField = UITextField()
        _textField.delegate = self
        _textField.addTarget(self, action: Selector("textFieldDidChange:"), forControlEvents: .EditingChanged)

        return _textField
        }()
    
    // MARK: Initializers
    
    required init(identifier: String) {
        super.init(identifier: identifier)

        selectionStyle = .None
        
        contentView.addSubview(textField)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Override UIResponder Functions
    
    override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        becomeFirstResponder()
    }
    
    // MARK: Override UIView Functions
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let valueInputEdgeInsets = dataSource?.valueInputEdgeInsetsForFormCell(self, withIdentifier: identifier) ?? UIEdgeInsetsZero
        
        // TextField
        let textFieldOriginX: CGFloat = valueInputEdgeInsets.left
        let textFieldOriginY: CGFloat = valueInputEdgeInsets.top
        let textFieldSizeWidth: CGFloat = CGRectGetWidth(bounds) - valueInputEdgeInsets.left - valueInputEdgeInsets.right
        let textFieldSizeHeight: CGFloat = CGRectGetHeight(bounds) - valueInputEdgeInsets.top - valueInputEdgeInsets.bottom
        
        textField.frame = CGRectMake(textFieldOriginX, textFieldOriginY, textFieldSizeWidth, textFieldSizeHeight)
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldDidChange(textField: UITextField) {
        value = textField.text
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return isEditable
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        errorState = false
        delegate?.formCell(self, withIdentifier: identifier, didBecomeFirstResponder: textField)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {

    }
    
    // MARK: FormTableViewCellProtocol
    
    override func setValue() {
        value = dataSource?.valueForFormCell(self, withIdentifier: identifier) as? String
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
}

// MARK: - FormDatePickerTableViewCell

class FormDatePickerTableViewCell: FormTextFieldTableViewCell {
    
    lazy var datePicker: UIDatePicker = {
        let _datePicker = UIDatePicker()
        _datePicker.addTarget(self, action: Selector("datePickerDidChangeValue:"), forControlEvents: .ValueChanged)
        
        return _datePicker
    }()
    
    lazy var dateFormatter: NSDateFormatter = {
        let _dateFormatter = NSDateFormatter()
        _dateFormatter.dateStyle = .MediumStyle
        _dateFormatter.timeStyle = .NoStyle
        
        return _dateFormatter
        }()
    
    // MARK: Initializers
    
    required init(identifier: String) {
        super.init(identifier: identifier)
        
        selectionStyle = .None
        
        textField.inputView = datePicker
        textField.tintColor = UIColor.clearColor()
        textField.inputAccessoryView = keyboardAccessoryView
    }
    
    required init?(coder aDecoder: NSCoder) {
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
    
    override func setValue() {
        value = dataSource?.valueForFormCell(self, withIdentifier: identifier) as? NSDate
    }
    
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

// MARK: - FormTextViewTableViewCell

class FormTextViewTableViewCell: FormTextInputTableViewCell, NSLayoutManagerDelegate, UITextViewDelegate {
    
    var allowLineBreak = true
    
    var contentHeight: CGFloat = 0 {
        didSet {
            if contentHeight != oldValue {
                delegate?.formCell(self, withIdentifier: identifier, didChangeRowHeight: rowHeight())
            }
        }
    }
    
    lazy var textView: TextView = {
        let _textView = TextView(frame: CGRectZero, textContainer: self.textContainer)
        _textView.delegate = self
        _textView.font = self.textLabel?.font
        _textView.backgroundColor = UIColor.clearColor()
        
        return _textView
        }()
    
    // TextStorage
    lazy var textStorage: NSTextStorage = {
        let attributes: [String: AnyObject] = [NSFontAttributeName: self.textLabel!.font]
        
        var attributedString = NSAttributedString(string: "", attributes: attributes)
        
        let _textStorage = NSTextStorage()
        _textStorage.appendAttributedString(attributedString)
        
        return _textStorage
        }()
    
    // LayoutManager
    lazy var textLayoutManager: NSLayoutManager = {
        let _textLayoutManager = NSLayoutManager()
        _textLayoutManager.delegate = self
        
        return _textLayoutManager
        }()
    
    // TextContainer
    lazy var textContainer: NSTextContainer = {
        let _textContainer = NSTextContainer(size: CGSizeMake(CGRectGetWidth(self.bounds), CGFloat.max))
        _textContainer.widthTracksTextView = true
        self.textLayoutManager.addTextContainer(_textContainer)
        self.textStorage.addLayoutManager(self.textLayoutManager)
        
        return _textContainer
        }()
    
    // MARK: Initializers
    
    required init(identifier: String) {
        super.init(identifier: identifier)
        
        maxRowHeight = 88.0
        
        selectionStyle = .None
        contentView.clipsToBounds = true
        
        contentView.addSubview(textView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Override UIResponder Functions
    
    override func becomeFirstResponder() -> Bool {
        return textView.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        return textView.resignFirstResponder()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        becomeFirstResponder()
    }
    
    // MARK: Override UIView Functions
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let valueInputEdgeInsets = dataSource?.valueInputEdgeInsetsForFormCell(self, withIdentifier: identifier) ?? UIEdgeInsetsZero
        
        let contentOffset = textView.contentOffset
        let offset: CGFloat = (CGRectGetHeight(bounds) == maxRowHeight) ? -11.5 : 11.5
        
        // TextView
        let textViewOriginX: CGFloat = valueInputEdgeInsets.left
        let textViewOriginY: CGFloat = valueInputEdgeInsets.top + 11.5
        let textViewSizeWidth: CGFloat = CGRectGetWidth(bounds) - valueInputEdgeInsets.left - valueInputEdgeInsets.right
        let textViewSizeHeight: CGFloat = CGRectGetHeight(bounds) + offset - valueInputEdgeInsets.top - valueInputEdgeInsets.bottom
        
        textView.frame = CGRectMake(textViewOriginX, textViewOriginY, textViewSizeWidth, textViewSizeHeight)
        
        // TextContainer
        textContainer.size = CGSizeMake(CGRectGetWidth(textView.bounds), CGFloat.max)

        // TextLabel
        var textLabelRect = textLabel?.frame ?? bounds
        textLabelRect.size.height = 44.0
        
        textLabel?.frame = textLabelRect
        
        textView.contentOffset = contentOffset
    }
    
    // MARK: NSLayoutManagerDelegate
    
    // MARK: UITextViewDelegate
    
    
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            return allowLineBreak
        }
        
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        
        value = textView.text
        contentHeight = textView.contentSize.height
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        return isEditable
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        errorState = false
        delegate?.formCell(self, withIdentifier: identifier, didBecomeFirstResponder: textView)
    }
    
    func textViewDidEndEditing(textView: UITextView) {

    }
    
    // MARK: ScrollViewDelegate

    func scrollViewDidScroll(scrollView: UIScrollView) {

    }
    
    // MARK: FormTableViewCellProtocol
    
    override func setValue() {
        value = dataSource?.valueForFormCell(self, withIdentifier: identifier) as? String
        layoutSubviews()
    }
    
    override func updateUI() {
        textView.text = value as? String
    }
    
    override func isEmpty() -> Bool {
        if let text = textView.text {
            return text.characters.count == 0
        }
        return true
    }
    
    override func rowHeight() -> CGFloat {
        if visible {
            let textHeight = textView.text?.boundingRectHeightWithMaxWidth(CGRectGetWidth(textView.bounds), font: textView.font!) ?? 0
            return min(max(textHeight + 11.5 + 11.5, minRowHeight), maxRowHeight)
        }
        return 0
    }
}

// MARK: - FormSwitchTableViewCell

class FormSwitchTableViewCell: FormTableViewCell {
    
    lazy var switchView: UISwitch = {
        let _switchView = UISwitch()
        _switchView.addTarget(self, action: Selector("switchDidChangeValue:"), forControlEvents: .ValueChanged)
        
        return _switchView
        }()
    
    // MARK: Initializers
    
    required init(identifier: String) {
        super.init(identifier: identifier)
        
        selectionStyle = .None
        
        contentView.addSubview(switchView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Override UIView Functions
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let valueInputEdgeInsets = dataSource?.valueInputEdgeInsetsForFormCell(self, withIdentifier: identifier) ?? UIEdgeInsetsZero
        
        // Switch
        switchView.sizeToFit()
        let switchOriginX: CGFloat = CGRectGetWidth(bounds) - CGRectGetWidth(switchView.bounds) - valueInputEdgeInsets.right
        let switchOriginY: CGFloat = (CGRectGetHeight(bounds) - CGRectGetHeight(switchView.bounds)) / 2.0
        let switchSizeWidth: CGFloat = CGRectGetWidth(switchView.bounds)
        let switchSizeHeight: CGFloat = CGRectGetHeight(switchView.bounds)
        
        switchView.frame = CGRectMake(switchOriginX, switchOriginY, switchSizeWidth, switchSizeHeight)
    }
    
    // MARK: Functions
    
    func switchDidChangeValue(sender: UISwitch) {
        value = sender.on
    }
    
    // MARK: FormTableViewCellProtocol
    
    override func setValue() {
        value = dataSource?.valueForFormCell(self, withIdentifier: identifier) as? Bool ?? false
    }
    
    override func updateUI() {
        switchView.on = value as? Bool ?? false
    }
    
    override func isEmpty() -> Bool {
        return false
    }
}

// MARK: - FormSelectionTableViewCell

class FormSelectionTableViewCell: FormTableViewCell {
    
    var selectionValueKeyPath: String?
    var sortDescriptors: Array<RLMSortDescriptor>?
    var allowsMultipleSelection = true
    var selectionViewControllerClass: UIViewController.Type?
    
    lazy var valueLabel: UILabel = {
        let _valueLabel = UILabel()
        _valueLabel.textColor = UIColor.grayColor()
        _valueLabel.font = self.textLabel?.font
        _valueLabel.textAlignment = .Right
        
        return _valueLabel
    }()
    
    // MARK: Initializers
    
    required init(identifier: String) {
        super.init(identifier: identifier)
        
        accessoryType = .DisclosureIndicator
        
        contentView.addSubview(valueLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Override UIView Functions
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let valueInputEdgeInsets = dataSource?.valueInputEdgeInsetsForFormCell(self, withIdentifier: identifier) ?? UIEdgeInsetsZero
        
        // ValueLabel
        let sizeWidth: CGFloat = CGRectGetWidth(contentView.bounds) - valueInputEdgeInsets.left - valueInputEdgeInsets.right
        let sizeHeight: CGFloat = CGRectGetHeight(contentView.bounds) - valueInputEdgeInsets.top - valueInputEdgeInsets.bottom
        
        valueLabel.frame = CGRectMake(valueInputEdgeInsets.left, valueInputEdgeInsets.top, sizeWidth, sizeHeight)
    }
    
    // MARK: FormTableViewCellProtocol
    
    override func setValue() {
        value = dataSource?.valueForFormCell(self, withIdentifier: identifier) as? Array<AnyObject> ?? Array<AnyObject>()
    }
    
    override func updateUI() {
        
        if allowsMultipleSelection {
            if let array = value as? Array<AnyObject> {
                valueLabel.text = "\(array.count)"
            } else {
                valueLabel.text = "0"
            }
        } else {
            valueLabel.text = nil
        }
    }
    
    override func isEmpty() -> Bool {
        return false
    }
}

// MARK: - FormButtonTableViewCell

class FormButtonTableViewCell: FormTableViewCell {
    
    // MARK: Initializers
    
    required init(identifier: String) {
        super.init(identifier: identifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Extension

extension String {
    
    func isValidEmail() -> Bool {
        let regularExpression = try? NSRegularExpression(pattern: "\\b^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,20}$\\b", options: [])
        let numberOfMatches = regularExpression?.numberOfMatchesInString(self, options: [], range: NSMakeRange(0, self.characters.count))
        return numberOfMatches > 0
    }
}

// MARK: - SubClasses

class TextView: UITextView {
    
    var placeholder: String? {
        didSet {
            placeHolderLabel.text = placeholder
            layoutSubviews()
        }
    }
    
    override var text: String? {
        didSet {
            
        }
    }

    override var font: UIFont? {
        didSet {
            placeHolderLabel.font = font
        }
    }
    
    override var textAlignment: NSTextAlignment {
        didSet {
            placeHolderLabel.textAlignment = textAlignment
        }
    }
    
    lazy var placeHolderLabel: UILabel = {
        let _placeHolderLabel = UILabel()
        _placeHolderLabel.font = self.font
        _placeHolderLabel.textAlignment = self.textAlignment
        _placeHolderLabel.textColor = UIColor(red: 0, green: 0, blue: 0.0980392, alpha: 0.22)
        
        return _placeHolderLabel
        }()
    
    // MARK: Initializers
    
//    override init() {
//        super.init(frame: CGRectZero)
//    }
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        addSubview(placeHolderLabel)
        
        textContainer?.lineFragmentPadding = 0
        textContainerInset = UIEdgeInsetsZero
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handleTextViewTextDidChangeNotification:"), name: UITextViewTextDidChangeNotification, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: Override UIView Functions
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // PlaceHolderLabel
        placeHolderLabel.sizeToFit()
        
        let placeHolderLabelOriginX: CGFloat = textContainerInset.left + contentInset.left
        let placeHolderLabelOriginY: CGFloat = textContainerInset.top + contentInset.top + 1.0
        let placeHolderLabelSizeWidth: CGFloat = CGRectGetWidth(placeHolderLabel.bounds)
        let placeHolderLabelSizeHeight: CGFloat = CGRectGetHeight(placeHolderLabel.bounds)
        
        placeHolderLabel.frame = CGRectMake(placeHolderLabelOriginX, placeHolderLabelOriginY, placeHolderLabelSizeWidth, placeHolderLabelSizeHeight)
    }
    
    // MARK: Notification Handler Functions
    
    func handleTextViewTextDidChangeNotification(sender: NSNotification) {
        if let text = text {
            placeHolderLabel.hidden = text.characters.count > 0
        } else {
            placeHolderLabel.hidden = false
        }
    }
}

class KeyboardAccessoryView: UIInputView {
    
    override init(frame: CGRect, inputViewStyle: UIInputViewStyle) {
        super.init(frame: frame, inputViewStyle: UIInputViewStyle.Keyboard)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
