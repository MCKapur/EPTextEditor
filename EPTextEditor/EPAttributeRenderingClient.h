//
//  EPAttributeRenderingClient.h
//  
//
//  Created by Rohan Kapur on 12/6/15.
//
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "EPStringAttribute.h"

/**
 This class fetches and/or calculates
 and hence renders an attribute's key/
 name and value for an attribute type
 (EPAttributeType).
 */
@interface EPAttributeRenderingClient : NSObject

/**
 Returns an array of string attributes for
 a combination of font characteristics.
 NOTE: the attributes' range properties
 are by default NSMakeRange(NSNotFound,
 NSNotFound) - be sure to set them before
 applying them.
*/
+ (NSArray *)attributesForTextCharacteristics:(EPTextCharacteristics)textCharacteristics;

@end
