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
    
    public enum CharacterLabelAlignment {
        case TopLeft
        case TopRight
        case BottomLeft
        case BottomRight
    }
    
    var characterlimit: Int = 0 {
        didSet {
            characterLabel.hidden = characterlimit == 0
            updateCharacterLabelWithCharacterCount(0)
        }
    }
    
    var characterLabelAlignment: CharacterLabelAlignment = .BottomRight
    
    var characterLabelValidTextColor = UIColor.lightGrayColor()
    var characterLabelInvalidTextColor = UIColor.redColor()
    
    var characterLabelInsets = UIEdgeInsetsMake(11, 120, 0, 16)
    
    public lazy var characterLabel: UILabel = {
        let _characterLabel = UILabel(forAutoLayout: ())
        _characterLabel.textAlignment = .Right
        _characterLabel.hidden = true
        
        return _characterLabel
    }()
    
    lazy var characterLabelTopConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.characterLabel, attribute: .Top, relatedBy: .Equal, toItem: self.contentView, attribute: .Top, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()
    
    lazy var characterLabelLeftConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.characterLabel, attribute: .Left, relatedBy: .Equal, toItem: self.contentView, attribute: .Left, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()
    
    lazy var characterLabelBottomConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.characterLabel, attribute: .Bottom, relatedBy: .Equal, toItem: self.contentView, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()
    
    lazy var characterLabelRightConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.characterLabel, attribute: .Right, relatedBy: .Equal, toItem: self.contentView, attribute: .Right, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()
    
    // MARK: - Initializers
    
    required public init(identifier: String, delegate: FormTableViewCellDelegate!) {
        super.init(identifier: identifier, delegate: delegate)
        
        valueTextView.hidden = true
        
        selectionStyle = .None
        contentView.clipsToBounds = true
        
        contentView.addSubview(characterLabel)
        
        contentView.addConstraints([characterLabelTopConstraint, characterLabelLeftConstraint, characterLabelBottomConstraint, characterLabelRightConstraint])
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Super
    
    public override func updateConstraints() {
        
        characterLabelTopConstraint.constant = characterLabelInsets.top
        characterLabelLeftConstraint.constant = characterLabelInsets.left
        characterLabelBottomConstraint.constant = -characterLabelInsets.bottom
        characterLabelRightConstraint.constant = -characterLabelInsets.right
        
        switch characterLabelAlignment {
        case .TopLeft:
            NSLayoutConstraint.activateConstraints([characterLabelTopConstraint, characterLabelLeftConstraint])
            NSLayoutConstraint.deactivateConstraints([characterLabelBottomConstraint, characterLabelRightConstraint])
        case .TopRight:
            NSLayoutConstraint.activateConstraints([characterLabelTopConstraint, characterLabelRightConstraint])
            NSLayoutConstraint.deactivateConstraints([characterLabelLeftConstraint, characterLabelBottomConstraint])
        case .BottomLeft:
            NSLayoutConstraint.activateConstraints([characterLabelBottomConstraint, characterLabelLeftConstraint])
            NSLayoutConstraint.deactivateConstraints([characterLabelTopConstraint, characterLabelRightConstraint])
        case .BottomRight:
            NSLayoutConstraint.activateConstraints([characterLabelBottomConstraint, characterLabelRightConstraint])
            NSLayoutConstraint.deactivateConstraints([characterLabelTopConstraint, characterLabelLeftConstraint])
        }
        
        super.updateConstraints()
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
        delegate?.formCellDidRequestNextFormTableViewCell?(self, identifier: identifier)
    }
}