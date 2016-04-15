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

//Get either "u" or "m" from `5` or `6`, respectively.
NSString *getCampusChar(int campus);

//Get the week number for any given date.
int getWeekNumber(int year, IHWDate *d);

//Get the week start date for the week that contains the given date.
IHWDate *getWeekStart(int year, IHWDate *d);

//Generate a blank year JSON file (for courses) for the given campus and year.
NSData *generateBlankYearJSON(int campus, int year);

//Generate a blank week JSON file (for notes) for the given week start date.
NSData *generateBlankWeekJSON(IHWDate *startingDate);

//Return whether two terms occur during the same time period.
    //i.e. first semester and second semester are compatible,
    //but first semester and second trimester are incompatible.
BOOL termsCompatible(int a, int b);

//Return the user-readable text for the given term.
NSString *stringForTerm(int term);

//Return the user-readable ordinal string for a given integer. (i.e. 2nd, 3rd, 21st)
NSString *getOrdinal(int num);

//Parse a course code, name, and period components into an IHWCourse object.
IHWCourse *parseCourse(NSString *code, NSString *name, NSArray *periodComponents);