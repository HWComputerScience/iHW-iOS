//
//  IHWPeriod.m
//  iHW
//
//  Created by Andrew Friedman on 7/10/13.
//  Copyright (c) 2013 Andrew Friedman. All rights reserved.
//

#import "IHWPeriod.h"
#import "IHWNote.h"

@implementation IHWPeriod

-(void)addNote:(IHWNote *)note {
    [self.notes addObject:note];
}
-(void)removeNoteByValue:(NSString *)value {
    for (int index = 0; index < self.notes.count; index++) {
        if ([((IHWNote *)[self.notes objectAtIndex:index]).value isEqualToString:value]) {
            [self.notes removeObjectAtIndex:index];
            return;
        }
    }
}

-(void)replaceNoteWithValue:(NSString *)value withNote:(IHWNote *)newNote {
    for (int index = 0; index < self.notes.count; index++) {
        if ([((IHWNote *)[self.notes objectAtIndex:index]).value isEqualToString:value]) {
            [self.notes replaceObjectAtIndex:index withObject:newNote];
            return;
        }
    }
}

@end
