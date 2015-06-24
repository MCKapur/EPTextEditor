//
//  EPAttributeManager.m
//
//
//  Created by Rohan Kapur on 12/6/15.
//
//

#import "EPAttributeRenderingClient.h"
#import "EPStringAttribute.h"
#import "EPAttributeManager.h"

// This is edge inclusive.
BOOL NSRangeIntersectsOrContainsRange(NSRange range1, NSRange range2) {
    BOOL retVal = NO;
    if ((range1.location <= range2.location && (range1.location + range1.length) >= (range2.length + range2.location)) || NSIntersectionRange(range1, range2).length)
        retVal = YES;
    return retVal;
}

@interface NSString (EPTrimLeadingWhitespace)
- (NSString *)stringByTrimmingLeadingWhitespace;
@end

@implementation NSString (EPTrimLeadingWhitespace)
- (NSString *)stringByTrimmingLeadingWhitespace {
    NSInteger i = 0;
    while ((i < [self length])
           && [[NSCharacterSet whitespaceCharacterSet] characterIsMember:[self characterAtIndex:i]]) {
        i++;
    }
    return [self substringFromIndex:i];
}
@end

@interface NSMutableArray (EPMutableArrayExtras)
/**
 Removes all objects at the indexes
 provided in the array argument. Indexes
 are NSNumbers.
 */
- (void)removeObjectsAtIndexes:(NSArray *)indexes;
@end

@implementation NSMutableArray (EPMutableArrayExtras)
- (void)removeObjectsAtIndexes:(NSArray *)indexes {
    for (NSNumber *index in indexes)
        [self removeObjectAtIndex:index.integerValue];
}
@end

@interface EPAttributeManager () {
    NSUInteger runningLocation;
}
/**
 The running text characteristics
 which are applied in response to
 new characters.
 */
@property (assign, readwrite, nonatomic) EPTextCharacteristics runningTextCharacteristics;
@end

@implementation EPAttributeManager

#pragma mark - Running Text Characteristics

- (void)beginRunningTextCharacteristics:(EPTextCharacteristics)textCharacteristics atRange:(NSRange)range {
    runningLocation = range.location;
    self.runningTextCharacteristics = textCharacteristics;
    if (self.runningTextCharacteristics != EPTextCharacteristicsMax && self.runningTextCharacteristics != EPTextCharacteristicsNone)
        [self addAttributesWithTextCharacteristics:self.runningTextCharacteristics atRange:range];
}

- (void)endRunningTextCharacteristics {
    runningLocation = NSNotFound;
    self.runningTextCharacteristics = EPTextCharacteristicsMax;
}

#pragma mark - Querying

- (NSArray *)indexesOfStringAttribute:(EPStringAttribute *)otherStringAttribute exactRangeMatch:(BOOL)exactRangeMatch {
    NSMutableArray *indexes = [NSMutableArray array];
    for (NSInteger i = 0; i < self.attributes.count; i++) {
        EPStringAttribute *stringAttribute = self.attributes[i];
        if ((otherStringAttribute.textCharacteristics == stringAttribute.textCharacteristics || otherStringAttribute.textCharacteristics == EPTextCharacteristicAny) && (exactRangeMatch || (NSRangeIntersectsOrContainsRange(stringAttribute.range, otherStringAttribute.range) || NSRangeIntersectsOrContainsRange(otherStringAttribute.range, stringAttribute.range))))
            [indexes addObject:@(i)];
    }
    return indexes;
}

#pragma mark - Configuring

- (NSMutableAttributedString *)synthesizeAttributedStringFromString:(NSString *)string {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string attributes:@{}];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20.0f] range:NSMakeRange(0, attributedString.string.length)];
    for (NSInteger i = 0; i < self.attributes.count; i++) {
        EPStringAttribute *attribute = self.attributes[i];
        [attributedString addAttribute:attribute.key value:attribute.value range:attribute.range];
    }
    return [attributedString copy];
}

#pragma mark - Modification

- (void)deleteAttributes:(NSMutableArray *)attributesToDelete andAddAttributes:(NSArray *)attributesToAdd {
    if (attributesToDelete) {
        for (EPStringAttribute *attributeToDelete in attributesToDelete)
            [self.attributes removeObjectsAtIndexes:[self indexesOfStringAttribute:attributeToDelete exactRangeMatch:NO]]; // This is a _selective_ NO. Evaluate whether you need an exact range match or not.
    }
    if (attributesToAdd) {
        for (EPStringAttribute *attributeToAdd in attributesToAdd)
            [self.attributes addObject:attributeToAdd];
    }
}

- (void)respondToDeletedCharactersInRange:(NSRange)range {
    if (range.location < runningLocation)
        [self endRunningTextCharacteristics];
    NSArray *indexes = [self indexesOfStringAttribute:[[EPStringAttribute alloc] initWithKey:nil value:nil range:range andTextCharacteristics:EPTextCharacteristicAny] exactRangeMatch:NO];
    if (indexes.count) {
        for (NSNumber *i in indexes) {
            EPStringAttribute *stringAttribute = self.attributes[i.integerValue];
            if (stringAttribute.range.length == range.length)
                [self.attributes removeObjectAtIndex:i.integerValue];
            else
                stringAttribute.range = NSMakeRange(stringAttribute.range.location, stringAttribute.range.length - range.length);
        }
    }
    else {
        NSMutableArray *attributesToDelete = [NSMutableArray array];
        NSMutableArray *attributesToAdd = [NSMutableArray array];
        for (EPStringAttribute *stringAttribute in self.attributes) {
            if (range.location < stringAttribute.range.location) {
                stringAttribute.range = NSMakeRange(stringAttribute.range.location - range.length, stringAttribute.range.length);
                NSArray *indexes = [self indexesOfStringAttribute:[[EPStringAttribute alloc] initWithKey:stringAttribute.key value:stringAttribute.value range:NSMakeRange(stringAttribute.range.location - 1, 0) andTextCharacteristics:EPTextCharacteristicAny] exactRangeMatch:NO];
                if (indexes.count) {
                    EPStringAttribute *attributeToAdjoin = [self.attributes objectAtIndex:[indexes[0] integerValue]];
                    [attributesToAdd addObject:[stringAttribute adjoinWithAttribute:attributeToAdjoin]];
                    [attributesToDelete addObjectsFromArray:@[stringAttribute, attributeToAdjoin]];
                }
            }
        }
        [self deleteAttributes:attributesToDelete andAddAttributes:attributesToAdd];
    }
}

// TODO: Scrambled TODO thought... what about copying/pasting? Shouldn't the attributes copy along?
// TODO: Enumerated adjoin sequence after modification

- (void)respondToNewCharacters:(NSString *)text inRange:(NSRange)range {
    if (range.location < runningLocation)
        [self endRunningTextCharacteristics];
    NSMutableArray *attributesToDelete = [NSMutableArray array];
    NSMutableArray *attributesToAdd = [NSMutableArray array];
    if (!range.length) {
        for (EPStringAttribute *stringAttribute in self.attributes) {
            if (range.location < stringAttribute.range.location)
                stringAttribute.range = NSMakeRange(stringAttribute.range.location + text.length, stringAttribute.range.length);
        }
        if (self.runningTextCharacteristics != EPTextCharacteristicsMax && self.runningTextCharacteristics != EPTextCharacteristicsNone) {
            for (EPStringAttribute *stringAttribute in self.attributes) {
                // TODO: Running attribute right in front of another attribute causes attribute to become "loose" & lose its integrity
                if (NSRangeIntersectsOrContainsRange(stringAttribute.range, range))
                    stringAttribute.range = NSMakeRange(stringAttribute.range.location, stringAttribute.range.length + text.length);
            }
            return;
        }
        else if (self.runningTextCharacteristics == EPTextCharacteristicsNone)
            return;
        for (EPStringAttribute *stringAttribute in self.attributes) {
            if (NSRangeIntersectsOrContainsRange(stringAttribute.range, range)) {
                if (![[text substringToIndex:1] isEqualToString:@" "])
                    stringAttribute.range = NSMakeRange(stringAttribute.range.location, stringAttribute.range.length + text.length);
                else {
                    // TODO: Disjoint sometimes not working?
                    // TODO: Disjoin on the go? Or disjoin when a running attribute ends eg. setting running attribute to none in an attributed zone.
                    if ((range.location > stringAttribute.range.location) && (range.location < stringAttribute.range.location + stringAttribute.range.length)) {
                        [attributesToDelete addObject:stringAttribute];
                        [attributesToAdd addObjectsFromArray:[stringAttribute disjointAttributesAtRange:NSMakeRange(range.location, 1)]];
                        // TODO: Reapply the attributes after disjoining?
                    }
                    else
                        stringAttribute.range = NSMakeRange(stringAttribute.range.location, stringAttribute.range.length + [text stringByTrimmingLeadingWhitespace].length);
                }
            }
        }
    }
    else if (text.length != range.length) {
        // TODO: Apply the same rules here as above.
        NSArray *indexes = [self indexesOfStringAttribute:[[EPStringAttribute alloc] initWithKey:nil value:nil range:range andTextCharacteristics:EPTextCharacteristicAny] exactRangeMatch:NO];
        if (indexes.count > 1) {
            NSUInteger smallestLocation = NSNotFound;
            for (NSNumber *index in indexes) {
                EPStringAttribute *attribute = self.attributes[index.integerValue];
                if (attribute.range.location <= smallestLocation)
                    smallestLocation = attribute.range.location;
                [attributesToDelete addObject:attribute];
            }
            NSArray *frontAttributes = [self indexesOfStringAttribute:[[EPStringAttribute alloc] initWithKey:NSFontAttributeName value:nil range:NSMakeRange(smallestLocation, 1) andTextCharacteristics:EPTextCharacteristicAny] exactRangeMatch:NO];
            for (NSNumber *index in frontAttributes) {
                EPStringAttribute *frontAttribute = self.attributes[index.integerValue];
                EPStringAttribute *newStringAttribute = [[EPStringAttribute alloc] initWithKey:frontAttribute.key value:frontAttribute.value range:NSMakeRange(frontAttribute.range.location, (range.location - frontAttribute.range.location) + text.length) andTextCharacteristics:frontAttribute.textCharacteristics];
                [attributesToAdd addObject:newStringAttribute];
            }
        }
        // TODO: Shift over consequent things due to replacement
        else if (indexes.count) {
            NSUInteger index = [indexes[0] integerValue];
            NSRange attributeRange = [self.attributes[index] range];
            [self.attributes[index] setRange:NSMakeRange(attributeRange.location, attributeRange.length + (text.length - range.length))];
        }
    }
    [self deleteAttributes:attributesToDelete andAddAttributes:attributesToAdd];
}

- (void)addAttributesWithTextCharacteristics:(EPTextCharacteristics)textCharacteristics atRange:(NSRange)range {
    NSArray *renderedAttributes = [EPAttributeRenderingClient attributesForTextCharacteristics:textCharacteristics];
    NSMutableArray *indexes = [NSMutableArray array];
    NSMutableArray *attributes = [NSMutableArray array];
    for (EPStringAttribute *attribute in renderedAttributes) {
        attribute.range = range;
        [attributes addObject:attribute];
        [indexes addObjectsFromArray:[self indexesOfStringAttribute:attribute exactRangeMatch:NO]];
    }
    // TODO: This won't work for > 1 text characteristic, specifically if we render a single font and hence attributes based on text characteristics. This also doesn't remove attributes at a SPECIFIC point. Only removes the entire attribute.
    if (indexes.count && (self.runningTextCharacteristics == EPTextCharacteristicsMax || self.runningTextCharacteristics == EPTextCharacteristicsNone)) {
        [self.attributes removeObjectsAtIndexes:indexes];
    }
    else {
        [self.attributes addObjectsFromArray:attributes];
    }
}

#pragma mark - Init

- (id)init {
    if (self = [super init])
        self.attributes = [NSMutableArray array];
    return self;
}

@end
