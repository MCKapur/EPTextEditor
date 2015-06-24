//
//  EPAttributedTextView.m
//  
//
//  Created by Rohan Kapur on 14/6/15.
//
//

#import "EPAttributeManager.h"
#import "EPStringAttribute.h"
#import "EPAttributedTextView.h"

static NSString *const EPKeyboardBarButtonItemEnabled = @"EPKeyboardBarButtonItemEnabled";
static NSString *const EPKeyboardBarButtonItemDisabled = @"EPKeyboardBarButtonItemDisabled";

@interface EPAttributedTextView () <UITextViewDelegate> {
}
@property (nonatomic, weak) id<UITextViewDelegate> externalDelegate;
@property (strong, readwrite, nonatomic) EPAttributeManager *attributeManager;
@end

@implementation EPAttributedTextView

- (void)setDelegate:(id<UITextViewDelegate>)delegate {
    // We always want self to be the delegate, if someone is interested in delegate calls we will forward those on if applicable
    if (delegate == self) {
        [super setDelegate:self];
        return;
    } else
        // Capture that someone else is interested in delegate calls
        self.externalDelegate = delegate;
}

#pragma mark - Updating

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (self.externalDelegate && [self.externalDelegate respondsToSelector:@selector(textViewShouldBeginEditing:)]) {
        if ([self.externalDelegate textViewShouldBeginEditing:textView]) {
            if (!text.length)
                [self.attributeManager respondToDeletedCharactersInRange:range];
            else
                [self.attributeManager respondToNewCharacters:text inRange:range];
        }
        return [self.externalDelegate textViewShouldBeginEditing:textView];
    }
    if (!text.length)
        [self.attributeManager respondToDeletedCharactersInRange:range];
    else
        [self.attributeManager respondToNewCharacters:text inRange:range];
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if (self.externalDelegate && [self.externalDelegate respondsToSelector:@selector(textViewShouldBeginEditing:)])
        return [self.externalDelegate textViewShouldBeginEditing:textView];
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    if (self.externalDelegate && [self.externalDelegate respondsToSelector:@selector(textViewShouldEndEditing:)])
        return [self.externalDelegate textViewShouldEndEditing:textView];
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (self.externalDelegate && [self.externalDelegate respondsToSelector:@selector(textViewDidBeginEditing:)])
        [self.externalDelegate textViewDidBeginEditing:textView];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (self.externalDelegate && [self.externalDelegate respondsToSelector:@selector(textViewDidEndEditing:)])
        [self.externalDelegate textViewDidEndEditing:textView];
}

- (void)textViewDidChange:(UITextView *)textView {
    if (self.externalDelegate && [self.externalDelegate respondsToSelector:@selector(textViewDidChange:)])
        [self.externalDelegate textViewDidChange:textView];
    [self updateTextViewText];
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    if (self.externalDelegate && [self.externalDelegate respondsToSelector:@selector(textViewDidChangeSelection:)])
        [self.externalDelegate textViewDidChangeSelection:textView];
    [self updateTextViewToolbar];
}

- (NSAttributedString *)attributedString {
    return [self.attributeManager synthesizeAttributedStringFromString:self.text];
}

- (void)updateTextViewText {
    UITextRange *selectedTextRange = self.selectedTextRange;
    [self setAttributedText:[self attributedString]];
    [self setSelectedTextRange:selectedTextRange];
    NSLog(@"\r--------------- START CURRENT ATTRIBUTE MAPPING --------------- \r %@ \r --------------- END CURRENT ATTRIBUTE MAPPING ---------------\r", self.attributeManager.attributes);
}

#pragma mark - Toolbar

- (void)updateTextViewToolbar {
    NSArray *indexes = [self.attributeManager indexesOfStringAttribute:[[EPStringAttribute alloc] initWithKey:nil value:nil range:[self selectedRange] andTextCharacteristics:EPTextCharacteristicAny] exactRangeMatch:NO];
    EPTextCharacteristics textCharacteristics = EPTextCharacteristicsNone;
    for (NSNumber *index in indexes) {
        EPStringAttribute *attribute = self.attributeManager.attributes[index.integerValue];
        if (textCharacteristics != EPTextCharacteristicsNone)
            textCharacteristics = (textCharacteristics | attribute.textCharacteristics); // TODO: Does this work?
        else
            textCharacteristics = attribute.textCharacteristics;
    }
    for (UIBarButtonItem *barButtonItem in [self keyboardBarButtonItems]) {
        if ((textCharacteristics & barButtonItem.tag) == barButtonItem.tag)
            [barButtonItem setTitle:[NSString stringWithFormat:@"[ %@ ]", [self characterForTextCharacteristic:(EPTextCharacteristics)barButtonItem.tag]]];
        else
            [barButtonItem setTitle:[NSString stringWithFormat:@"%@", [self characterForTextCharacteristic:(EPTextCharacteristics)barButtonItem.tag]]];
    } // TODO: Instead of this, set the bar button item background color.
}

- (NSArray *)keyboardBarButtonItems {
    return ((UIToolbar *)self.inputAccessoryView).items;
}

- (NSString *)characterForTextCharacteristic:(EPTextCharacteristics)textCharacteristic {
    NSString *retVal = nil;
    switch (textCharacteristic) {
        case EPTextCharacteristicBold:
            retVal = @"B";
            break;
        default:
            break;
    }
    return retVal;
}

- (EPTextCharacteristics)textCharacteristicsFromKeyboardBarButtonItems {
    EPTextCharacteristics textCharacteristics = EPTextCharacteristicsNone;
    for (UIBarButtonItem *barButtonItem in [self keyboardBarButtonItems]) {
        if ([barButtonItem.accessibilityIdentifier isEqualToString:EPKeyboardBarButtonItemEnabled]) // TODO: Better solution
            textCharacteristics = (textCharacteristics == EPTextCharacteristicsMax) ? (EPTextCharacteristics)barButtonItem.tag : (textCharacteristics | (EPTextCharacteristics)barButtonItem.tag);
    }
    return textCharacteristics;
}

- (void)clickedBarButtonItem:(UIBarButtonItem *)barButtonItem {
    if ([barButtonItem.accessibilityIdentifier isEqualToString:EPKeyboardBarButtonItemEnabled]) {
        [barButtonItem setAccessibilityIdentifier:EPKeyboardBarButtonItemDisabled];
        [barButtonItem setTitle:[NSString stringWithFormat:@"%@", [self characterForTextCharacteristic:(EPTextCharacteristics)barButtonItem.tag]]];
    }
    else {
        [barButtonItem setAccessibilityIdentifier:EPKeyboardBarButtonItemEnabled];
        [barButtonItem setTitle:[NSString stringWithFormat:@"[ %@ ]", [self characterForTextCharacteristic:(EPTextCharacteristics)barButtonItem.tag]]];
    }
    NSRange selectedTextRange = [self selectedRange];
    if (!selectedTextRange.length)
        [self.attributeManager beginRunningTextCharacteristics:[self textCharacteristicsFromKeyboardBarButtonItems] atRange:selectedTextRange];
    else
        [self addAttributeWithType:(EPTextCharacteristics)barButtonItem.tag];
}

#pragma mark - Text Interactions

- (void)addAttributeWithType:(EPTextCharacteristics)textCharacteristics {
    NSRange selectedTextRange = [self selectedRange];
    if (!selectedTextRange.length)
        return;
    [self.attributeManager addAttributesWithTextCharacteristics:textCharacteristics atRange:selectedTextRange];
    [self updateTextViewText];
}

#pragma mark - Toolbar

- (void)drawToolbar {
    UIToolbar *keyboardToolbar = [[UIToolbar alloc] init];
    [keyboardToolbar sizeToFit];
    UIBarButtonItem *boldButton = [[UIBarButtonItem alloc] initWithTitle:@"B" style:UIBarButtonItemStylePlain target:self action:@selector(clickedBarButtonItem:)];
    [boldButton setTag:EPTextCharacteristicBold];
    [keyboardToolbar setItems:@[boldButton]];
    [self setInputAccessoryView:keyboardToolbar];
}

#pragma mark - Init

- (void)commonInit {
    self.attributeManager = [[EPAttributeManager alloc] init];
    self.delegate = self;
    [self drawToolbar];
}

- (id)initWithCoder:(nonnull NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder])
        [self commonInit];
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame])
        [self commonInit];
    return self;
}

- (id)initWithFrame:(CGRect)frame textContainer:(nullable NSTextContainer *)textContainer {
    if (self = [super initWithFrame:frame textContainer:textContainer])
        [self commonInit];
    return self;
}

- (id)init {
    if (self = [super init])
        [self commonInit];
    return self;
}

@end
