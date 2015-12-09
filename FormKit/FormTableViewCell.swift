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
    var identifier: String { get set }
    var visible: Bool { get set }
    var errorState: Bool { get set }
    
    func isFirstResponder() -> Bool
    func becomeFirstResponder() -> Bool
    func resignFirstResponder() -> Bool
    
    func isEmpty() -> Bool
    func isValid(showErrorState: Bool) -> Bool

    func config()
    func updateUI()
    
    func valueView() -> UIView
    func valueString() -> String?
    func rowHeight() -> CGFloat
    
    func setValue()
    func getValue() -> AnyObject?
    
    func pickerClearButtonTouchedUpInside(sender: UIButton)
    func pickerDoneButtonTouchedUpInside(sender: UIButton)
}

public protocol FormTableViewCellDataSource {
    func formManagerForFormCell(sender: FormTableViewCell, identifier: String) -> FormManager?
    
    func valueForFormCell(sender: FormTableViewCell, identifier: String) -> AnyObject?

    func labelEdgeInsetsForFormCell(sender: FormTableViewCell, identifier: String) -> UIEdgeInsets
    func valueEdgeInsetsForFormCell(sender: FormTableViewCell, identifier: String) -> UIEdgeInsets
    func buttonEdgeInsetsForFormCell(sender: FormTableViewCell, identifier: String) -> UIEdgeInsets
    
    func bottomLineEdgeInsetsForFormCell(sender: FormTableViewCell, identifier: String) -> UIEdgeInsets
    func bottomLineWidthForFormCell(sender: FormTableViewCell, identifier: String) -> CGFloat
    
    func defaultConfigurationForFormCell(sender: FormTableViewCell, identifier: String) -> FormTableViewCellConfiguration?
    
    func valueTransformerForKey(key: String!, identifier: String?) -> NSValueTransformer!
}

public protocol FormTableViewCellDelegate {
    func formCell(sender: FormTableViewCell, identifier: String, didBecomeFirstResponder firstResponder: UIView?)
    
    func formCell(sender: FormTableViewCell, identifier: String, didChangeValue value: AnyObject?, valueKeyPath: String?)
    
    func formCell(sender: FormTableViewCell, identifier: String, didChangeRowHeightFrom from: CGFloat, to: CGFloat)
    
    func formCell(sender: FormTableViewCell, identifier: String, didChangeRowVisibilityAtIndexPath from: NSIndexPath?, to: NSIndexPath?)

    func formCellDidRequestNextFormTableViewCell(sender: FormTableViewCell, identifier: String)
    
    func formCell(sender: FormTableViewCell, identifier: String, shouldValidateWithIdentifier validationIdentifier: String) -> Bool
    
    func formCell(sender: FormTableViewCell, identifier: String, didTouchUpInsideButton button: UIButton)
}

public struct FormTableViewCellConfiguration {
    
    let config: (cell: FormTableViewCell, value: AnyObject?, identifier: String, label: UILabel, valueView: UIView) -> Void
    
    // MARK: - Initializers
    
    public init(config: (cell: FormTableViewCell, value: AnyObject?, identifier: String, label: UILabel, valueView: UIView) -> Void) {
        self.config = config
    }
    
    // MARK: - Methods
    
    public static func defaultConfiguration() -> FormTableViewCellConfiguration {
        return FormTableViewCellConfiguration(config: { (cell, value, identifier, label, valueView) -> Void in

            // Label - Error state
            cell.label.textColor = (cell.errorState) ? cell.errorLabelTextColor : cell.defaultLabelTextColor
            
            // TextField
            if let textField = valueView as? UITextField {
                textField.textColor = (cell.isEditable) ? UIColor.blackColor() : UIColor.grayColor()
            }
            
            // TextView
            if let textView = valueView as? UITextView {
                textView.textColor = (cell.isEditable) ? UIColor.blackColor() : UIColor.grayColor()
            }
        })
    }
    
    public static func emailConfiguration() -> FormTableViewCellConfiguration {
        return FormTableViewCellConfiguration(config: { (cell, value, identifier, label, valueView) -> Void in
            if let textField = valueView as? UITextField {
                textField.keyboardType = .EmailAddress
                textField.autocorrectionType = .No
                textField.autocapitalizationType = .None
            }
        })
    }

    public static func passwordConfiguration() -> FormTableViewCellConfiguration {
        return FormTableViewCellConfiguration(config: { (cell, value, identifier, label, valueView) -> Void in
            if let textField = valueView as? UITextField {
                textField.secureTextEntry = true
                textField.autocorrectionType = .No
                textField.autocapitalizationType = .None
            }
        })
    }
}

public struct FormTableViewCellValidation {
    let closure: (value: AnyObject?) -> Bool
    let errorMessage: String
    let identifier: String
}

public struct FormTableViewCellAction {
    let closure: (value: AnyObject?) -> Void
    let identifier: String
    
    // MARK: - Initializers
    
    public init(closure: (value: AnyObject?) -> Void, identifier: String) {
        self.closure = closure
        self.identifier = identifier
    }
}

public class FormTableViewCell: UITableViewCell, FormTableViewCellProtocol {
    
    public var identifier: String
    
    public var valueKeyPath: String?

    public var value: AnyObject? {
        didSet {
            updateUI()
            
            delegate?.formCell(self, identifier: identifier, didChangeValue: value, valueKeyPath: valueKeyPath)
            
            let oldRowHeight = CGRectGetHeight(bounds)
            let newRowHeight = self.rowHeight()
            
            if oldRowHeight != newRowHeight {
                delegate?.formCell(self, identifier: identifier, didChangeRowHeightFrom: oldRowHeight, to: newRowHeight)
            }
            
            config()
        }
    }
    
    public var validate = true

    public var isEditable = true {
        didSet {
            layoutSubviews()
        }
    }
    
    public var configurations = [FormTableViewCellConfiguration.defaultConfiguration()]
    
    public var defaultCellBackgroundColor = UIColor.whiteColor()
    public var errorCellBackgroundColor = UIColor.redColor().colorWithAlphaComponent(0.2)
    
    public var defaultLabelTextColor = UIColor.blackColor()
    public var errorLabelTextColor = UIColor.redColor()
    
    public var validations = Array<FormTableViewCellValidation>()
    public var actions = Array<FormTableViewCellAction>()

    public var dataSource: FormTableViewCellDataSource?
    public var delegate: FormTableViewCellDelegate?
    
    private var fromIndexPath: NSIndexPath?
    private var toIndexPath: NSIndexPath?
    
    public var visible: Bool = true {
        willSet {
            if visible != newValue {
                if let formManager = dataSource?.formManagerForFormCell(self, identifier: identifier) {
                    fromIndexPath = formManager.indexPathForCell(self)
                }
            }
        }
        
        didSet {
            if visible != oldValue {
                resignFirstResponder()
                
                if let formManager = dataSource?.formManagerForFormCell(self, identifier: identifier) {
                    formManager.updateVisibleFormSections()
                    toIndexPath = formManager.indexPathForCell(self)
                }
                
                delegate?.formCell(self, identifier: identifier, didChangeRowVisibilityAtIndexPath: fromIndexPath, to: toIndexPath)
            }
        }
    }
    
    public var errorState: Bool = false {
        didSet {
            config()
        }
    }
    
    public var minRowHeight: CGFloat = 44.0
    public var maxRowHeight: CGFloat = 44.0
    
    public var labeVerticallyCentered = false
    
    public lazy var keyboardAccessoryView: KeyboardAccessoryView = {
        let _keyboardAccessoryView = KeyboardAccessoryView(frame: CGRectMake(0, 0, CGRectGetWidth(self.contentView.bounds), 44))
        _keyboardAccessoryView.addSubview(self.pickerClearButton)
        _keyboardAccessoryView.addSubview(self.pickerDoneButton)
        
        return _keyboardAccessoryView
        }()
    
    public lazy var pickerDoneButton: UIButton = {
        let _pickerDoneButton = UIButton(type: .System)
        _pickerDoneButton.translatesAutoresizingMaskIntoConstraints = false
        _pickerDoneButton.setTitle("Done", forState: .Normal)
        _pickerDoneButton.addTarget(self, action: Selector("pickerDoneButtonTouchedUpInside:"), forControlEvents: .TouchUpInside)
        
        return _pickerDoneButton
        }()
    
    public lazy var pickerClearButton: UIButton = {
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
        _textView.backgroundColor = UIColor.clearColor()
        
        _textView.editable = false
        _textView.selectable = true
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
        
        return _bottomSeparatorView
        }()
    
    // MARK: - Initializers
    
    required public init(identifier: String, dataSource: FormTableViewCellDataSource!, delegate: FormTableViewCellDelegate!) {
        self.identifier = identifier
        self.dataSource = dataSource
        self.delegate = delegate
        
        super.init(style: .Default, reuseIdentifier: "")
        
        if let configuration = dataSource?.defaultConfigurationForFormCell(self, identifier: identifier) {
            self.configurations.append(configuration)
        }
        
        contentView.addSubview(bottomSeparatorView)
        contentView.addSubview(label)
        contentView.addSubview(valueTextView)
                
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

    // MARK: - Super
    
    override public func becomeFirstResponder() -> Bool {
        errorState = false
        return false
    }
    
    override public func resignFirstResponder() -> Bool {
        return false
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let labelEdgeInsets = dataSource?.labelEdgeInsetsForFormCell(self, identifier: identifier) ?? UIEdgeInsetsZero
        let valueEdgeInsets = dataSource?.valueEdgeInsetsForFormCell(self, identifier: identifier) ?? UIEdgeInsetsZero
        let bottomLineEdgeInsets = dataSource?.bottomLineEdgeInsetsForFormCell(self, identifier: identifier) ?? UIEdgeInsetsZero
        let bottomLineWidth = dataSource?.bottomLineWidthForFormCell(self, identifier: identifier) ?? 0
        
        // Label
        let labelOriginX = labelEdgeInsets.left
        let labelOriginY = labelEdgeInsets.top
        let labelSizeWidth = CGRectGetWidth(bounds) - labelEdgeInsets.left - labelEdgeInsets.right
        
        var labelSizeHeight = minRowHeight
        if labeVerticallyCentered {
            labelSizeHeight = CGRectGetHeight(bounds) - labelEdgeInsets.top - labelEdgeInsets.bottom
        }
        
        label.frame = CGRectMake(labelOriginX, labelOriginY, labelSizeWidth, labelSizeHeight)
        
        // ValueTextView
        let sizeWidth = CGRectGetWidth(contentView.bounds) - valueEdgeInsets.left - valueEdgeInsets.right
        let sizeHeight = CGRectGetHeight(contentView.bounds) - valueEdgeInsets.top - valueEdgeInsets.bottom
        
        valueTextView.frame = CGRectMake(valueEdgeInsets.left, valueEdgeInsets.top, sizeWidth, sizeHeight)
        
        // BottomSeparatorView
        let bottomSeparatorViewOriginX = bottomLineEdgeInsets.left
        let bottomSeparatorViewOriginY = CGRectGetHeight(bounds) - bottomLineWidth
        let bottomSeparatorViewWidth = CGRectGetWidth(bounds) - bottomLineEdgeInsets.left - bottomLineEdgeInsets.right
        let bottomSeparatorViewHeight = bottomLineWidth
        
        bottomSeparatorView.frame = CGRectMake(bottomSeparatorViewOriginX, bottomSeparatorViewOriginY, bottomSeparatorViewWidth, bottomSeparatorViewHeight)
        
        config()
    }
    
    // MARK: - Methods
    
    // MARK: FormTableViewCellAction
    
    public func removeAllActions() {
        actions.removeAll()
    }

    public func addAction(action: FormTableViewCellAction) {
        actions.append(action)
    }
    
    public func addConfiguration(configuration: FormTableViewCellConfiguration) {
        configurations.append(configuration)
    }
    
    public func addConfigurations(configurations: [FormTableViewCellConfiguration]) {
        for configuration in configurations {
            addConfiguration(configuration)
        }
    }
    
    // MARK: FormTableViewCellValidation
    
    func validateValue() -> Array<FormTableViewCellValidation>? {
        var failedValidations = Array<FormTableViewCellValidation>()
        for validation in validations {
            let shouldValidate = delegate?.formCell(self, identifier: identifier, shouldValidateWithIdentifier: validation.identifier) ?? true
            if shouldValidate {
                if validation.closure(value: value) == false {
                    failedValidations.append(validation)
                }
            }
        }
        
        return (failedValidations.count > 0) ? failedValidations : nil
    }
    
    public func addValidation(validation: (value: AnyObject?) -> Bool, withErrorMessage errorMessage: String, identifier: String = "") {
        let validation = FormTableViewCellValidation(closure: validation, errorMessage: errorMessage, identifier: identifier)
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
    
    // MARK: FormTableViewCellConfiguration
    
    // MARK: - Protocols
    
    public func valueView() -> UIView {
        return valueTextView
    }
    
    public func config() {
        for configuration in configurations {
            configuration.config(cell: self, value: self.value, identifier: self.identifier, label: self.label, valueView: self.valueView())
        }
    }
    
    public func setValue() {
        let value = dataSource?.valueForFormCell(self, identifier: identifier)
        
        // ValueTransformer
        if let valueKeyPath = valueKeyPath, valueTransformer = dataSource?.valueTransformerForKey(valueKeyPath, identifier: identifier) {
            if let value: AnyObject = valueTransformer.transformedValue(value) {
                self.value = value
            }
        } else {
            self.value = value
        }
    }
    
    public func getValue() -> AnyObject? {

        // ValueTransformer
        if let valueKeyPath = valueKeyPath, valueTransformer = dataSource?.valueTransformerForKey(valueKeyPath, identifier: identifier) {
            if let value = valueTransformer.reverseTransformedValue(value) {
                return value
            }
        }
        
        return value
    }
    
    public func updateUI() {
        valueTextView.text = valueString()
    }
    
    public func isEmpty() -> Bool {
        return value == nil
    }
    
    public func isValid(showErrorState: Bool = true) -> Bool {
        if validate {
            let isValid = validateValue() == nil
            if showErrorState {
                errorState = !isValid
            }
            return isValid
        }
        
        return true
    }
    
    public func rowHeight() -> CGFloat {
        let valueEdgeInsets = dataSource?.valueEdgeInsetsForFormCell(self, identifier: identifier) ?? UIEdgeInsetsZero
        let maxWidth = CGRectGetWidth(UIScreen.mainScreen().bounds) - valueEdgeInsets.left - valueEdgeInsets.right
        
        var valueLabelHeight: CGFloat = 0
        if let text = valueString() {
            valueLabelHeight = text.boundingRectHeightWithMaxWidth(maxWidth, font: valueTextView.font!) + 1
        }
        
        let rowHeight = min(max(valueLabelHeight + valueEdgeInsets.top + valueEdgeInsets.bottom, minRowHeight), maxRowHeight)
        
        return rowHeight
    }
    
    public func valueString() -> String? {
        if let stringArray = value as? [String] {
            return stringArray.joinWithSeparator(", ")
        } else if let array = value as? [AnyObject] {
            return "\(array.count)"
        } else if let string = value as? String {
            return string
        } else if let number = value as? NSNumber {
            return number.stringValue
        }
        
        return nil
    }
    
    // MARK: Actions
    
    public func pickerClearButtonTouchedUpInside(sender: UIButton) {

    }
    
    public func pickerDoneButtonTouchedUpInside(sender: UIButton) {

    }
}

// MARK: - Extension

extension String {
    
    func isValidEmail() -> Bool {
        let regularExpression = try? NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}", options: [])
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

public class KeyboardAccessoryView: UIInputView {
    
    override init(frame: CGRect, inputViewStyle: UIInputViewStyle) {
        super.init(frame: frame, inputViewStyle: UIInputViewStyle.Keyboard)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
