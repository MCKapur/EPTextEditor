//
//  EPStringAttribute.m
//  
//
//  Created by Rohan Kapur on 11/6/15.
//
//

#import "EPStringAttribute.h"

@interface EPStringAttribute ()
@property (assign, readwrite, nonatomic) EPTextCharacteristics textCharacteristics;
@property (strong, readwrite, nonatomic) NSString *key;
@property (strong, readwrite, nonatomic) id value;
@end

@implementation EPStringAttribute

#pragma mark - Overriding

- (NSString *)description {
    return [NSString stringWithFormat:@"\rKey: %@\rValue: %@\rRange: %@\rText Characteristics: %d\r", self.key, self.value, NSStringFromRange(self.range), self.textCharacteristics];
}

- (instancetype)copy {
    EPStringAttribute *stringAttribute = [[EPStringAttribute alloc] initWithKey:self.key value:self.value range:self.range andTextCharacteristics:self.textCharacteristics];
    return stringAttribute;
}

#pragma mark - Adjoining/Disjoining Attributes

- (NSArray *)disjointAttributesAtRange:(NSRange)range {
    EPStringAttribute *stringAttribute = [self copy];
    stringAttribute.range = NSMakeRange(stringAttribute.range.location, stringAttribute.range.length + range.length);
    NSRange firstRangeComponent = NSMakeRange(stringAttribute.range.location, range.location - stringAttribute.range.location);
    NSRange secondRangeComponent = NSMakeRange(range.location + range.length, (stringAttribute.range.location + stringAttribute.range.length) - range.location - range.length);
    return @[[[EPStringAttribute alloc] initWithKey:stringAttribute.key value:stringAttribute.value range:firstRangeComponent andTextCharacteristics:stringAttribute.textCharacteristics], [[EPStringAttribute alloc] initWithKey:stringAttribute.key value:stringAttribute.value range:secondRangeComponent andTextCharacteristics:stringAttribute.textCharacteristics]];
}

- (EPStringAttribute *)adjoinWithAttribute:(EPStringAttribute *)attribute {
    EPStringAttribute *stringAttribute = [self copy];
    if (![stringAttribute.value isEqual:attribute.value])
        return nil;
    if (stringAttribute.range.location > attribute.range.location)
        stringAttribute.range = NSMakeRange(attribute.range.location, attribute.range.length + stringAttribute.range.length);
    else
        stringAttribute.range = NSMakeRange(stringAttribute.range.location, stringAttribute.range.length + attribute.range.length);
    return stringAttribute;
}

#pragma mark - Init

- (id)initWithKey:(NSString *)key value:(id)value range:(NSRange)textRange andTextCharacteristics:(EPTextCharacteristics)textCharacteristics {
    if (self = [self init]) {
        [self setKey:key];
        [self setValue:value];
        [self setRange:textRange];
        [self setTextCharacteristics:textCharacteristics];
    }
    return self;
}

- (id)init {
    return [super init];
}

@end