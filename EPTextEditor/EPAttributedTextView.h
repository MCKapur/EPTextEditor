//
//  EPAttributedTextView.h
//  
//
//  Created by Rohan Kapur on 14/6/15.
//
//

#import <UIKit/UIKit.h>

/**
 A text view that supports
 rich editing eg. bolding,
 underlining, headings, links
 colors, images, etc. but is
 completely native without any
 use of HTML.
 
 NOTE: This subclass needs
 to be its own delegate so
 it can receive changes in
 text, selection, etc. that
 NSNotificationCenter does
 not provide.
 
 With that being said, it
 also stores a seperate 
 property called externalDelegate
 and if an outside class sets
 this class' delegate to self,
 it will actually set the externalDelegate
 property and that will be used
 to forward all delegate methods.
 */
@interface EPAttributedTextView : UITextView

@end
