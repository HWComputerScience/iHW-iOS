//
//  IHWCourse.h
//  iHW
//
//  Created by Andrew Friedman on 7/10/13.
//  Copyright (c) 2013 Andrew Friedman. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MEETING_X 0
#define MEETING_NORMAL 1
#define MEETING_DOUBLE_BEFORE 2
#define MEETING_DOUBLE_AFTER 3

#define TERM_SEMESTER_1 4
#define TERM_SEMESTER_2 5
#define TERM_TRIMESTER_1 6
#define TERM_TRIMESTER_2 7
#define TERM_TRIMESTER_3 8


@interface IHWCourse : NSObject

@property (strong, nonatomic) NSArray *meetings;
@property (strong, nonatomic) NSString *name;
@property int period;
@property int term;

- (id)initWithName:(NSString *)n period:(int)p term:(int)t meetings:(NSArray *)m;
- (id)initWithJSONDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)saveCourse;

-(int)getTotalMeetings;
- (int)getMeetingOn:(int)dayNum;

@end
