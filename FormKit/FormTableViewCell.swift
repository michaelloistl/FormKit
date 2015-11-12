//
//  FormTableViewCell.swift
//  FormKit
//
//  Created by Michael Loistl on 20/02/2015.
//  Copyright (c) 2015 MIchael LOistl. All rights reserved.
//

import Foundation
import UIKit
import PureLayout

public protocol FormTableViewCellProtocol {
    // TODO:
}

public protocol FormTableViewCellDataSource {
    func valueForFormCell(sender: FormTableViewCell, withIdentifier identifier: String) -> AnyObject?

    func labelEdgeInsetsForFormCell(sender: FormTableViewCell, withIdentifier identifier: String) -> UIEdgeInsets
    func valueEdgeInsetsForFormCell(sender: FormTableViewCell, withIdentifier identifier: String) -> UIEdgeInsets
    
    func labelConfigurationForFormCell(sender: FormTableViewCell, withIdentifier identifier: String) -> [String: AnyObject]
    func valueConfigurationForFormCell(sender: FormTableViewCell, withIdentifier identifier: String) -> [String: AnyObject]
}

public protocol FormTableViewCellDelegate {
    func formCell(sender: FormTableViewCell, withIdentifier identifier: String, didBecomeFirstResponder firstResponder: UIView?)
    
    func formCell(sender: FormTableViewCell, withIdentifier identifier: String, didChangeValue value: AnyObject?, forObjectType objectType:AnyClass?, valueKeyPath: String?)
    
    func formCell(sender: FormTableViewCell, withIdentifier identifier: String, didChangeRowHeight rowHeight: CGFloat)
    func formCell(sender: FormTableViewCell, withIdentifier identifier: String, didChangeRowVisibility visible: Bool)

    func formCellDidRequestNextFormTableViewCell(sender: FormTableViewCell, withIdentifier identifier: String)
    
    func formCell(sender: FormTableViewCell, withIdentifier identifier: String, shouldValidateWithIdentifier validationIdentifier: String) -> Bool
}

public class FormTableViewCellConfiguration {
    var labelProperties = [String: NSObject]()
    var valueProperties = [String: NSObject]()
    
    required public init() { }
    
    public class func defaultConfiguration() -> FormTableViewCellConfiguration {
        return FormTableViewCellConfiguration()
    }
    
    public class func emailConfiguration() -> FormTableViewCellConfiguration {
        let configuration = self.defaultConfiguration()
        
        configuration.valueProperties["keyboardType"] = UIKeyboardType.EmailAddress.rawValue
        configuration.valueProperties["autocorrectionType"] = UITextAutocorrectionType.No.rawValue
        configuration.valueProperties["autocapitalizationType"] = UITextAutocapitalizationType.None.rawValue
        
        return configuration
    }

    public class func passwordConfiguration() -> FormTableViewCellConfiguration {
        let configuration = self.defaultConfiguration()
        
        configuration.valueProperties["secureTextEntry"] = true
        configuration.valueProperties["autocorrectionType"] = UITextAutocorrectionType.No.rawValue
        configuration.valueProperties["autocapitalizationType"] = UITextAutocapitalizationType.None.rawValue
        
        return configuration
    }
}

public class FormTableViewCell: UITableViewCell, FormTableViewCellProtocol {
    
    public struct Validation {
        let closure: (value: AnyObject?) -> Bool
        let errorMessage: String
        let identifier: String
    }

    public struct Action {
        let closure: (value: AnyObject?) -> Void
        let identifier: String
    }

    public var labelRightEdgeIsLeftValueEdge = true
    
    public var identifier: String
    
    public var objectType: AnyClass?
    
    public var valueKeyPath: String?

    public var value: AnyObject? {
        didSet {
            configValue()
            updateUI()
            delegate?.formCell(self, withIdentifier: identifier, didChangeValue: value, forObjectType: objectType, valueKeyPath: valueKeyPath)
        }
    }
    
    public var validate = true

    public var isEditable = true
    
    public var validations = Array<Validation>()
    public var actions = Array<Action>()

    public var dataSource: FormTableViewCellDataSource?
    public var delegate: FormTableViewCellDelegate?
    
    public var visible: Bool = true {
        didSet {
            if visible != oldValue {

                // Resign first responder
                resignFirstResponder()
                delegate?.formCell(self, withIdentifier: identifier, didChangeRowVisibility: visible)
            }
        }
    }
    
    public var errorState: Bool = false {
        didSet {
            contentView.backgroundColor = (errorState) ? UIColor.redColor().colorWithAlphaComponent(0.1) : UIColor.whiteColor()
        }
    }
    
    public var minRowHeight: CGFloat = 44.0
    public var maxRowHeight: CGFloat = 44.0
    
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
    
    public lazy var label: UILabel = {
        let _label = UILabel(frame: CGRectZero)
        _label.backgroundColor = UIColor.clearColor()
        
        return _label
        }()
    
    public lazy var valueTextView: UITextView = {
        let _textView = UITextView()
        _textView.textColor = UIColor.grayColor()
        _textView.font = self.label.font
        _textView.textAlignment = .Right
        
        _textView.editable = false
//        _textView.selectable = true
        _textView.scrollEnabled = false
        _textView.userInteractionEnabled = false
        
        _textView.contentInset = UIEdgeInsetsZero
        _textView.textContainerInset = UIEdgeInsetsZero
        _textView.textContainer.lineFragmentPadding = 0

        return _textView
    }()
    
    // BottomSeparatorView
    public lazy var bottomSeparatorView: UIView = {
        let _bottomSeparatorView = UIView()
        _bottomSeparatorView.backgroundColor = UIColor.lightGrayColor()
        _bottomSeparatorView.hidden = true
        
        return _bottomSeparatorView
        }()
    
    // MARK: - Initializers
    
    required public init(identifier: String, dataSource: FormTableViewCellDataSource!, delegate: FormTableViewCellDelegate!, configuration: FormTableViewCellConfiguration = FormTableViewCellConfiguration.defaultConfiguration()) {
        self.identifier = identifier
        self.dataSource = dataSource
        self.delegate = delegate
        
        super.init(style: .Default, reuseIdentifier: "")
        
        contentView.addSubview(bottomSeparatorView)
        contentView.addSubview(label)
        contentView.addSubview(valueTextView)
        
        // label configuration
        for (key, value) in configuration.labelProperties {
            if label.respondsToSelector(Selector(key)) {
                label.setValue(value, forKey: key)
            }
        }
        
        // valueTextView configuration
        for (key, value) in configuration.labelProperties {
            if valueTextView.respondsToSelector(Selector(key)) {
                valueTextView.setValue(value, forKey: key)
            }
        }
                
        // KeyboardAccessoryView
        pickerClearButton.autoAlignAxis(.Horizontal, toSameAxisOfView: keyboardAccessoryView)
        pickerClearButton.autoPinEdge(.Left, toEdge: .Left, ofView: keyboardAccessoryView, withOffset: 16)
        pickerDoneButton.autoAlignAxis(.Horizontal, toSameAxisOfView: keyboardAccessoryView)
        pickerDoneButton.autoPinEdge(.Right, toEdge: .Right, ofView: keyboardAccessoryView, withOffset: -16)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        
        configLabel()
        
        let labelEdgeInsets = dataSource?.labelEdgeInsetsForFormCell(self, withIdentifier: identifier) ?? UIEdgeInsetsZero
        let valueEdgeInsets = dataSource?.valueEdgeInsetsForFormCell(self, withIdentifier: identifier) ?? UIEdgeInsetsZero
        
        // Label
        let labelOriginX: CGFloat = labelEdgeInsets.left
        let labelOriginY: CGFloat = labelEdgeInsets.top
        let labelSizeWidth: CGFloat = CGRectGetWidth(bounds) - labelEdgeInsets.left - labelEdgeInsets.right
        let labelSizeHeight: CGFloat = CGRectGetHeight(bounds) - labelEdgeInsets.top - labelEdgeInsets.bottom
        
        label.frame = CGRectMake(labelOriginX, labelOriginY, labelSizeWidth, labelSizeHeight)
        
        // ValueTextView
        let sizeWidth: CGFloat = CGRectGetWidth(contentView.bounds) - valueEdgeInsets.left - valueEdgeInsets.right
        let sizeHeight: CGFloat = CGRectGetHeight(contentView.bounds) - valueEdgeInsets.top - valueEdgeInsets.bottom
        
        valueTextView.frame = CGRectMake(valueEdgeInsets.left, valueEdgeInsets.top, sizeWidth, sizeHeight)
        
        // BottomSeparatorView
        let bottomSeparatorViewOriginX: CGFloat = 19
        let bottomSeparatorViewOriginY: CGFloat = CGRectGetHeight(bounds) - 1
        let bottomSeparatorViewWidth: CGFloat = CGRectGetWidth(bounds) - (19 * 2)
        let bottomSeparatorViewHeight: CGFloat = 1
        
        bottomSeparatorView.frame = CGRectMake(bottomSeparatorViewOriginX, bottomSeparatorViewOriginY, bottomSeparatorViewWidth, bottomSeparatorViewHeight)
    }
    
    // MARK: - Super
    
    override public func becomeFirstResponder() -> Bool {
        errorState = false
        return false
    }
    
    override public func resignFirstResponder() -> Bool {
        return false
    }
    
    // MARK: - Methods
    
    func configLabel() {
        if let config = dataSource?.labelConfigurationForFormCell(self, withIdentifier: identifier) {
            for (key, value) in config {
                if label.respondsToSelector(Selector(key)) {
                    label.setValue(value, forKey: key)
                }
            }
        }
    }

    func configValue() {
        if let config = dataSource?.valueConfigurationForFormCell(self, withIdentifier: identifier) {
            for (key, value) in config {
                if valueTextView.respondsToSelector(Selector(key)) {
                    valueTextView.setValue(value, forKey: key)
                }
            }
        }
    }
    
    func setValue() {
        value = dataSource?.valueForFormCell(self, withIdentifier: identifier) as? Array<AnyObject> ?? Array<AnyObject>()
    }
    
    func updateUI() {
        valueTextView.text = textFromValue()
    }
    
    func isEmpty() -> Bool {
        return value == nil
    }
    
    func isValid(showErrorState: Bool = true) -> Bool {
        if validate {
            let isValid = validateValue() == nil
            if showErrorState {
                errorState = !isValid
            }
            return isValid
        }
        
        return true
    }
    
    func rowHeight() -> CGFloat {
        let valueEdgeInsets = dataSource?.valueEdgeInsetsForFormCell(self, withIdentifier: identifier) ?? UIEdgeInsetsZero

        var valueLabelHeight: CGFloat = 0
        if let text = textFromValue() {
            valueLabelHeight = text.boundingRectHeightWithMaxWidth(CGRectGetWidth(valueTextView.bounds), font: valueTextView.font!) + 1
        }
        
        return min(max(valueLabelHeight + valueEdgeInsets.top + valueEdgeInsets.bottom, minRowHeight), maxRowHeight)
    }
    
    func textFromValue() -> String? {
        if let stringArray = value as? [String] {
            return stringArray.joinWithSeparator(", ")
        } else if let array = value as? [AnyObject] {
            return "\(array.count)"
        } else if let string = value as? String {
            return string
        }
        
        return nil
    }
    
    // MARK: Actions
    
    public func addAction(action: (value: AnyObject?) -> Void, identifier: String) {
        let action = Action(closure: action, identifier: identifier)
        actions.append(action)
    }
    
    // MARK: Validations
    
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
    
    public func addValidation(validation: (value: AnyObject?) -> Bool, withErrorMessage errorMessage: String, identifier: String = "") {
        let validation = Validation(closure: validation, errorMessage: errorMessage, identifier: identifier)
        validations.append(validation)
    }
    
    public func addValidationForTypeEmailWithIdentifier(identifier: String) {
        addValidation({ (value) -> Bool in
            if let stringValue = value as? String {
                return stringValue.isValidEmail()
            }
            return false
        }, withErrorMessage: "Invalid email address", identifier: identifier)
    }
    
    public func addValidationForNotNilValueWithIdentifier(identifier: String) {
        addValidation({ (value) -> Bool in
            return value != nil
        }, withErrorMessage: "Value must be not nil", identifier: identifier)
    }

    public func addValidationForTypeStringWithMinLength(length: Int, identifier: String) {
        let characterString = (length > 1) ? "characters" : "character"
        addValidation({ (value) -> Bool in
            if let stringValue = value as? String {
                return stringValue.characters.count >= length
            }
            return false
        }, withErrorMessage: "Must be at least \(length) \(characterString)", identifier: identifier)
    }
    
    public func addValidationForTypeStringWithMaxLength(length: Int, identifier: String) {
        let characterString = (length > 1) ? "characters" : "character"
        addValidation({ (value) -> Bool in
            if let stringValue = value as? String {
                return stringValue.characters.count <= length
            }
            return true
            }, withErrorMessage: "Must be at most \(length) \(characterString)", identifier: identifier)
    }
    
    public func addValidationForTypeNumericWithMinNumber(number: Double, identifier: String) {
        addValidation({ (value) -> Bool in
            if let doubleValue = value?.doubleValue {
                return doubleValue >= number
            }
            return false
        }, withErrorMessage: "Must be at least \(number)", identifier: identifier)
    }
    
    public func addValidationForTypeNumericWithMaxNumber(number: Double, identifier: String) {
        addValidation({ (value) -> Bool in
            if let doubleValue = value?.doubleValue {
                return doubleValue <= number
            }
            return false
            }, withErrorMessage: "Must be at least \(number)", identifier: identifier)
    }
    
    // MARK: Actions
    
    func pickerClearButtonTouchedUpInside(sender: UIButton) {

    }
    
    func pickerDoneButtonTouchedUpInside(sender: UIButton) {

    }
}

// MARK: - FormTextInputTableViewCell

public class FormTextInputTableViewCell: FormTableViewCell {
    
    var characterlimit: Int = 0 {
        didSet {
            characterLabel.hidden = characterlimit == 0
            updateCharacterLabelWithCharacterCount(0)
        }
    }
    
    var characterLabelValidTextColor = UIColor.lightGrayColor()
    var characterLabelInvalidTextColor = UIColor.redColor()
    
    public lazy var characterLabel: UILabel = {
        let _characterLabel = UILabel()
        _characterLabel.textAlignment = .Right
        _characterLabel.hidden = true
        
        return _characterLabel
        }()
    
    // MARK: - Initializers
    
    required public init(identifier: String, dataSource: FormTableViewCellDataSource!, delegate: FormTableViewCellDelegate!, configuration: FormTableViewCellConfiguration = FormTableViewCellConfiguration.defaultConfiguration()) {
        super.init(identifier: identifier, dataSource: dataSource, delegate: delegate, configuration: configuration)
        
        valueTextView.hidden = true
        
        selectionStyle = .None
        contentView.clipsToBounds = true
        
        contentView.addSubview(characterLabel)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Super
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let valueEdgeInsets = dataSource?.valueEdgeInsetsForFormCell(self, withIdentifier: identifier) ?? UIEdgeInsetsZero
        
        let originX: CGFloat = valueEdgeInsets.left
        let originY: CGFloat = CGRectGetHeight(bounds) - valueEdgeInsets.bottom
        let sizeWidth: CGFloat = CGRectGetWidth(bounds) - valueEdgeInsets.left - valueEdgeInsets.right
        let sizeHeight: CGFloat = valueEdgeInsets.bottom
        
        characterLabel.frame = CGRectMake(originX, originY, sizeWidth, sizeHeight)
    }
    
    // MARK: - Methods
    
    func updateCharacterLabelWithCharacterCount(count: Int) {
        if characterlimit > 0 {
            let remainingCharacters = characterlimit - count
            characterLabel.text = "\(remainingCharacters)"
            characterLabel.textColor = (remainingCharacters < 0) ? characterLabelInvalidTextColor : characterLabelValidTextColor
            characterLabel.hidden = false
        } else {
            characterLabel.hidden = true
        }
    }
    
    func nextFormTableViewCell() {
        delegate?.formCellDidRequestNextFormTableViewCell(self, withIdentifier: identifier)
    }
}

// MARK: - FormTextFieldTableViewCell

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
        
        let valueEdgeInsets = dataSource?.valueEdgeInsetsForFormCell(self, withIdentifier: identifier) ?? UIEdgeInsetsZero
        
        // TextField
        let textFieldOriginX: CGFloat = valueEdgeInsets.left
        let textFieldOriginY: CGFloat = valueEdgeInsets.top
        let textFieldSizeWidth: CGFloat = CGRectGetWidth(bounds) - valueEdgeInsets.left - valueEdgeInsets.right
        let textFieldSizeHeight: CGFloat = CGRectGetHeight(bounds) - valueEdgeInsets.top - valueEdgeInsets.bottom
        
        textField.frame = CGRectMake(textFieldOriginX, textFieldOriginY, textFieldSizeWidth, textFieldSizeHeight)
    }
    
    // MARK: - Methods
    
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
        delegate?.formCell(self, withIdentifier: identifier, didBecomeFirstResponder: textField)
    }
    
    public func textFieldDidEndEditing(textField: UITextField) {

    }
}

// MARK: - FormTextViewTableViewCell

public class FormTextViewTableViewCell: FormTextInputTableViewCell, NSLayoutManagerDelegate, UITextViewDelegate {
    
    var allowLineBreak = true
    
    var contentHeight: CGFloat = 0 {
        didSet {
            if contentHeight != oldValue {
                delegate?.formCell(self, withIdentifier: identifier, didChangeRowHeight: rowHeight())
            }
        }
    }
    
    public lazy var textView: TextView = {
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
    
    required public init(identifier: String, dataSource: FormTableViewCellDataSource!, delegate: FormTableViewCellDelegate!, configuration: FormTableViewCellConfiguration = FormTableViewCellConfiguration.defaultConfiguration()) {
        super.init(identifier: identifier, dataSource: dataSource, delegate: delegate, configuration: configuration)
        
        maxRowHeight = 88.0
        
        contentView.insertSubview(textView, atIndex: 0)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Override UIResponder Functions
    
    override public func isFirstResponder() -> Bool {
        return textView.isFirstResponder()
    }

    override public func becomeFirstResponder() -> Bool {
        return textView.becomeFirstResponder()
    }
    
    override public func resignFirstResponder() -> Bool {
        return textView.resignFirstResponder()
    }
    
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        becomeFirstResponder()
    }
    
    // MARK: - Super
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let valueEdgeInsets = dataSource?.valueEdgeInsetsForFormCell(self, withIdentifier: identifier) ?? UIEdgeInsetsZero
        
        textView.textContainerInset.top = valueEdgeInsets.top
        
        // TextView
        let textViewOriginX: CGFloat = valueEdgeInsets.left
        let textViewOriginY: CGFloat = 0
        let textViewSizeWidth: CGFloat = CGRectGetWidth(bounds) - valueEdgeInsets.left - valueEdgeInsets.right
        let textViewSizeHeight: CGFloat = rowHeight() - valueEdgeInsets.bottom
        
        textView.frame = CGRectMake(textViewOriginX, textViewOriginY, textViewSizeWidth, textViewSizeHeight)
        
        // TextContainer
        textContainer.size = CGSizeMake(CGRectGetWidth(textView.bounds), CGFloat.max)

        // TextLabel
        var textLabelRect = textLabel?.frame ?? bounds
        textLabelRect.size.height = 44.0
        
        textLabel?.frame = textLabelRect
    }
    
    // MARK: Methods

    
    // MARK: UITextViewDelegate
    
    public func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            if textView.returnKeyType == .Next {
                nextFormTableViewCell()
            }

            return allowLineBreak
        }
        
        return true
    }
    
    public func textViewDidChange(textView: UITextView) {
        
        layoutSubviews()
        
        value = textView.text
        contentHeight = textView.contentSize.height
        updateCharacterLabelWithCharacterCount(textView.text?.characters.count ?? 0)

        let valueEdgeInsets = dataSource?.valueEdgeInsetsForFormCell(self, withIdentifier: identifier) ?? UIEdgeInsetsZero
        let textViewHeight = CGRectGetHeight(bounds) - valueEdgeInsets.bottom
        let textHeight = textView.text?.boundingRectHeightWithMaxWidth(CGRectGetWidth(textView.bounds), font: textView.font!) ?? 0
        
        textView.scrollEnabled = textHeight > textViewHeight
    }
    
    public func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        return isEditable
    }
    
    public func textViewDidBeginEditing(textView: UITextView) {
        errorState = false
        delegate?.formCell(self, withIdentifier: identifier, didBecomeFirstResponder: textView)
    }
    
    public func textViewDidEndEditing(textView: UITextView) {

    }
    
    // MARK: ScrollViewDelegate

    public func scrollViewDidScroll(scrollView: UIScrollView) {

    }
    
    // MARK: FormTableViewCellProtocol
    
    override func setValue() {
        value = dataSource?.valueForFormCell(self, withIdentifier: identifier) as? String
        layoutSubviews()
    }
    
    override func updateUI() {
        if let text = value as? String {
            if textView.text != text {
                textView.text = ""
                textView.insertText(text)
            }
        }
    }
    
    override func isEmpty() -> Bool {
        if let text = textView.text {
            return text.characters.count == 0
        }
        return true
    }
    
    override func rowHeight() -> CGFloat {
        if visible {
            let valueEdgeInsets = dataSource?.valueEdgeInsetsForFormCell(self, withIdentifier: identifier) ?? UIEdgeInsetsZero
            let textHeight = textView.text?.boundingRectHeightWithMaxWidth(CGRectGetWidth(textView.bounds), font: textView.font!) ?? 0
            return min(max(textHeight + valueEdgeInsets.top + valueEdgeInsets.bottom, minRowHeight), maxRowHeight)
        }
        return 0
    }
}

// MARK: - FormDatePickerTableViewCell

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

// MARK: - FormSwitchTableViewCell

public class FormSwitchTableViewCell: FormTableViewCell {
    
    public lazy var switchView: UISwitch = {
        let _switchView = UISwitch()
        _switchView.addTarget(self, action: Selector("switchDidChangeValue:"), forControlEvents: .ValueChanged)
        
        return _switchView
        }()
    
    // MARK: Initializers
    
    required public init(identifier: String, dataSource: FormTableViewCellDataSource!, delegate: FormTableViewCellDelegate!, configuration: FormTableViewCellConfiguration = FormTableViewCellConfiguration.defaultConfiguration()) {
        super.init(identifier: identifier, dataSource: dataSource, delegate: delegate, configuration: configuration)
        
        selectionStyle = .None
        
        contentView.addSubview(switchView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Super
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let valueEdgeInsets = dataSource?.valueEdgeInsetsForFormCell(self, withIdentifier: identifier) ?? UIEdgeInsetsZero
        
        // Switch
        switchView.sizeToFit()
        let switchOriginX: CGFloat = CGRectGetWidth(bounds) - CGRectGetWidth(switchView.bounds) - valueEdgeInsets.right
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

public class FormSelectionTableViewCell: FormTableViewCell {
    
    public var allowsMultipleSelection = false
    
    public var selectionTitle: String?
    public var selectionValues = [String]()
    
    public var selectionViewControllerClass: UIViewController.Type?
    
    // MARK: Initializers
    
    required public init(identifier: String, dataSource: FormTableViewCellDataSource!, delegate: FormTableViewCellDelegate!, configuration: FormTableViewCellConfiguration = FormTableViewCellConfiguration.defaultConfiguration()) {
        super.init(identifier: identifier, dataSource: dataSource, delegate: delegate, configuration: configuration)
        
        accessoryType = .DisclosureIndicator
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - FormButtonTableViewCell

public class FormButtonTableViewCell: FormTableViewCell {
    
    // MARK: Initializers
    
    required public init(identifier: String, dataSource: FormTableViewCellDataSource!, delegate: FormTableViewCellDelegate!, configuration: FormTableViewCellConfiguration = FormTableViewCellConfiguration.defaultConfiguration()) {
        super.init(identifier: identifier, dataSource: dataSource, delegate: delegate, configuration: configuration)

        valueTextView.hidden = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
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
    
    func boundingRectHeightWithMaxWidth(maxWidth: CGFloat, font: UIFont) -> CGFloat {
        let attributes: [String : AnyObject] = [NSFontAttributeName: font]
        return boundingRectHeightWithMaxWidth(maxWidth, attributes: attributes)
    }
    
    func boundingRectHeightWithMaxWidth(maxWidth: CGFloat, attributes: [String : AnyObject]) -> CGFloat {
        let maxSize = CGSizeMake(maxWidth, CGFloat.max)
        let rect = NSString(string: self).boundingRectWithSize(maxSize, options: .UsesLineFragmentOrigin, attributes: attributes, context: nil)
        return CGRectGetHeight(rect)
    }
}

// MARK: - SubClasses

public class TextView: UITextView {
    
    var placeholder: String? {
        didSet {
            placeHolderLabel.text = placeholder
            layoutSubviews()
        }
    }
    
    override public var text: String? {
        didSet {
            
        }
    }

    override public var font: UIFont? {
        didSet {
            placeHolderLabel.font = font
        }
    }
    
    override public var textAlignment: NSTextAlignment {
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
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Super
    
    override public func layoutSubviews() {
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
