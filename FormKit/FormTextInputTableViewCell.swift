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

open class FormTextInputTableViewCell: FormTableViewCell {
    
    public enum CharacterLabelAlignment {
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
    }
    
    open var characterlimit: Int = 0 {
        didSet {
            characterLabel.isHidden = characterlimit == 0
            updateCharacterLabelWithCharacterCount(0)
        }
    }
    
    var characterLabelAlignment: CharacterLabelAlignment = .bottomRight
    
    var characterLabelValidTextColor = UIColor.lightGray
    var characterLabelInvalidTextColor = UIColor.red
    
    var characterLabelInsets = UIEdgeInsetsMake(11, 120, 0, 16)
    
    open lazy var characterLabel: UILabel = {
        let _characterLabel = UILabel(forAutoLayout: ())
        _characterLabel.textAlignment = .right
        _characterLabel.isHidden = true
        
        return _characterLabel
    }()
    
    lazy var characterLabelTopConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.characterLabel, attribute: .top, relatedBy: .equal, toItem: self.contentView, attribute: .top, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()
    
    lazy var characterLabelLeftConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.characterLabel, attribute: .left, relatedBy: .equal, toItem: self.contentView, attribute: .left, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()
    
    lazy var characterLabelBottomConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.characterLabel, attribute: .bottom, relatedBy: .equal, toItem: self.contentView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        _constraint.priority = 750
        
        return _constraint
    }()
    
    lazy var characterLabelRightConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.characterLabel, attribute: .right, relatedBy: .equal, toItem: self.contentView, attribute: .right, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()
    
    // MARK: - Initializers
    
    required public init(labelText: String?, identifier: String? = nil, configurations: [FormCellConfiguration]? = nil, delegate: FormTableViewCellDelegate?) {
        super.init(labelText: labelText, identifier: identifier, configurations: configurations, delegate: delegate)
        
        valueTextView.isHidden = true
        
        selectionStyle = .none
        contentView.clipsToBounds = true
        
        contentView.addSubview(characterLabel)
        
        contentView.addConstraints([characterLabelTopConstraint, characterLabelLeftConstraint, characterLabelBottomConstraint, characterLabelRightConstraint])
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Super
    
    open override func updateConstraints() {
        
        characterLabelTopConstraint.constant = characterLabelInsets.top
        characterLabelLeftConstraint.constant = characterLabelInsets.left
        characterLabelBottomConstraint.constant = -characterLabelInsets.bottom
        characterLabelRightConstraint.constant = -characterLabelInsets.right
        
        if !characterLabel.isHidden {
            switch characterLabelAlignment {
            case .topLeft:
                NSLayoutConstraint.activate([characterLabelTopConstraint, characterLabelLeftConstraint])
                NSLayoutConstraint.deactivate([characterLabelBottomConstraint, characterLabelRightConstraint])
            case .topRight:
                NSLayoutConstraint.activate([characterLabelTopConstraint, characterLabelRightConstraint])
                NSLayoutConstraint.deactivate([characterLabelLeftConstraint, characterLabelBottomConstraint])
            case .bottomLeft:
                NSLayoutConstraint.activate([characterLabelBottomConstraint, characterLabelLeftConstraint])
                NSLayoutConstraint.deactivate([characterLabelTopConstraint, characterLabelRightConstraint])
            case .bottomRight:
                NSLayoutConstraint.activate([characterLabelBottomConstraint, characterLabelRightConstraint])
                NSLayoutConstraint.deactivate([characterLabelTopConstraint, characterLabelLeftConstraint])
            }
        }
        
        super.updateConstraints()
    }
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let _ = becomeFirstResponder()
    }

    // MARK: - Methods
    
    func updateCharacterLabelWithCharacterCount(_ count: Int) {
        if characterlimit > 0 {
            let remainingCharacters = characterlimit - count
            characterLabel.text = "\(remainingCharacters)"
            characterLabel.textColor = (remainingCharacters < 0) ? characterLabelInvalidTextColor : characterLabelValidTextColor
            characterLabel.isHidden = false
        } else {
            characterLabel.isHidden = true
        }
    }
    
    func nextFormTableViewCell() {
        delegate?.formCellDidRequestNextFormTableViewCell?(self)
    }
}
