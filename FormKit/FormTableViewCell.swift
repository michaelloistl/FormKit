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

// TODO: Clean up FormTableViewCellProtocol to keep only vars and funcs that are required due to dependencies

@objc public protocol FormTableViewCellDelegate {
    optional func formCell(sender: FormTableViewCell, didBecomeFirstResponder firstResponder: UIView?)
    optional func formCell(sender: FormTableViewCell, didResignFirstResponder firstResponder: UIView?)
    optional func formCell(sender: FormTableViewCell, didChangeValue value: AnyObject?)
    optional func formCell(sender: FormTableViewCell, didChangeRowHeightFrom from: CGFloat, to: CGFloat)
    optional func formCell(sender: FormTableViewCell, didChangeRowVisibilityAtIndexPath from: NSIndexPath?, to: NSIndexPath?)
    optional func formCellDidRequestNextFormTableViewCell(sender: FormTableViewCell)
    optional func formCell(sender: FormTableViewCell, didTouchUpInsideButton button: UIButton)
    optional func formCellShouldResignFirstResponder(sender: FormTableViewCell) -> Bool
    optional func formCell(sender: FormTableViewCell, shouldValidateWithIdentifier validationIdentifier: String?) -> Bool
}

public struct FormCellConfiguration {
    
    public typealias ConfigClosure = (cell: FormTableViewCell, value: AnyObject?, label: UILabel, valueView: UIView) -> Void
    
    public let config: ConfigClosure
    
    // MARK: - Initializers
    
    public init(config: ConfigClosure) {
        self.config = config
    }
    
    // MARK: - Methods
    
    public static func defaultConfiguration() -> FormCellConfiguration {
        return FormCellConfiguration(config: { (cell, value, label, valueView) -> Void in

            // Label - Error state
            cell.label.textColor = (cell.errorState) ? cell.errorLabelTextColor : cell.defaultLabelTextColor
            
            // TextField
            if let textField = valueView as? UITextField {
                textField.textColor = (cell.editable) ? UIColor.blackColor() : UIColor.grayColor()
            }
            
            // TextView
            if let textView = valueView as? UITextView {
                textView.textColor = (cell.editable) ? UIColor.blackColor() : UIColor.grayColor()
            }
        })
    }
    
    public static func emailConfiguration() -> FormCellConfiguration {
        return FormCellConfiguration(config: { (cell, value, label, valueView) -> Void in
            if let textField = valueView as? UITextField {
                textField.keyboardType = .EmailAddress
                textField.autocorrectionType = .No
                textField.autocapitalizationType = .None
            }
        })
    }

    public static func passwordConfiguration() -> FormCellConfiguration {
        return FormCellConfiguration(config: { (cell, value, label, valueView) -> Void in
            if let textField = valueView as? UITextField {
                textField.secureTextEntry = true
                textField.autocorrectionType = .No
                textField.autocapitalizationType = .None
            }
        })
    }
}

public struct FormCellValidation {
    
    public typealias ValidationClosure = (value: AnyObject?) -> Bool
    
    public let closure: ValidationClosure
    public let errorMessage: String
    public let identifier: String?
    
    // MARK: - Initializers
    
    public init(closure: ValidationClosure, errorMessage: String, identifier: String? = nil) {
        self.closure = closure
        self.errorMessage = errorMessage
        self.identifier = identifier
    }
}

public struct FormCellAction {

    public typealias ActionClosure = (value: AnyObject?) -> Void
    
    public let closure: ActionClosure
    
    // MARK: - Initializers
    
    public init(closure: ActionClosure) {
        self.closure = closure
    }
}

/**
 A structure that contains closures to set, get and write a cell value
 
 - SeeAlso: `FormTableViewCell.valueDataSource: FormCellDataSource?`
 
 - Parameter setFormCellValue: A closure object returning the value to be set as the form cells's value. The closure can be used to transform the value.
 - Parameter getFormCellValue: A closure object returning the form cell's value. The closure can be used to transform the value.
 - Parameter writeObjectValue: A closure object to write the cell's value back to an associated object. The closure object is called for all form cells via `FormManager.writeAllFormCellValues()` or all visible form cells via `FormManager.writeAllVisibleFormCellValues()`
 */
public struct FormCellDataSource {
    
    public typealias SetFormCellValueClosure = () -> AnyObject?
    public typealias GetFormCellValueClosure = (value: AnyObject?) -> AnyObject?
    public typealias DidChangeFormCellValueClosure = (value: AnyObject?) -> Void
    public typealias WriteObjectValueClosure = (value: AnyObject?) -> Void

    let setFormCellValue: SetFormCellValueClosure
    let getFormCellValue: GetFormCellValueClosure?
    let didChangeFormCellValue: DidChangeFormCellValueClosure?
    let writeObjectValue: WriteObjectValueClosure?
    
    // MARK: - Initializers
    
    public init(setFormCellValue: SetFormCellValueClosure,
                getFormCellValue: GetFormCellValueClosure? = nil,
                didChangeFormCellValue: DidChangeFormCellValueClosure? = nil,
                writeObjectValue: WriteObjectValueClosure? = nil) {
        
        self.setFormCellValue = setFormCellValue
        self.getFormCellValue = getFormCellValue
        self.didChangeFormCellValue = didChangeFormCellValue
        self.writeObjectValue = writeObjectValue
    }
}

public class FormTableViewCell: UITableViewCell, FormTextViewDataSource {
    
    public var delegate: FormTableViewCellDelegate?
    
    public var value: AnyObject? {
        didSet {
            updateUI()
            
            valueDataSource?.didChangeFormCellValue?(value: value)
            
            delegate?.formCell?(self, didChangeValue: value)
        
            cachedRowSize = CGSizeMake(CGRectGetWidth(bounds), self.rowHeight())
            
            updateConstraints()
            layoutSubviews()
        }
    }
    
    var cachedRowSize: CGSize = CGSizeZero {
        didSet {
            if oldValue.height != 0 && oldValue.height != cachedRowSize.height { // oldValue.width != cachedRowSize.width ||
                delegate?.formCell?(self, didChangeRowHeightFrom: oldValue.height, to: cachedRowSize.height)
            }
        }
    }
    
    public var identifier: String?
    
    public var visible: Bool = true {
        willSet {
            if visible != newValue {
                if let formManager = formManager {
                    fromIndexPath = formManager.indexPathForCell(self)
                }
            }
        }
        
        didSet {
            if visible != oldValue {
                resignFirstResponder()
                
                if let formManager = formManager {
                    formManager.updateVisibleFormSections()
                    toIndexPath = formManager.indexPathForCell(self)
                }
                
                delegate?.formCell?(self, didChangeRowVisibilityAtIndexPath: fromIndexPath, to: toIndexPath)
            }
        }
    }
    
    public var validate = true
    
    public var editable = true {
        didSet {
            if editable != oldValue {
                updateConstraints()
                layoutSubviews()
            }
        }
    }
    
    public var errorState: Bool = false {
        didSet {
            config()
        }
    }
    
    public var formManager: FormManager?
    
    public var configurations = [FormCellConfiguration]()
    
    public var validations = [FormCellValidation]()
    
    public var actions = [FormCellAction]()
    
    public var valueDataSource: FormCellDataSource?
    
    public var labelInsets = UIEdgeInsetsMake(0, 16, 0, 16)
    
    public var valueViewInsets = UIEdgeInsetsMake(11, 120, 11, 16)
    
    public var buttonInsets = UIEdgeInsetsZero
    
    public var bottomLineInsets = UIEdgeInsetsMake(0, 16, 0, 0)
    
    public var bottomLineWidth: CGFloat = 0
    
    public var minRowHeight: CGFloat = 44.0
    
    public var maxRowHeight: CGFloat = 44.0
    
    public var defaultLabelTextColor = UIColor.blackColor()
    
    public var errorLabelTextColor = UIColor.redColor()
    
    public var valueStringClosure: ((value: AnyObject?) -> String)?
    
    private var fromIndexPath: NSIndexPath?
    
    private var toIndexPath: NSIndexPath?
    
    public var labelVerticallyCentered = true
    
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
        _pickerDoneButton.addTarget(self, action: #selector(FormTableViewCell.pickerDoneButtonTouchedUpInside(_:)), forControlEvents: .TouchUpInside)
        
        return _pickerDoneButton
        }()
    
    public lazy var pickerClearButton: UIButton = {
        let _pickerClearButton = UIButton(type: .System)
        _pickerClearButton.translatesAutoresizingMaskIntoConstraints = false
        _pickerClearButton.setTitle("Clear", forState: .Normal)
        _pickerClearButton.addTarget(self, action: #selector(FormTableViewCell.pickerClearButtonTouchedUpInside(_:)), forControlEvents: .TouchUpInside)
        
        return _pickerClearButton
        }()
    
    public lazy var label: UILabel = {
        let _label = UILabel(forAutoLayout: ())
        _label.backgroundColor = UIColor.clearColor()
        
        return _label
        }()
    
    lazy var labelTopConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.label, attribute: .Top, relatedBy: .Equal, toItem: self.contentView, attribute: .Top, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()
    
    lazy var labelLeftConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.label, attribute: .Left, relatedBy: .Equal, toItem: self.contentView, attribute: .Left, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()
    
    lazy var labelBottomConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.label, attribute: .Bottom, relatedBy: .Equal, toItem: self.contentView, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()
    
    lazy var labelRightConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.label, attribute: .Right, relatedBy: .Equal, toItem: self.contentView, attribute: .Right, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()
    
    public lazy var valueTextView: FormTextView = {
        let _textView = FormTextView(forAutoLayout: ())
        _textView.dataSource = self
        
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
    
    lazy var valueTextViewTopConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.valueTextView, attribute: .Top, relatedBy: .Equal, toItem: self.contentView, attribute: .Top, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()
    
    lazy var valueTextViewLeftConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.valueTextView, attribute: .Left, relatedBy: .Equal, toItem: self.contentView, attribute: .Left, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()
    
    lazy var valueTextViewBottomConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.valueTextView, attribute: .Bottom, relatedBy: .Equal, toItem: self.contentView, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        _constraint.priority = 750
        
        return _constraint
    }()
    
    lazy var valueTextViewRightConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.valueTextView, attribute: .Right, relatedBy: .Equal, toItem: self.contentView, attribute: .Right, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()
    
    public lazy var bottomSeparatorView: UIView = {
        let _bottomSeparatorView = UIView(forAutoLayout: ())
        _bottomSeparatorView.backgroundColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1)
        
        return _bottomSeparatorView
        }()
    
    lazy var bottomSeparatorViewLeftConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.bottomSeparatorView, attribute: .Left, relatedBy: .Equal, toItem: self.contentView, attribute: .Left, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()

    lazy var bottomSeparatorViewRightConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.bottomSeparatorView, attribute: .Right, relatedBy: .Equal, toItem: self.contentView, attribute: .Right, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()

    lazy var bottomSeparatorViewHeightConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.bottomSeparatorView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()

    // MARK: - Initializers
    
    required public init(labelText: String?, identifier: String? = nil, configurations: [FormCellConfiguration]? = nil, delegate: FormTableViewCellDelegate?) {
        self.identifier = identifier
        self.delegate = delegate

        super.init(style: .Default, reuseIdentifier: identifier)

        contentView.addSubview(bottomSeparatorView)
        contentView.addSubview(label)
        contentView.addSubview(valueTextView)
                
        // KeyboardAccessoryView
        pickerClearButton.autoAlignAxis(.Horizontal, toSameAxisOfView: keyboardAccessoryView)
        pickerClearButton.autoPinEdge(.Left, toEdge: .Left, ofView: keyboardAccessoryView, withOffset: 16)
        pickerDoneButton.autoAlignAxis(.Horizontal, toSameAxisOfView: keyboardAccessoryView)
        pickerDoneButton.autoPinEdge(.Right, toEdge: .Right, ofView: keyboardAccessoryView, withOffset: -16)
        
        // bottomSeparatorView
        bottomSeparatorView.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: contentView)
        
        // Constraints
        contentView.addConstraints([labelTopConstraint, labelLeftConstraint, labelBottomConstraint, labelRightConstraint])
        contentView.addConstraints([valueTextViewTopConstraint, valueTextViewLeftConstraint, valueTextViewBottomConstraint, valueTextViewRightConstraint])
        contentView.addConstraints([bottomSeparatorViewLeftConstraint, bottomSeparatorViewRightConstraint, bottomSeparatorViewHeightConstraint])
        
        // Label Text
        self.label.text = labelText
        
        // Configurations
        if let configurations = configurations {
            self.addConfigurations(configurations)
        }
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
    
    public override func updateConstraints() {
        
        // Label
        labelTopConstraint.constant = labelInsets.top
        labelLeftConstraint.constant = labelInsets.left
        labelBottomConstraint.constant = -labelInsets.bottom
        labelRightConstraint.constant = -labelInsets.right
        
        labelBottomConstraint.active = labelVerticallyCentered
        
        // ValueTextView
        valueTextViewTopConstraint.constant = valueViewInsets.top
        valueTextViewLeftConstraint.constant = valueViewInsets.left
        valueTextViewBottomConstraint.constant = -valueViewInsets.bottom
        valueTextViewRightConstraint.constant = -valueViewInsets.right
        
        // BottomSeparatorView
        bottomSeparatorViewLeftConstraint.constant = bottomLineInsets.left
        bottomSeparatorViewRightConstraint.constant = bottomLineInsets.right
        bottomSeparatorViewHeightConstraint.constant = bottomLineWidth
        
        super.updateConstraints()
    }
    
    override public func layoutSubviews() {
        config()
        
        if CGRectGetWidth(bounds) != cachedRowSize.width {
            cachedRowSize = CGSizeMake(CGRectGetWidth(bounds), self.rowHeight())
        }
        
        super.layoutSubviews()
    }
    
    // MARK: - Methods
    
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
    
    public func config() {
        for configuration in configurations {
            configuration.config(cell: self, value: self.value, label: self.label, valueView: self.valueView())
            setNeedsUpdateConstraints()
        }
    }
    
    public func updateUI() {
        valueTextView.text = valueString()
    }
    
    public func valueView() -> UIView {
        return valueTextView
    }
    
    public func valueString() -> String? {
        if let valueStringClosure = valueStringClosure {
            return valueStringClosure(value: value)
        } else {
            if let stringArray = value as? [String] {
                return stringArray.joinWithSeparator(", ")
            } else if let array = value as? [AnyObject] {
                var selectableObjects = [FormSelectable]()
                for object in array {
                    if let object = object as? FormSelectable {
                        selectableObjects.append(object)
                    }
                }
                
                if selectableObjects.count > 0 {
                    let stringArray = selectableObjects.map({ $0.stringValue() })
                    return stringArray.joinWithSeparator(", ")
                }
                
                return "\(array.count)"
            } else if let string = value as? String {
                return string
            } else if let number = value as? NSNumber {
                return number.stringValue
            }
        }
        
        return nil
    }
    
    public func rowHeight() -> CGFloat {
        let maxWidth = CGRectGetWidth(UIScreen.mainScreen().bounds) - valueViewInsets.left - valueViewInsets.right
        
        var valueViewHeight: CGFloat = 0
        if let text = valueString() {
            valueViewHeight = text.boundingRectHeightWithMaxWidth(maxWidth, font: valueTextView.font!) + 1
        }
        
        let rowHeight = min(max(valueViewHeight + valueViewInsets.top + valueViewInsets.bottom, minRowHeight), max(minRowHeight, maxRowHeight))
        
        return rowHeight
    }
    
    public func setValue() -> Bool {
        if let valueDataSource = valueDataSource {
            self.value = valueDataSource.setFormCellValue()
            return true
        }
        
        return false
    }
    
    public func getValue() -> AnyObject? {
        if let valueDataSource = valueDataSource {
            return valueDataSource.getFormCellValue?(value: self.value)
        }
        
        return value
    }
    
    public func writeObjectValue() {
        valueDataSource?.writeObjectValue?(value: self.value)
    }
    
    // MARK: Actions
    
    public func pickerClearButtonTouchedUpInside(sender: UIButton) {
        
    }
    
    public func pickerDoneButtonTouchedUpInside(sender: UIButton) {
        
    }
    
    // MARK: FormCellAction
    
    public func removeAllActions() {
        actions.removeAll()
    }

    public func addAction(action: FormCellAction) {
        actions.append(action)
    }
    
    public func addAction(action: FormCellAction.ActionClosure) {
        let action = FormCellAction(closure: action)
        addAction(action)
    }
    
    // MARK: FormCellConfiguration

    public func removeAllConfigurations() {
        configurations.removeAll()
    }

    public func addConfiguration(configuration: FormCellConfiguration) {
        configurations.append(configuration)
        
        config()
    }
    
    public func addConfigurations(configurations: [FormCellConfiguration]) {
        for configuration in configurations {
            addConfiguration(configuration)
        }
    }
    
    public func addConfiguration(configuration: FormCellConfiguration.ConfigClosure) {
        let config = FormCellConfiguration(config: configuration)
        addConfiguration(config)
    }
    
    // MARK: FormCellValidation
    
    public func removeAllValidations() {
        validations.removeAll()
    }
    
    public func addValidation(validation: FormCellValidation) {
        validations.append(validation)
    }
    
    public func addValidation(validation: FormCellValidation.ValidationClosure, errorMessage: String, identifier: String? = nil) {
        let validation = FormCellValidation(closure: validation, errorMessage: errorMessage, identifier: identifier)
        validations.append(validation)
    }
    
    public func addValidationForTypeEmail(identifier: String? = nil) {
        addValidation({ (value) -> Bool in
            if let stringValue = value as? String {
                return stringValue.isValidEmail()
            }
            return false
            }, errorMessage: "Invalid email address", identifier: identifier)
    }
    
    public func addValidationForNotNilValue(identifier: String? = nil) {
        addValidation({ (value) -> Bool in
            return value != nil
            }, errorMessage: "Value must be not nil", identifier: identifier)
    }
    
    public func addValidationForTypeStringWithMinLength(length: Int, identifier: String? = nil) {
        let characterString = (length > 1) ? "characters" : "character"
        addValidation({ (value) -> Bool in
            if let stringValue = value as? String {
                return stringValue.characters.count >= length
            }
            return false
            }, errorMessage: "Must be at least \(length) \(characterString)", identifier: identifier)
    }
    
    public func addValidationForTypeStringWithMaxLength(length: Int, identifier: String? = nil) {
        let characterString = (length > 1) ? "characters" : "character"
        addValidation({ (value) -> Bool in
            if let stringValue = value as? String {
                return stringValue.characters.count <= length
            }
            return true
            }, errorMessage: "Must be at most \(length) \(characterString)", identifier: identifier)
    }
    
    public func addValidationForTypeNumericWithMinNumber(number: Double, identifier: String? = nil) {
        addValidation({ (value) -> Bool in
            if let doubleValue = value?.doubleValue {
                return doubleValue >= number
            }
            return false
            }, errorMessage: "Must be at least \(number)", identifier: identifier)
    }
    
    public func addValidationForTypeNumericWithMaxNumber(number: Double, identifier: String) {
        addValidation({ (value) -> Bool in
            if let doubleValue = value?.doubleValue {
                return doubleValue <= number
            }
            return false
            }, errorMessage: "Must be at least \(number)", identifier: identifier)
    }
    
    func validateValue() -> Array<FormCellValidation>? {
        var failedValidations = Array<FormCellValidation>()
        for validation in validations {
            let shouldValidate = delegate?.formCell?(self, shouldValidateWithIdentifier: validation.identifier) ?? true
            if shouldValidate {
                if validation.closure(value: value) == false {
                    failedValidations.append(validation)
                }
            }
        }
        
        return (failedValidations.count > 0) ? failedValidations : nil
    }
    
    // MARK: - Protocols
    
    // MARK: FormTextViewDataSource
    
    public func formTextViewMinHeight(sender: FormTextView) -> CGFloat {
        return minRowHeight - valueViewInsets.top - valueViewInsets.bottom
    }
    
    public func formTextViewMaxHeight(sender: FormTextView) -> CGFloat {
        return maxRowHeight - valueViewInsets.top - valueViewInsets.bottom
    }
    
    public func formTextViewShouldResignFirstResponder(sender: FormTextView) -> Bool {
        return delegate?.formCellShouldResignFirstResponder?(self) ?? true
    }
}

// MARK: - Extension

public extension String {
    
    public func isValidEmail() -> Bool {
        let regularExpression = try? NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}", options: [])
        let numberOfMatches = regularExpression?.numberOfMatchesInString(self, options: [], range: NSMakeRange(0, self.characters.count))
        return numberOfMatches > 0
    }
    
    private func boundingRectHeightWithMaxWidth(maxWidth: CGFloat, font: UIFont) -> CGFloat {
        let attributes: [String : AnyObject] = [NSFontAttributeName: font]
        return boundingRectHeightWithMaxWidth(maxWidth, attributes: attributes)
    }
    
    private func boundingRectHeightWithMaxWidth(maxWidth: CGFloat, attributes: [String : AnyObject]) -> CGFloat {
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
