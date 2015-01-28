//
//  BackView.m
//  iHW
//
//  Created by Branden Kim on 1/28/15.
//  Copyright (c) 2015 Jonathan Burns. All rights reserved.
//

#import "BackView.h"

@implementation BackView 

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self == [super initWithFrame:frame]) {
        [self setBounds:frame];
        [self setBackgroundColor:[UIColor colorWithRed:255 green:0 blue:0 alpha:1]];
        
        done = [[UIButton alloc]initWithFrame:CGRectMake(0, 20, 50, self.frame.size.height)];
        [done setTitle:@"Done" forState:UIControlStateNormal];
        [self addSubview:done];
    }
    return self;
}

@end