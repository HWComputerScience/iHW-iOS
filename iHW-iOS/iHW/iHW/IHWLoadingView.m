//
//  IHWLoadingView.m
//  iHW
//
//  Created by Jonathan Burns on 8/13/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import "IHWLoadingView.h"
#import <QuartzCore/QuartzCore.h>

@implementation IHWLoadingView

- (id)initWithText:(NSString *)message
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        //Add this view directly to the screen, ignoring any on-screen viewcontrollers
        [[[[UIApplication sharedApplication] delegate] window] addSubview:self];
        
        //Necessary configuration stuff
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.25];
        self.alpha = 0;
        self.popupView = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.size.width/2-180/2, self.bounds.size.height/2-100/2, 180, 100)];
        [self addSubview:self.popupView];
        self.popupView.layer.cornerRadius = 10;
        self.popupView.layer.masksToBounds = YES;
        self.popupView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        
        //Configuration for textlabel
        self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 160, 30)];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.opaque = NO;
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.font = [UIFont boldSystemFontOfSize:20];
        self.textLabel.shadowColor = [UIColor blackColor];
        self.textLabel.shadowOffset = CGSizeMake(1, 1);
        self.textLabel.text = message;
        [self.popupView addSubview:self.textLabel];
        
        UIActivityIndicatorView *progressView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        progressView.frame = CGRectMake(70, 45, 40, 40);
        [self.popupView addSubview:progressView];
        [progressView startAnimating];
        
        //Fade in
        [UIView animateWithDuration:0.1 animations:^{
            self.alpha = 1;
        }];
    }
    return self;
}

- (void)dismiss {
    //Fade out
    [UIView animateWithDuration:0.1 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
}

@end
