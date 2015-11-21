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
    
//    var contentHeight: CGFloat = 0 {
//        didSet {
//            if contentHeight != oldValue {
//                delegate?.formCell(self, identifier: identifier, didChangeRowHeight: rowHeight())
//            }
//        }
//    }
    
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
    
    required public init(identifier: String, dataSource: FormTableViewCellDataSource!, delegate: FormTableViewCellDelegate!) {
        super.init(identifier: identifier, dataSource: dataSource, delegate: delegate)
        
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
        
        let valueEdgeInsets = dataSource?.valueEdgeInsetsForFormCell(self, identifier: identifier) ?? UIEdgeInsetsZero
        
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
    
    override func valueView() -> UIView {
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
//        contentHeight = textView.contentSize.height
        updateCharacterLabelWithCharacterCount(textView.text?.characters.count ?? 0)
        
        let valueEdgeInsets = dataSource?.valueEdgeInsetsForFormCell(self, identifier: identifier) ?? UIEdgeInsetsZero
        let textViewHeight = CGRectGetHeight(bounds) - valueEdgeInsets.bottom
        let textHeight = textView.text?.boundingRectHeightWithMaxWidth(CGRectGetWidth(textView.bounds), font: textView.font!) ?? 0
        
        textView.scrollEnabled = textHeight > textViewHeight
    }
    
    public func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        return isEditable
    }
    
    public func textViewDidBeginEditing(textView: UITextView) {
        errorState = false
        delegate?.formCell(self, identifier: identifier, didBecomeFirstResponder: textView)
    }
    
    public func textViewDidEndEditing(textView: UITextView) {
        
    }
    
    // MARK: ScrollViewDelegate
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        
    }
    
    // MARK: FormTableViewCellProtocol
    
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
            let valueEdgeInsets = dataSource?.valueEdgeInsetsForFormCell(self, identifier: identifier) ?? UIEdgeInsetsZero
            let textHeight = textView.text?.boundingRectHeightWithMaxWidth(CGRectGetWidth(textView.bounds), font: textView.font!) ?? 0
            return min(max(textHeight + valueEdgeInsets.top + valueEdgeInsets.bottom, minRowHeight), maxRowHeight)
        }
        return 0
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
    
    // MARK: - Initializers
    
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