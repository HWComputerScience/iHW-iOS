//
//  IHWNote.m
//  iHW
//
//  Created by Andrew Friedman on 7/10/13.
//  Copyright (c) 2013 Andrew Friedman. All rights reserved.
//

#import "IHWNote.h"

@implementation IHWNote

- (id)initWithText:(NSString *)val isToDo:(BOOL)todo isChecked:(BOOL)checked isImportant:(BOOL)important
{
    self = [super init];
    if (self) {
        self.text = val;
        self.isToDo = todo;
        self.isImportant = important;
    }
    return self;
}

- (id)initWithJSONDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        self.text = [dictionary objectForKey:@"text"];
        self.isToDo = [[dictionary objectForKey:@"isToDo"] boolValue];
        self.isChecked = [[dictionary objectForKey:@"isChecked"] boolValue];
        self.isImportant = [[dictionary objectForKey:@"isImportant"] boolValue];
    }
    return self;
}

- (NSDictionary *)saveNote {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:self.text forKey:@"text"];
    [dict setObject:[NSNumber numberWithBool:self.isToDo] forKey:@"isToDo"];
    [dict setObject:[NSNumber numberWithBool:self.isChecked] forKey:@"isChecked"];
    [dict setObject:[NSNumber numberWithBool:self.isImportant] forKey:@"isImportant"];
    return [NSDictionary dictionaryWithDictionary:dict];
}

- (BOOL)isEqual:(id)object {
    if (![object isMemberOfClass:[IHWNote class]]) return NO;
    IHWNote *other = (IHWNote *)object;
    return [self.text isEqualToString:other.text];
}

- (NSString *)description {
    return self.text;
}

@end
