//
//  EPStringAttribute.h
//  
//
//  Created by Rohan Kapur on 11/6/15.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    EPTextCharacteristicsNone = (1 << 0),
    EPTextCharacteristicAny = (1 << 1),
    EPTextCharacteristicBold = (1 << 2),
    EPTextCharacteristicsMax = (1 << 3) // NOTE: THIS SHOULD ALWAYS BE THE LAST VALUE
} EPTextCharacteristics;

static const NSString *NSAttributeNameAnyAttribute = @"NSAttributeNameAnyAttribute";

/**
 Stores data about an attribute
 eg. the name, value, and range
 that would be used to add attributes
 to an NSMutableAttributedString via
 -addAttribute:value:range:.
 */
@interface EPStringAttribute : NSObject

/**
 The text characteristics that
 define the attribute and its
 key/value pair.
 */
@property (assign, readonly, nonatomic) EPTextCharacteristics textCharacteristics;

/**
 The key/name of the attribute;
 the attribute itself. Corresponds to the
 first parameter in NSMutableAttributedString's
 -addAttribute:value:range:.
 */
@property (strong, readonly, nonatomic) NSString *key;
/**
 The arbitrary value of the attribute. Corresponds
 to the second parameter in NSMutableAttributedString's
 -addAttribute:value:range:.
 */
@property (strong, readonly, nonatomic) id value;
/**
 The range of characters to where the attribute
 applies in the string. Corresponds to the third
 parameter in NSMutableAttributedString's -addAttribute:
 value:range:.
 */
@property (readwrite, nonatomic) NSRange range;

/**
 Initializes a new EPStringAttribute
 with the key, value, text characteristics,
 and range properties set.
 */
- (id)initWithKey:(NSString *)key value:(id)value range:(NSRange)textRange andTextCharacteristics:(EPTextCharacteristics)textCharacteristics;

/**
 Disjoin (seperate) an attribute at
 a range into two seperate attributes.
 NOTE: The range's length should be equal
 to the desired disjoin offset, rather than 0
 pulled directly from text view's shouldChangeTextInRange:
 delegate method.
 */
- (NSArray *)disjointAttributesAtRange:(NSRange)range;

/**
 Adjoin two attributes into one
 single attribute across the
 collective ranges.
 */
- (EPStringAttribute *)adjoinWithAttribute:(EPStringAttribute *)attribute;

@end
