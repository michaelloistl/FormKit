# FormKit

## A Work In Progress

FormKit is still in early design and development which means that any implementations will (likely) break as FormKit evolves.


## Protocols

### FormTableViewCellProtocol

### FormTableViewCellDelegate

## Structs

### FormCellConfiguration

### FormCellValidation

### FormCellAction

### FormCellDataSource

FormCellDataSource is used to **set** and **get** a value on a FormTableViewCell using a closure that allows to transform the value.




## Todo's

- [ ] Bug fixes
- [ ] Dynamic data sections
- [ ] Documentation
- [ ] Tests





class func animateWithDuration(duration: NSTimeInterval, animations: () -> Void)

Description	
Animate changes to one or more views using the specified duration.
This method performs the specified animations immediately using the UIViewAnimationOptionCurveEaseInOut and UIViewAnimationOptionTransitionNone animation options.
During an animation, user interactions are temporarily disabled for the views being animated. (Prior to iOS 5, user interactions are disabled for the entire application.)
Parameters	

duration	
The total duration of the animations, measured in seconds. If you specify a negative value or 0, the changes are made without animating them.

animations	
A block object containing the changes to commit to the views. This is where you programmatically change any animatable properties of the views in your view hierarchy. This block takes no parameters and has no return value. This parameter must not be NULL.

Availability	iOS (4.0 and later)

Declared In	UIKit

Reference	UIView Class Reference


- Parameter setFormCellValue:
A closure object returning the value to be set as the form cells's value. The closure can be used to transform the value.