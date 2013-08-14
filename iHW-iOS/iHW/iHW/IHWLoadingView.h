//
//  IHWLoadingView.h
//  iHW
//
//  Created by Jonathan Burns on 8/13/13.
//  Copyright (c) 2013 Andrew Friedman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IHWLoadingView : UIView

@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIView *popupView;

- (id)initWithText:(NSString *)message;
- (void)dismiss;

@end
