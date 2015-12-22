//
//  FormValueTransformer.swift
//  FormKit
//
//  Created by Michael Loistl on 22/02/2015.
//  Copyright (c) 2015 MIchael LOistl. All rights reserved.
//

import Foundation

// MARK: - ValueTransformers

public class FormValueTransformer: NSValueTransformer {
    
    public typealias closureAlias = (value: AnyObject?) -> AnyObject?
    
    var forwardClosure: (closureAlias)?
    var reverseClosure: (closureAlias)?
    
    // MARK: Initializers
    
    public override init() {
        super.init()
    }
    
    public convenience init(forwardClosure: ((value: AnyObject?) -> AnyObject?)?, reverseClosure: ((value: AnyObject?) -> AnyObject?)?) {
        self.init()
        
        self.forwardClosure = forwardClosure
        self.reverseClosure = reverseClosure
    }
    
    // MARK: Class Functions
    
    // Returns a transformer which transforms values using the given closure.
    // Reverse transformations will not be allowed.
    public class func transformerWithClosure(closure: closureAlias) -> NSValueTransformer! {
        return FormValueTransformer(forwardClosure: closure, reverseClosure: nil)
    }
    
    // Returns a transformer which transforms values using the given closure, for
    // forward or reverse transformations.
    public class func reversibleTransformerWithClosure(closure: closureAlias) -> NSValueTransformer! {
        return reversibleTransformerWithForwardClosure(closure, reverseClosure: closure)
    }
    
    // Returns a transformer which transforms values using the given closures.
    public class func reversibleTransformerWithForwardClosure(forwardClosure: closureAlias, reverseClosure: closureAlias) -> NSValueTransformer! {
        return FormReversibleValueTransformer(forwardClosure: forwardClosure, reverseClosure: reverseClosure)
    }
    
    // MARK: ValueTransformer
    
    public override class func allowsReverseTransformation() -> Bool {
        return false
    }
    
    public override class func transformedValueClass() -> AnyClass {
        return NSObject.self
    }
    
    public override func transformedValue(value: AnyObject?) -> AnyObject? {
        if let forwardClosure = forwardClosure {
            return forwardClosure(value: value)
        }
        return nil
    }
}

public class FormReversibleValueTransformer: FormValueTransformer {
    
    // MARK: ValueTransformer
    
    public override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    public override func reverseTransformedValue(value: AnyObject?) -> AnyObject? {
        if let reverseClosure = reverseClosure {
            return reverseClosure(value: value)
        }
        return nil
    }
    
}

