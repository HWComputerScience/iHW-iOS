//
//  IHWNote.m
//  iHW
//
//  Created by Andrew Friedman on 7/10/13.
//  Copyright (c) 2013 Andrew Friedman. All rights reserved.
//

#import "IHWNote.h"

@implementation IHWNote

- (id)initWithValue:(NSString *)val isImportant:(BOOL)important isToDo:(BOOL)todo
{
    self = [super init];
    if (self) {
        self.value = val;
        self.isToDo = todo;
        self.isImportant = important;
    }
    return self;
}

@end
