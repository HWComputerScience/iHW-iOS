//
//  IHWCourse.h
//  iHW
//
//  Created by Andrew Friedman on 6/14/13.
//  Copyright (c) 2013 Andrew Friedman. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MEETING_X_DAY 0
#define MEETING_SINGLE_PERIOD 1
#define MEETING_DOUBLE_BEFORE 2
#define MEETING_DOUBLE_AFTER 3

@interface IHWCourse : NSObject

@property NSArray *meetings;
@property NSString *name;
@property int term;
@property int period; 


@end
