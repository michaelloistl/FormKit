//
//  FormValueTransformer.swift
//  FormKit
//
//  Created by Michael Loistl on 22/02/2015.
//  Copyright (c) 2015 MIchael LOistl. All rights reserved.
//

import Foundation

// MARK: - ValueTransformers

open class FormValueTransformer: ValueTransformer {
    
    public typealias closureAlias = (_ value: Any?) -> Any?
    
    var forwardClosure: (closureAlias)?
    var reverseClosure: (closureAlias)?
    
    // MARK: Initializers
    
    public override init() {
        super.init()
    }
    
    public convenience init(forwardClosure: ((_ value: Any?) -> Any?)?, reverseClosure: ((_ value: Any?) -> Any?)?) {
        self.init()
        
        self.forwardClosure = forwardClosure
        self.reverseClosure = reverseClosure
    }
    
    // MARK: Class Functions
    
    // Returns a transformer which transforms values using the given closure.
    // Reverse transformations will not be allowed.
    open class func transformerWithClosure(_ closure: @escaping closureAlias) -> ValueTransformer! {
        return FormValueTransformer(forwardClosure: closure, reverseClosure: nil)
    }
    
    // Returns a transformer which transforms values using the given closure, for
    // forward or reverse transformations.
    open class func reversibleTransformerWithClosure(_ closure: @escaping closureAlias) -> ValueTransformer! {
        return reversibleTransformerWithForwardClosure(closure, reverseClosure: closure)
    }
    
    // Returns a transformer which transforms values using the given closures.
    open class func reversibleTransformerWithForwardClosure(_ forwardClosure: @escaping closureAlias, reverseClosure: @escaping closureAlias) -> ValueTransformer! {
        return FormReversibleValueTransformer(forwardClosure: forwardClosure, reverseClosure: reverseClosure)
    }
    
    // MARK: ValueTransformer
    
    open override class func allowsReverseTransformation() -> Bool {
        return false
    }
    
    open override class func transformedValueClass() -> AnyClass {
        return NSObject.self
    }
    
    open override func transformedValue(_ value: Any?) -> Any? {
        if let forwardClosure = forwardClosure {
            return forwardClosure(value as Any?)
        }
        return nil
    }
}

open class FormReversibleValueTransformer: FormValueTransformer {
    
    // MARK: ValueTransformer
    
    open override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    open override func reverseTransformedValue(_ value: Any?) -> Any? {
        if let reverseClosure = reverseClosure {
            return reverseClosure(value as Any?)
        }
        return nil
    }
    
}

