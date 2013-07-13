//
//  IHWNote.h
//  iHW
//
//  Created by Andrew Friedman on 7/10/13.
//  Copyright (c) 2013 Andrew Friedman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IHWNote : NSObject

@property (strong, nonatomic) NSString *value;
@property BOOL isToDo;
@property BOOL isImportant;
@property BOOL isChecked;

- (id)initWithValue:(NSString *)val isImportant:(BOOL)important isToDo:(BOOL)todo;

@end
