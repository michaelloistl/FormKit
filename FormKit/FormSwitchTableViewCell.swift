//
//  FormSwitchTableViewCell.swift
//  FormKit
//
//  Created by Michael Loistl on 14/11/2015.
//  Copyright © 2015 Aplo. All rights reserved.
//

import Foundation
import UIKit

public class FormSwitchTableViewCell: FormTableViewCell {
    
    public lazy var switchView: UISwitch = {
        let _switchView = UISwitch(forAutoLayout: ())
        _switchView.addTarget(self, action: Selector("switchDidChangeValue:"), forControlEvents: .ValueChanged)
        
        return _switchView
    }()
    
    lazy var switchViewRightConstraint: NSLayoutConstraint = {
        let _constraint = NSLayoutConstraint(item: self.switchView, attribute: .Right, relatedBy: .Equal, toItem: self.contentView, attribute: .Right, multiplier: 1.0, constant: 0.0)
        
        return _constraint
    }()
    
    // MARK: Initializers
    
    required public init(identifier: String, delegate: FormTableViewCellDelegate!) {
        super.init(identifier: identifier, delegate: delegate)
        
        selectionStyle = .None
        
        contentView.addSubview(switchView)
        
        contentView.addConstraint(switchViewRightConstraint)
        switchView.autoAlignAxis(.Horizontal, toSameAxisOfView: contentView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Super
    
    public override func updateConstraints() {
        
        switchViewRightConstraint.constant = -valueViewInsets.right
        
        super.updateConstraints()
    }
    
    // MARK: Methods

    override public func valueView() -> UIView {
        return switchView
    }
    
    // MARK: Actions
    
    func switchDidChangeValue(sender: UISwitch) {
        value = sender.on
    }
    
    // MARK: FormTableViewCellProtocol
    
    override public func updateUI() {
        switchView.on = value as? Bool ?? false
    }
    
    override public func isEmpty() -> Bool {
        return false
    }
}