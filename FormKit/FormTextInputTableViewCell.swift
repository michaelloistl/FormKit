//
//  FormTextInputTableViewCell.swift
//  FormKit
//
//  Created by Michael Loistl on 14/11/2015.
//  Copyright © 2015 Aplo. All rights reserved.
//

import Foundation
import UIKit
import PureLayout

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
    
    required public init(identifier: String, dataSource: FormTableViewCellDataSource!, delegate: FormTableViewCellDelegate!) {
        super.init(identifier: identifier, dataSource: dataSource, delegate: delegate)
        
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
        
        let valueEdgeInsets = dataSource?.valueEdgeInsetsForFormCell(self, identifier: identifier) ?? UIEdgeInsetsZero
        
        let originX: CGFloat = valueEdgeInsets.left
        let originY: CGFloat = CGRectGetHeight(bounds) - valueEdgeInsets.bottom
        let sizeWidth: CGFloat = CGRectGetWidth(bounds) - valueEdgeInsets.left - valueEdgeInsets.right
        let sizeHeight: CGFloat = valueEdgeInsets.bottom
        
        characterLabel.frame = CGRectMake(originX, originY, sizeWidth, sizeHeight)
    }
    
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        becomeFirstResponder()
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
        delegate?.formCellDidRequestNextFormTableViewCell(self, identifier: identifier)
    }
}