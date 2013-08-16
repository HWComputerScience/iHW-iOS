//
//  IHWUtils.h
//  iHW
//
//  Created by Jonathan Burns on 8/15/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <stdio.h>
#import "IHWConstants.h"
#import "CJSONSerializer.h"
#import "IHWCourse.h"
#import "IHWCurriculum.h"

NSString *getCampusChar(int campus);
int getWeekNumber(int year, IHWDate *d);
IHWDate *getWeekStart(int year, IHWDate *d);
NSData *generateBlankYearJSON(int campus, int year);
NSData *generateBlankWeekJSON(IHWDate *startingDate);
BOOL termsCompatible(int a, int b);

NSString *stringForTerm(int term);
NSString *getOrdinal(int num);
IHWCourse *parseCourse(NSString *code, NSString *name, NSArray *periodComponents);