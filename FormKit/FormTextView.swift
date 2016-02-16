//
//  FormTextView.swift
//  FormKit
//
//  Created by Michael Loistl on 10/01/2016.
//  Copyright © 2016 Aplo. All rights reserved.
//

import Foundation
import UIKit

public protocol FormTextViewDataSource {
    func formTextViewMinHeight(sender: FormTextView) -> CGFloat
    func formTextViewMaxHeight(sender: FormTextView) -> CGFloat
    
    func formTextViewShouldResignFirstResponder(sender: FormTextView) -> Bool
}

public class FormTextView: UITextView {
    
    public var dataSource: FormTextViewDataSource?
    
    public var placeholder: String? {
        didSet {
            placeHolderLabel.text = placeholder
            layoutSubviews()
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
        
        scrollsToTop = false
        
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
    
    public override func resignFirstResponder() -> Bool {
        if dataSource?.formTextViewShouldResignFirstResponder(self) == false {
            return false
        }
        
        return super.resignFirstResponder()
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