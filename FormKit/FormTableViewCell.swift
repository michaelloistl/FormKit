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
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


public typealias FormCellActionClosure = (_ cell: FormTableViewCell, _ value: AnyObject?) -> ()

// TODO: Clean up FormTableViewCellProtocol to keep only vars and funcs that are required due to dependencies

@objc public protocol FormTableViewCellDelegate {
    @objc optional func formCell(_ sender: FormTableViewCell, didBecomeFirstResponder firstResponder: UIView?)
    @objc optional func formCell(_ sender: FormTableViewCell, didResignFirstResponder firstResponder: UIView?)
    @objc optional func formCell(_ sender: FormTableViewCell, didChangeValue value: AnyObject?)
    @objc optional func formCell(_ sender: FormTableViewCell, didChangeRowHeightFrom from: CGFloat, to: CGFloat)
    @objc optional func formCell(_ sender: FormTableViewCell, didChangeRowVisibilityAtIndexPath from: IndexPath?, to: IndexPath?)
    @objc optional func formCellDidRequestNextFormTableViewCell(_ sender: FormTableViewCell)
    @objc optional func formCell(_ sender: FormTableViewCell, didTouchUpInsideButton button: UIButton)
    @objc optional func formCellShouldResignFirstResponder(_ sender: FormTableViewCell) -> Bool
    @objc optional func formCell(_ sender: FormTableViewCell, shouldValidateWithIdentifier validationIdentifier: String?) -> Bool
    
    @objc optional func formCell(_ sender: FormTextFieldTableViewCell, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
}

public struct FormCellConfiguration {
    
    public typealias ConfigClosure = (_ cell: FormTableViewCell, _ value: AnyObject?, _ label: UILabel, _ valueView: UIView) -> Void
    
    public let config: ConfigClosure
    
    // MARK: - Initializers
    
    public init(config: @escaping ConfigClosure) {
        self.config = config
    }
    
    // MARK: - Methods
    
    public static func defaultConfiguration() -> FormCellConfiguration {
        return FormCellConfiguration(config: { (cell, value, label, valueView) -> Void in

            // Label - Error state
            cell.label.textColor = (cell.errorState) ? cell.errorLabelTextColor : cell.defaultLabelTextColor
            
            // TextField
            if let textField = valueView as? UITextField {
                textField.textColor = (cell.editable) ? UIColor.black : UIColor.gray
            }
            
            // TextView
            if let textView = valueView as? UITextView {
                textView.textColor = (cell.editable) ? UIColor.black : UIColor.gray
            }
        })
    }
    
    public static func emailConfiguration() -> FormCellConfiguration {
        return FormCellConfiguration(config: { (cell, value, label, valueView) -> Void in
            if let textField = valueView as? UITextField {
                textField.keyboardType = .emailAddress
                textField.autocorrectionType = .no
                textField.autocapitalizationType = .none
            }
        })
    }

    public static func passwordConfiguration() -> FormCellConfiguration {
        return FormCellConfiguration(config: { (cell, value, label, valueView) -> Void in
            if let textField = valueView as? UITextField {
                textField.isSecureTextEntry = true
                textField.autocorrectionType = .no
                textField.autocapitalizationType = .none
            }
        })
    }
}

public struct FormCellValidation {
    
    public typealias ValidationClosure = (_ value: AnyObject?) -> Bool
    
    public let closure: ValidationClosure
    public let errorMessage: String
    public let identifier: String?
    
    // MARK: - Initializers
    
    public init(closure: @escaping ValidationClosure, errorMessage: String, identifier: String? = nil) {
        self.closure = closure
        self.errorMessage = errorMessage
        self.identifier = identifier
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
    public typealias GetFormCellValueClosure = (_ value: AnyObject?) -> AnyObject?
    public typealias DidChangeFormCellValueClosure = (_ oldValue: AnyObject?, _ newValue: AnyObject?) -> Void
    public typealias WriteObjectValueClosure = (_ value: AnyObject?) -> Void

    public let setFormCellValue: SetFormCellValueClosure
    public let getFormCellValue: GetFormCellValueClosure?
    public let didChangeFormCellValue: DidChangeFormCellValueClosure?
    public let writeObjectValue: WriteObjectValueClosure?
    
    // MARK: - Initializers
    
    public init(setFormCellValue: @escaping SetFormCellValueClosure,
                getFormCellValue: GetFormCellValueClosure? = nil,
                didChangeFormCellValue: DidChangeFormCellValueClosure? = nil,
                writeObjectValue: WriteObjectValueClosure? = nil) {
        
        self.setFormCellValue = setFormCellValue
        self.getFormCellValue = getFormCellValue
        self.didChangeFormCellValue = didChangeFormCellValue
        self.writeObjectValue = writeObjectValue
    }
}

open class FormTableViewCell: UITableViewCell, FormTextViewDataSource {
    
    open var delegate: FormTableViewCellDelegate?
    
    open var value: AnyObject? {
        didSet {
            updateUI()
            
            delegate?.formCell?(self, didChangeValue: value)
            
            valueDataSource?.didChangeFormCellValue?(oldValue, value)
            
            cachedRowSize = CGSize(width: bounds.width, height: self.rowHeight())
            
            updateConstraints()
            layoutSubviews()
        }
    }
    
    var cachedRowSize: CGSize = CGSize.zero {
        didSet {
            if oldValue.height != 0 && oldValue.height != cachedRowSize.height { // oldValue.width != cachedRowSize.width ||
                delegate?.formCell?(self, didChangeRowHeightFrom: oldValue.height, to: cachedRowSize.height)
            }
        }
    }
    
    open var identifier: String?
    
    open var visible: Bool = true {
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
    
    open var validate = true
    
    open var editable = true {
        didSet {
            if editable != oldValue {
                updateConstraints()
                layoutSubviews()
            }
        }
    }
    
    open var errorState: Bool = false {
        didSet {
            config()
        }
    }
    
    open var formManager: FormManager?
    
    open var configurations = [FormCellConfiguration]()
    
    open var validations = [FormCellValidation]()
    
    open var valueDataSource: FormCellDataSource?
    
    open var labelInsets = UIEdgeInsetsMake(0, 16, 0, 16)
    
    open var valueViewInsets = UIEdgeInsetsMake(11, 120, 11, 16)
    
    open var buttonInsets = UIEdgeInsets.zero
    
    open var bottomLineInsets = UIEdgeInsetsMake(0, 16, 0, 100)
    
    open var bottomLineWidth: CGFloat = 0
    
    open var minRowHeight: CGFloat = 44.0
    
    open var maxRowHeight: CGFloat = 44.0
    
    open var defaultLabelTextColor = UIColor.black
    
    open var errorLabelTextColor = UIColor.red
    
    open var valueStringClosure: ((_ value: AnyObject?) -> String)?
    
    fileprivate var fromIndexPath: IndexPath?
    
    fileprivate var toIndexPath: IndexPath?
    
    open var labelVerticallyCentered = true
    
    open var action: FormCellActionClosure?
    
    open lazy var keyboardAccessoryView: KeyboardAccessoryView = {
        let _keyboardAccessoryView = KeyboardAccessoryView(frame: CGRect(x: 0, y: 0, width: self.contentView.bounds.width, height: 44))
        _keyboardAccessoryView.addSubview(self.pickerClearButton)
        _keyboardAccessoryView.addSubview(self.pickerDoneButton)
        
        return _keyboardAccessoryView
        }()
    
    open lazy var pickerDoneButton: UIButton = {
        let _pickerDoneButton = UIButton(type: .system)
        _pickerDoneButton.translatesAutoresizingMaskIntoConstraints = false
        _pickerDoneButton.setTitle("Done", for: UIControlState())
        _pickerDoneButton.addTarget(self, action: #selector(pickerDoneButtonTouchedUpInside(_:)), for: .touchUpInside)
        
        return _pickerDoneButton
        }()
    
    open lazy var pickerClearButton: UIButton = {
        let _pickerClearButton = UIButton(type: .system)
        _pickerClearButton.translatesAutoresizingMaskIntoConstraints = false
        _pickerClearButton.setTitle("Clear", for: UIControlState())
        _pickerClearButton.addTarget(self, action: #selector(pickerClearButtonTouchedUpInside(_:)), for: .touchUpInside)
        
        return _pickerClearButton
        }()
    
    open lazy var label: UILabel = {
        let _label = UILabel(forAutoLayout: ())
        _label.backgroundColor = UIColor.clear
        
        return _label
        }()
    
    lazy var labelTopConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.label, attribute: .top, relatedBy: .equal, toItem: self.contentView, attribute: .top, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()
    
    lazy var labelLeftConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.label, attribute: .left, relatedBy: .equal, toItem: self.contentView, attribute: .left, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()
    
    lazy var labelBottomConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.label, attribute: .bottom, relatedBy: .equal, toItem: self.contentView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()
    
    lazy var labelRightConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.label, attribute: .right, relatedBy: .equal, toItem: self.contentView, attribute: .right, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()
    
    open lazy var valueTextView: FormTextView = {
        let _textView = FormTextView(forAutoLayout: ())
        _textView.dataSource = self
        
        _textView.textColor = UIColor.gray
        _textView.font = self.label.font
        _textView.textAlignment = .right
        _textView.backgroundColor = UIColor.clear
        
        _textView.isEditable = false
        _textView.isSelectable = true
        _textView.isScrollEnabled = false
        _textView.isUserInteractionEnabled = false
        
        _textView.contentInset = UIEdgeInsets.zero
        _textView.textContainerInset = UIEdgeInsets.zero
        _textView.textContainer.lineFragmentPadding = 0

        return _textView
    }()
    
    lazy var valueTextViewTopConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.valueTextView, attribute: .top, relatedBy: .equal, toItem: self.contentView, attribute: .top, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()
    
    lazy var valueTextViewLeftConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.valueTextView, attribute: .left, relatedBy: .equal, toItem: self.contentView, attribute: .left, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()
    
    lazy var valueTextViewBottomConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.valueTextView, attribute: .bottom, relatedBy: .equal, toItem: self.contentView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        _constraint.priority = 750
        
        return _constraint
    }()
    
    lazy var valueTextViewRightConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.valueTextView, attribute: .right, relatedBy: .equal, toItem: self.contentView, attribute: .right, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()
    
    open lazy var bottomSeparatorView: UIView = {
        let _bottomSeparatorView = UIView(forAutoLayout: ())
        _bottomSeparatorView.backgroundColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1)
        
        return _bottomSeparatorView
        }()
    
    lazy var bottomSeparatorViewLeftConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.bottomSeparatorView, attribute: .left, relatedBy: .equal, toItem: self.contentView, attribute: .left, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()

    lazy var bottomSeparatorViewRightConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.bottomSeparatorView, attribute: .right, relatedBy: .equal, toItem: self.contentView, attribute: .right, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()

    lazy var bottomSeparatorViewHeightConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.bottomSeparatorView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()

    // MARK: - Initializers
    
    required public init(labelText: String?, identifier: String? = nil, configurations: [FormCellConfiguration]? = nil, delegate: FormTableViewCellDelegate?) {
        self.identifier = identifier
        self.delegate = delegate

        super.init(style: .default, reuseIdentifier: identifier)

        contentView.addSubview(bottomSeparatorView)
        contentView.addSubview(label)
        contentView.addSubview(valueTextView)
                
        // KeyboardAccessoryView
        pickerClearButton.autoAlignAxis(.horizontal, toSameAxisOf: keyboardAccessoryView)
        pickerClearButton.autoPinEdge(.left, to: .left, of: keyboardAccessoryView, withOffset: 16)
        pickerDoneButton.autoAlignAxis(.horizontal, toSameAxisOf: keyboardAccessoryView)
        pickerDoneButton.autoPinEdge(.right, to: .right, of: keyboardAccessoryView, withOffset: -16)
        
        // bottomSeparatorView
        bottomSeparatorView.autoPinEdge(.bottom, to: .bottom, of: contentView)
        
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
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Super
    
    override open func becomeFirstResponder() -> Bool {
        errorState = false
        return false
    }
    
    override open func resignFirstResponder() -> Bool {
        return false
    }
    
    open override func updateConstraints() {
        
        // Label
        labelTopConstraint.constant = labelInsets.top
        labelLeftConstraint.constant = labelInsets.left
        labelBottomConstraint.constant = -labelInsets.bottom
        labelRightConstraint.constant = -labelInsets.right
        
        labelBottomConstraint.isActive = labelVerticallyCentered
        
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
    
    override open func layoutSubviews() {
        config()
        
        if bounds.width != cachedRowSize.width {
            cachedRowSize = CGSize(width: bounds.width, height: self.rowHeight())
        }
        
        super.layoutSubviews()
    }
    
    // MARK: - Methods
    
    open func isEmpty() -> Bool {
        return value == nil
    }
    
    open func isValid(_ showErrorState: Bool = true) -> Bool {
        if validate {
            let isValid = validateValue() == nil
            if showErrorState {
                errorState = !isValid
            }
            return isValid
        }
        
        return true
    }
    
    open func config() {
        for configuration in configurations {
            configuration.config(self, self.value, self.label, self.valueView())
            setNeedsUpdateConstraints()
        }
    }
    
    open func updateUI() {
        valueTextView.text = valueString()
    }
    
    open func valueView() -> UIView {
        return valueTextView
    }
    
    open func valueString() -> String? {
        if let valueStringClosure = valueStringClosure {
            return valueStringClosure(value)
        } else {
            if let stringArray = value as? [String] {
                return stringArray.joined(separator: ", ")
            }
//            else if let array = value as? [AnyObject] {
//                var selectableObjects = [FormSelectable]()
//                for object in array {
//                    if let object = object as? FormSelectable {
//                        selectableObjects.append(object)
//                    }
//                }
//                
//                if selectableObjects.count > 0 {
//                    let stringArray = selectableObjects.map({ $0.stringValue() })
//                    return stringArray.joinWithSeparator(", ")
//                }
//                
//                return "\(array.count)"
//            }
            else if let string = value as? String {
                return string
            } else if let number = value as? NSNumber {
                return number.stringValue
            }
        }
        
        return nil
    }
    
    open func rowHeight() -> CGFloat {
        let maxWidth = UIScreen.main.bounds.width - valueViewInsets.left - valueViewInsets.right
        
        var valueViewHeight: CGFloat = 0
        if let text = valueString() {
            valueViewHeight = text.boundingRectHeightWithMaxWidth(maxWidth, font: valueTextView.font!) + 1
        }
        
        let rowHeight = min(max(valueViewHeight + valueViewInsets.top + valueViewInsets.bottom, minRowHeight), max(minRowHeight, maxRowHeight))
        
        return rowHeight
    }
    
    open func setValue() -> Bool {
        if let valueDataSource = valueDataSource {
            self.value = valueDataSource.setFormCellValue()
            return true
        }
        
        return false
    }
    
    open func getValue() -> AnyObject? {
        if let valueDataSource = valueDataSource {
            return valueDataSource.getFormCellValue?(self.value)
        }
        
        return value
    }
    
    open func writeObjectValue() {
        valueDataSource?.writeObjectValue?(self.value)
    }
    
    // MARK: Actions
    
    open func pickerClearButtonTouchedUpInside(_ sender: UIButton) {
        
    }
    
    open func pickerDoneButtonTouchedUpInside(_ sender: UIButton) {
        
    }
    
    // MARK: FormCellConfiguration

    open func removeAllConfigurations() {
        configurations.removeAll()
    }

    open func addConfiguration(_ configuration: FormCellConfiguration) {
        configurations.append(configuration)
        
        config()
    }
    
    open func addConfigurations(_ configurations: [FormCellConfiguration]) {
        for configuration in configurations {
            addConfiguration(configuration)
        }
    }
    
    open func addConfiguration(_ configuration: @escaping FormCellConfiguration.ConfigClosure) {
        let config = FormCellConfiguration(config: configuration)
        addConfiguration(config)
    }
    
    // MARK: FormCellValidation
    
    open func removeAllValidations() {
        validations.removeAll()
    }
    
    open func addValidation(_ validation: FormCellValidation) {
        validations.append(validation)
    }
    
    open func addValidation(_ validation: @escaping FormCellValidation.ValidationClosure, errorMessage: String, identifier: String? = nil) {
        let validation = FormCellValidation(closure: validation, errorMessage: errorMessage, identifier: identifier)
        validations.append(validation)
    }
    
    open func addValidationForTypeEmail(_ identifier: String? = nil) {
        addValidation({ (value) -> Bool in
            if let stringValue = value as? String {
                return stringValue.isValidEmail()
            }
            return false
            }, errorMessage: "Invalid email address", identifier: identifier)
    }
    
    open func addValidationForNotNilValue(_ identifier: String? = nil) {
        addValidation({ (value) -> Bool in
            return value != nil
            }, errorMessage: "Value must be not nil", identifier: identifier)
    }
    
    open func addValidationForTypeStringWithMinLength(_ length: Int, identifier: String? = nil) {
        let characterString = (length > 1) ? "characters" : "character"
        addValidation({ (value) -> Bool in
            if let stringValue = value as? String {
                return stringValue.characters.count >= length
            }
            return false
            }, errorMessage: "Must be at least \(length) \(characterString)", identifier: identifier)
    }
    
    open func addValidationForTypeStringWithMaxLength(_ length: Int, identifier: String? = nil) {
        let characterString = (length > 1) ? "characters" : "character"
        addValidation({ (value) -> Bool in
            if let stringValue = value as? String {
                return stringValue.characters.count <= length
            }
            return true
            }, errorMessage: "Must be at most \(length) \(characterString)", identifier: identifier)
    }
    
    open func addValidationForTypeNumericWithMinNumber(_ number: Double, identifier: String? = nil) {
        addValidation({ (value) -> Bool in
            if let doubleValue = value?.doubleValue {
                return doubleValue >= number
            }
            return false
            }, errorMessage: "Must be at least \(number)", identifier: identifier)
    }
    
    open func addValidationForTypeNumericWithMaxNumber(_ number: Double, identifier: String) {
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
                if validation.closure(value) == false {
                    failedValidations.append(validation)
                }
            }
        }
        
        return (failedValidations.count > 0) ? failedValidations : nil
    }
    
    // MARK: - Protocols
    
    // MARK: FormTextViewDataSource
    
    open func formTextViewMinHeight(_ sender: FormTextView) -> CGFloat {
        return minRowHeight - valueViewInsets.top - valueViewInsets.bottom
    }
    
    open func formTextViewMaxHeight(_ sender: FormTextView) -> CGFloat {
        return maxRowHeight - valueViewInsets.top - valueViewInsets.bottom
    }
    
    open func formTextViewShouldResignFirstResponder(_ sender: FormTextView) -> Bool {
        return delegate?.formCellShouldResignFirstResponder?(self) ?? true
    }
}

// MARK: - Extension

public extension String {
    
    public func isValidEmail() -> Bool {
        let regularExpression = try? NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}", options: [])
        let numberOfMatches = regularExpression?.numberOfMatches(in: self, options: [], range: NSMakeRange(0, self.characters.count))
        return numberOfMatches > 0
    }
    
    fileprivate func boundingRectHeightWithMaxWidth(_ maxWidth: CGFloat, font: UIFont) -> CGFloat {
        let attributes: [String : AnyObject] = [NSFontAttributeName: font]
        return boundingRectHeightWithMaxWidth(maxWidth, attributes: attributes)
    }
    
    fileprivate func boundingRectHeightWithMaxWidth(_ maxWidth: CGFloat, attributes: [String : AnyObject]) -> CGFloat {
        let maxSize = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        let rect = NSString(string: self).boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        return rect.height
    }
}

open class KeyboardAccessoryView: UIInputView {
    
    override init(frame: CGRect, inputViewStyle: UIInputViewStyle) {
        super.init(frame: frame, inputViewStyle: UIInputViewStyle.keyboard)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
