//
//  IHWNote.h
//  iHW
//
//  Created by Andrew Friedman on 7/10/13.
//  Copyright (c) 2013 Andrew Friedman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IHWNote : NSObject

@property (strong, nonatomic) NSString *text;
@property BOOL isToDo;
@property BOOL isImportant;
@property BOOL isChecked;

- (id)initWithText:(NSString *)val isToDo:(BOOL)todo isChecked:(BOOL)checked isImportant:(BOOL)important;
- (id)initWithJSONDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)saveNote;
- (BOOL)isEqual:(id)object;
- (NSString *)description;

@end
