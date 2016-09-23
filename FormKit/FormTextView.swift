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
    func formTextViewMinHeight(_ sender: FormTextView) -> CGFloat
    func formTextViewMaxHeight(_ sender: FormTextView) -> CGFloat
    
    func formTextViewShouldResignFirstResponder(_ sender: FormTextView) -> Bool
}

open class FormTextView: UITextView {
    
    open var dataSource: FormTextViewDataSource?
    
    open var placeholder: String? {
        didSet {
            placeHolderLabel.text = placeholder
            layoutSubviews()
        }
    }
    
    override open var font: UIFont? {
        didSet {
            placeHolderLabel.font = font
        }
    }
    
    override open var textAlignment: NSTextAlignment {
        didSet {
            placeHolderLabel.textAlignment = textAlignment
        }
    }
    
    open lazy var placeHolderLabel: UILabel = {
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
        textContainerInset = UIEdgeInsets.zero
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextViewTextDidChangeNotification(_:)), name: NSNotification.Name.UITextViewTextDidChange, object: nil)
        
        placeHolderLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero, excludingEdge: .bottom)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Super
    
    open override var intrinsicContentSize : CGSize {
        let width = super.intrinsicContentSize.width
        var height = sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)).height
        
        if let minHeight = dataSource?.formTextViewMinHeight(self) {
            height = max(height, minHeight)
        }
        
        if let maxHeight = dataSource?.formTextViewMaxHeight(self) {
            height = min(height, maxHeight)
        }
        
        return CGSize(width: width, height: height)
    }
    
    open override func resignFirstResponder() -> Bool {
        if dataSource?.formTextViewShouldResignFirstResponder(self) == false {
            return false
        }
        
        return super.resignFirstResponder()
    }
    
    // MARK: Notification Handler Functions
    
    func handleTextViewTextDidChangeNotification(_ sender: Notification) {
        if let text = text {
            placeHolderLabel.isHidden = text.characters.count > 0
        } else {
            placeHolderLabel.isHidden = false
        }
    }
}
