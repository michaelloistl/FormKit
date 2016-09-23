//
//  FormTextViewTableViewCell.swift
//  FormKit
//
//  Created by Michael Loistl on 14/11/2015.
//  Copyright © 2015 Aplo. All rights reserved.
//

import Foundation
import UIKit

public class FormTextViewTableViewCell: FormTextInputTableViewCell, NSLayoutManagerDelegate, UITextViewDelegate {
    
    public var allowLineBreak = true
    
    public var placeholder: String? {
        didSet {
            placeholderLabel.text = placeholder
        }
    }
    
    var placeholderLabelOffset = UIOffsetZero
    
    var textViewWidth: CGFloat {
        return CGRectGetWidth(contentView.bounds) - valueViewInsets.left - valueViewInsets.right
    }
    
    var textViewHeight: CGFloat {
        return textView.sizeThatFits(CGSizeMake(textViewWidth, CGFloat.max)).height
    }
    
    public lazy var textView: FormTextView = {
        let _textView = FormTextView(forAutoLayout: ())
        _textView.delegate = self
        _textView.dataSource = self
        _textView.font = self.textLabel?.font
        _textView.backgroundColor = UIColor.clearColor()
        
        _textView.contentInset = UIEdgeInsetsZero
        _textView.textContainerInset = UIEdgeInsetsZero
        _textView.textContainer.lineFragmentPadding = 0

        return _textView
    }()
    
    public lazy var placeholderLabel: UILabel = {
        let _label = UILabel(forAutoLayout: ())
        _label.font = self.textLabel?.font
        _label.textColor = UIColor.lightGrayColor()
        
        return _label
    }()
    
    lazy var textViewTopConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.textView, attribute: .Top, relatedBy: .Equal, toItem: self.contentView, attribute: .Top, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()
    
    lazy var textViewLeftConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.textView, attribute: .Left, relatedBy: .Equal, toItem: self.contentView, attribute: .Left, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()
    
    lazy var textViewBottomConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.textView, attribute: .Bottom, relatedBy: .Equal, toItem: self.contentView, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        _constraint.priority = 750
        
        return _constraint
    }()
    
    lazy var textViewRightConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.textView, attribute: .Right, relatedBy: .Equal, toItem: self.contentView, attribute: .Right, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()
    
    lazy var placeholderLabelTopConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.placeholderLabel, attribute: .Top, relatedBy: .Equal, toItem: self.contentView, attribute: .Top, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()
    
    lazy var placeholderLabelLeftConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.placeholderLabel, attribute: .Left, relatedBy: .Equal, toItem: self.contentView, attribute: .Left, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()
    
    // MARK: Initializers
    
    required public init(labelText: String?, identifier: String? = nil, configurations: [FormCellConfiguration]? = nil, delegate: FormTableViewCellDelegate?) {
        super.init(labelText: labelText, identifier: identifier, configurations: configurations, delegate: delegate)
        
        maxRowHeight = 88.0
        
        contentView.insertSubview(textView, atIndex: 0)
        contentView.insertSubview(placeholderLabel, atIndex: 0)
        
        contentView.addConstraints([textViewTopConstraint, textViewLeftConstraint, textViewBottomConstraint, textViewRightConstraint])
        contentView.addConstraints([placeholderLabelTopConstraint, placeholderLabelLeftConstraint])
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Super

    override public func isFirstResponder() -> Bool {
        return textView.isFirstResponder()
    }
    
    override public func becomeFirstResponder() -> Bool {
        return textView.becomeFirstResponder()
    }
    
    override public func resignFirstResponder() -> Bool {
        return textView.resignFirstResponder()
    }
    
    public override func updateConstraints() {
        
        textViewTopConstraint.constant = valueViewInsets.top
        textViewLeftConstraint.constant = valueViewInsets.left
        textViewBottomConstraint.constant = -valueViewInsets.bottom
        textViewRightConstraint.constant = -valueViewInsets.right
        
        placeholderLabelTopConstraint.constant = valueViewInsets.top + placeholderLabelOffset.vertical
        placeholderLabelLeftConstraint.constant = valueViewInsets.left + placeholderLabelOffset.horizontal
        
        super.updateConstraints()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        textView.userInteractionEnabled = editable
    }
    
    // MARK: Methods
    
    override public func valueView() -> UIView {
        return textView
    }
    
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

        updateCharacterLabelWithCharacterCount(textView.text?.characters.count ?? 0)
        
        placeholderLabel.hidden = !textView.text.isEmpty
    }
    
    public func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        return editable
    }
    
    public func textViewDidBeginEditing(textView: UITextView) {
        errorState = false
        delegate?.formCell?(self, didBecomeFirstResponder: textView)
    }
    
    public func textViewDidEndEditing(textView: UITextView) {
        delegate?.formCell?(self, didResignFirstResponder: textView)
    }
    
    // MARK: ScrollViewDelegate
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        
    }
    
    // MARK: FormTableViewCellProtocol
    
    override public func updateUI() {
        if let text = value as? String {
            if textView.text != text {
                textView.text = ""
                textView.insertText(text)
            }
        }
    }
    
    override public func isEmpty() -> Bool {
        if let text = textView.text {
            return text.characters.count == 0
        }
        return true
    }
    
    override public func rowHeight() -> CGFloat {
        if visible {
            let rowHeight = min(max(ceil(self.textViewHeight) + valueViewInsets.top + valueViewInsets.bottom, minRowHeight), maxRowHeight)
            
            let textViewHeight = rowHeight - valueViewInsets.top - valueViewInsets.bottom

            textView.scrollEnabled = self.textViewHeight > textViewHeight
            
            return rowHeight
        }
        return 0
    }
}
