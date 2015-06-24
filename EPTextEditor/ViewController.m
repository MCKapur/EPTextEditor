//
//  ViewController.m
//  EPTextEditor
//
//  Created by Rohan Kapur on 11/6/15.
//  Copyright (c) 2015 Rohan Kapur. All rights reserved.
//

#import "EPAttributedTextView.h"
#import "ViewController.h"

static CGFloat const EPAttributedTextViewTopMarginConstant = 20.0f;
static CGFloat const EPAttributedTextViewWidthMarginConstant = 5.0f;

@interface ViewController ()
@property (strong, readwrite, nonatomic) EPAttributedTextView *textView;
@end

@implementation ViewController

#pragma mark Setup

- (void)drawTextEditor {
    [self setTextView:[[EPAttributedTextView alloc] init]];
    [self.textView setTextColor:[UIColor blackColor]];
    [self.textView setShowsVerticalScrollIndicator:NO];
    [self.view addSubview:self.textView];
    [self.textView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addConstraints:@[[NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f], [NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:EPAttributedTextViewTopMarginConstant], [NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0f constant:-EPAttributedTextViewWidthMarginConstant], [NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0f]]];
}

#pragma mark View Lifecycle

- (void)viewDidLoad {
    [self drawTextEditor];
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
