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
    
    var allowLineBreak = true
    
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
        
        return _constraint
    }()
    
    lazy var textViewRightConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.textView, attribute: .Right, relatedBy: .Equal, toItem: self.contentView, attribute: .Right, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()
    
    // MARK: Initializers
    
    required public init(identifier: String, delegate: FormTableViewCellDelegate!) {
        super.init(identifier: identifier, delegate: delegate)
        
        maxRowHeight = 88.0
        
        contentView.insertSubview(textView, atIndex: 0)
        
        contentView.addConstraints([textViewTopConstraint, textViewLeftConstraint, textViewBottomConstraint, textViewRightConstraint])
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
    }
    
    public func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        return editable
    }
    
    public func textViewDidBeginEditing(textView: UITextView) {
        errorState = false
        delegate?.formCell?(self, identifier: identifier, didBecomeFirstResponder: textView)
    }
    
    public func textViewDidEndEditing(textView: UITextView) {
        
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

// MARK: - SubClasses

protocol FormTextViewDataSource {
    func formTextViewMinHeight(sender: FormTextView) -> CGFloat
    func formTextViewMaxHeight(sender: FormTextView) -> CGFloat
}

public class FormTextView: UITextView {
    
    var dataSource: FormTextViewDataSource?
    
    public var placeholder: String? {
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
    
    public lazy var placeHolderLabel: UILabel = {
        let _placeHolderLabel = UILabel()
        _placeHolderLabel.font = self.font
        _placeHolderLabel.textAlignment = self.textAlignment
        _placeHolderLabel.textColor = UIColor(red: 0, green: 0, blue: 0.0980392, alpha: 0.22)
        
        return _placeHolderLabel
    }()
    
    // MARK: - Initializers
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        addSubview(placeHolderLabel)
        
        textContainer?.lineFragmentPadding = 0
        textContainerInset = UIEdgeInsetsZero
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handleTextViewTextDidChangeNotification:"), name: UITextViewTextDidChangeNotification, object: nil)
        
        placeHolderLabel.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Bottom)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Super
    
    public override func intrinsicContentSize() -> CGSize {
        let width = super.intrinsicContentSize().width
        var height = sizeThatFits(CGSizeMake(width, CGFloat.max)).height
        
        if let minHeight = dataSource?.formTextViewMinHeight(self) {
            height = max(height, minHeight)
        }
        
        if let maxHeight = dataSource?.formTextViewMaxHeight(self) {
            height = min(height, maxHeight)
        }
        
        return CGSizeMake(width, height)
    }
    
//    override public func layoutSubviews() {
//        super.layoutSubviews()
//        
//        // PlaceHolderLabel
//        placeHolderLabel.sizeToFit()
//        
//        let placeHolderLabelOriginX: CGFloat = textContainerInset.left + contentInset.left
//        let placeHolderLabelOriginY: CGFloat = textContainerInset.top + contentInset.top + 1.0
//        let placeHolderLabelSizeWidth: CGFloat = CGRectGetWidth(placeHolderLabel.bounds)
//        let placeHolderLabelSizeHeight: CGFloat = CGRectGetHeight(placeHolderLabel.bounds)
//        
//        placeHolderLabel.frame = CGRectMake(placeHolderLabelOriginX, placeHolderLabelOriginY, placeHolderLabelSizeWidth, placeHolderLabelSizeHeight)
//    }
    
    // MARK: Notification Handler Functions
    
    func handleTextViewTextDidChangeNotification(sender: NSNotification) {
        if let text = text {
            placeHolderLabel.hidden = text.characters.count > 0
        } else {
            placeHolderLabel.hidden = false
        }
    }
}