//
//  EPAttributeRenderingClient.m
//  
//
//  Created by Rohan Kapur on 12/6/15.
//
//

#import "EPAttributeRenderingClient.h"

@implementation EPAttributeRenderingClient

+ (NSArray *)attributesForTextCharacteristics:(EPTextCharacteristics)textCharacteristics {
    // TODO: This won't support more continous data eg. font size (rather you could have
    // multiple types of headings)
    // To solve this, a metadata/extra data parameter should be passed to the method as an argument
    // Ask Prabhav if that is needed. You could pass an extra metadata parameter.
    NSString *key = nil;
    id value = nil;
    // TODO: Implement this when more attribute types come. For now it's just bold.
    key = NSFontAttributeName;
    value = [UIFont boldSystemFontOfSize:20.0f];
    return @[[[EPStringAttribute alloc] initWithKey:key value:value range:NSMakeRange(NSNotFound, NSNotFound) andTextCharacteristics:textCharacteristics]];
}

@end
