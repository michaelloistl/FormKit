//
//  FormTextViewTableViewCell.swift
//  FormKit
//
//  Created by Michael Loistl on 14/11/2015.
//  Copyright © 2015 Aplo. All rights reserved.
//

import Foundation

open class FormTextViewTableViewCell: FormTextInputTableViewCell, NSLayoutManagerDelegate, UITextViewDelegate {
    
    open var allowLineBreak = true
    
    open var placeholder: String? {
        didSet {
            placeholderLabel.text = placeholder
        }
    }
    
    open var didChangeSelection: (_ textView: UITextView) -> Void = { _ in }
    open var shouldChangeText: (_ textView: UITextView, _ range: NSRange, _ replacementText: String) -> Bool = { _ in return true }
    
    var placeholderLabelOffset = UIOffset.zero
    
    var textViewWidth: CGFloat {
        return contentView.bounds.width - valueViewInsets.left - valueViewInsets.right
    }
    
    var textViewHeight: CGFloat {
        return textView.sizeThatFits(CGSize(width: textViewWidth, height: CGFloat.greatestFiniteMagnitude)).height
    }
    
    open lazy var textView: FormTextView = {
        let _textView = FormTextView(forAutoLayout: ())
        _textView.delegate = self
        _textView.dataSource = self
        _textView.font = self.textLabel?.font
        _textView.backgroundColor = .clear
        
        _textView.contentInset = UIEdgeInsets.zero
        _textView.textContainerInset = UIEdgeInsets.zero
        _textView.textContainer.lineFragmentPadding = 0

        return _textView
    }()
    
    open lazy var placeholderLabel: UILabel = {
        let _label = UILabel(forAutoLayout: ())
        _label.font = self.textLabel?.font
        _label.textColor = .lightGray
        
        return _label
    }()
    
    lazy var textViewTopConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.textView, attribute: .top, relatedBy: .equal, toItem: self.contentView, attribute: .top, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()
    
    lazy var textViewLeftConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.textView, attribute: .left, relatedBy: .equal, toItem: self.contentView, attribute: .left, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()
    
    lazy var textViewBottomConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.textView, attribute: .bottom, relatedBy: .equal, toItem: self.contentView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        _constraint.priority = 750
        
        return _constraint
    }()
    
    lazy var textViewRightConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.textView, attribute: .right, relatedBy: .equal, toItem: self.contentView, attribute: .right, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()
    
    lazy var placeholderLabelTopConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.placeholderLabel, attribute: .top, relatedBy: .equal, toItem: self.contentView, attribute: .top, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()
    
    lazy var placeholderLabelLeftConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.placeholderLabel, attribute: .left, relatedBy: .equal, toItem: self.contentView, attribute: .left, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()
    
    // MARK: Initializers
    
    required public init(labelText: String?, identifier: String? = nil, configurations: [FormCellConfiguration]? = nil, delegate: FormTableViewCellDelegate?) {
        super.init(labelText: labelText, identifier: identifier, configurations: configurations, delegate: delegate)
        
        maxRowHeight = 88.0
        
        contentView.insertSubview(textView, at: 0)
        contentView.insertSubview(placeholderLabel, at: 0)
        
        contentView.addConstraints([textViewTopConstraint, textViewLeftConstraint, textViewBottomConstraint, textViewRightConstraint])
        contentView.addConstraints([placeholderLabelTopConstraint, placeholderLabelLeftConstraint])
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Super

    override open var isFirstResponder : Bool {
        return textView.isFirstResponder
    }
    
    @discardableResult
    override open func becomeFirstResponder() -> Bool {
        return textView.becomeFirstResponder()
    }
    
    @discardableResult
    override open func resignFirstResponder() -> Bool {
        return textView.resignFirstResponder()
    }
    
    open override func updateConstraints() {
        
        textViewTopConstraint.constant = valueViewInsets.top
        textViewLeftConstraint.constant = valueViewInsets.left
        textViewBottomConstraint.constant = -valueViewInsets.bottom
        textViewRightConstraint.constant = -valueViewInsets.right
        
        placeholderLabelTopConstraint.constant = valueViewInsets.top + placeholderLabelOffset.vertical
        placeholderLabelLeftConstraint.constant = valueViewInsets.left + placeholderLabelOffset.horizontal
        
        super.updateConstraints()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        textView.isUserInteractionEnabled = editable
    }
    
    // MARK: Methods
    
    override open func valueView() -> UIView {
        return textView
    }
    
    // MARK: UITextViewDelegate
    
    open func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        var shouldChange = true
        if text == "\n" {
            if textView.returnKeyType == .next {
                nextFormTableViewCell()
            }
            shouldChange = allowLineBreak
        }
        
        if shouldChange {
            shouldChange = shouldChangeText(textView, range, text)
        }
        
        return shouldChange
    }

    open func textViewDidChangeSelection(_ textView: UITextView) {
        didChangeSelection(textView)
    }

    open func textViewDidChange(_ textView: UITextView) {
        
        layoutSubviews()
        
        value = textView.text as Any?

        updateCharacterLabelWithCharacterCount(textView.text?.characters.count ?? 0)
        
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    open func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return editable
    }
    
    open func textViewDidBeginEditing(_ textView: UITextView) {
        errorState = false
        delegate?.formCell?(self, didBecomeFirstResponder: textView)
    }
    
    open func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.formCell?(self, didResignFirstResponder: textView)
    }
    
    // MARK: ScrollViewDelegate
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    // MARK: FormTableViewCellProtocol
    
    override open func updateUI() {
        if let text = value as? String {
            if textView.text != text {
                textView.text = ""
                textView.insertText(text)
            }
        }
    }
    
    override open func isEmpty() -> Bool {
        if let text = textView.text {
            return text.characters.count == 0
        }
        return true
    }
    
    override open func rowHeight() -> CGFloat {
        if visible {
            let rowHeight = min(max(ceil(self.textViewHeight) + valueViewInsets.top + valueViewInsets.bottom, minRowHeight), maxRowHeight)
            
            let textViewHeight = rowHeight - valueViewInsets.top - valueViewInsets.bottom

            textView.isScrollEnabled = self.textViewHeight > textViewHeight
            
            return rowHeight
        }
        return 0
    }
}
