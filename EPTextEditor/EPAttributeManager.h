//
//  EPAttributeManager.h
//  
//
//  Created by Rohan Kapur on 12/6/15.
//
//

#import <Foundation/Foundation.h>

#import "EPStringAttribute.h"

/**
 Stores an array of EPStringAttribute
 objects and synthesizes an attributed
 string ready to be displayed on the UI
 from these objects. Also has convenience
 methods to modify the attributes array
 and the EPStringAttribute objects in 
 response to changes in the text/string.
 */
@interface EPAttributeManager : NSObject

/**
 This sets the running text characteristics
 of the attribute manager, and the range
 in which the "run" begins.
 The running text characteristics
 which are applied in response to
 new characters.
 The text characteristics need to be in sync
 everytime a new running characteristic is
 applied or a selected text range is changed.
 NOTE: MAKE SURE THIS IS IN SYNC.
 */
- (void)beginRunningTextCharacteristics:(EPTextCharacteristics)textCharacteristics atRange:(NSRange)range;

/**
 Force ends any running text characteristics
 by setting the running text characteristic
 to EPTextCharacteristicsMax. This means
 that the text characteristics inherited
 will correspond to the ones of an attribute
 at the text view's selected range (in that
 context). This is called internally if a set
 of conditions is satisfied.
 */
- (void)endRunningTextCharacteristics;

/**
 An array containing EPStringAttribute
 objects used as the attributes for the
 NSMutableAttributedString. If exact range
 match is no, any attributes contained in
 the range or any attributes that contain that
 range will be returned.
 */
@property (strong, readwrite, nonatomic) NSMutableArray *attributes;

/**
 Returns the unsigned indexes of an
 EPStringAttribute argument in the
 array of EPStringAttribuet "attributes"
 property. If you pass NO to the
 exactRangeMatch: argument, all attributes
 which FALL into the range are returned.
 Otherwise, if the argument is YES, then
 only attributes with the exact same range
 are returned.
 */
- (NSArray *)indexesOfStringAttribute:(EPStringAttribute *)otherStringAttribute exactRangeMatch:(BOOL)exactRangeMatch;

/**
 Creates an NSMutableAttributedString
 from the provided NSString argument
 and unwraps and uses the EPStringAttributes
 in the "attributes" array property as the
 attributed string's attributes.
 */
- (NSAttributedString *)synthesizeAttributedStringFromString:(NSString *)string;

/**
 Modifies the "attributes" property and
 the EPStringAttributes inside it to 
 correspond with new deletions to the
 string.
 */
- (void)respondToDeletedCharactersInRange:(NSRange)range;

/**
 Modifies the "attributes" property and
 the EPStringAttributes inside it to
 correspond with new characters in the
 string.
 */
- (void)respondToNewCharacters:(NSString *)text inRange:(NSRange)range;

/**
 Adds or modifies the attributes array to
 introduce new attributes at a certain range
 of the (attributed) string, from a set of
 text characteristics.
 */
- (void)addAttributesWithTextCharacteristics:(EPTextCharacteristics)textCharacteristics atRange:(NSRange)range;

@end
