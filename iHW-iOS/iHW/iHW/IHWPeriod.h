//
//  IHWPeriod.h
//  iHW
//
//  Created by Andrew Friedman on 7/10/13.
//  Copyright (c) 2013 Andrew Friedman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IHWNote.h"

@interface IHWPeriod : NSObject

@property (strong, nonatomic) NSMutableArray *notes;
@property (strong, nonatomic) NSString *courseName;
@property int number;

-(void)addNote:(IHWNote *)note;
-(void)removeNoteByValue:(NSString *)value;
-(void)replaceNoteWithValue:(NSString *)value withNote:(IHWNote *)newNote;

@end
