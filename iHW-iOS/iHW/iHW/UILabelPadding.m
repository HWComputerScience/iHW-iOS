//
//  UILabelPadding.m
//  iHW
//
//  Created by Jonathan Burns on 4/13/14.
//  Copyright (c) 2014 Jonathan Burns. All rights reserved.
//

#import "UILabelPadding.h"

@implementation UILabelPadding

- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.edgeInsets)];
}

@end
