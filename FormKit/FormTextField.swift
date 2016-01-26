//
//  FormTextField.swift
//  FormKit
//
//  Created by Michael Loistl on 10/01/2016.
//  Copyright © 2016 Aplo. All rights reserved.
//

import Foundation
import UIKit

public protocol FormTextFieldDataSource {
    func formTextFieldShouldResignFirstResponder(sender: FormTextField) -> Bool
}

public class FormTextField: UITextField {
    
    public var dataSource: FormTextFieldDataSource?
    
    // MARK: - Super
    
    public override func resignFirstResponder() -> Bool {
        if dataSource?.formTextFieldShouldResignFirstResponder(self) == false {
            return false
        }
        
        return super.resignFirstResponder()
    }
}
