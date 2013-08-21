//
//  UIViewController+IHW.m
//  iHW
//
//  Created by Jonathan Burns on 8/19/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import "UIViewController+IHW.h"

@implementation UIViewController (IHW)

- (void)applicationDidEnterBackground {
    [self.childViewControllers makeObjectsPerformSelector:@selector(applicationDidEnterBackground)];
}

@end
