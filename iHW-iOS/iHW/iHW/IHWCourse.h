//
//  IHWCourse.h
//  iHW
//
//  Created by Jonathan Burns on 7/10/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IHWCourse : NSObject

@property (strong, nonatomic) NSArray *meetings;
@property (strong, nonatomic) NSString *name;
@property int period;
@property int term;

- (id)initWithName:(NSString *)n period:(int)p term:(int)t meetings:(NSArray *)m;
- (id)initWithJSONDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)saveCourse;

-(int)totalMeetings;
- (int)meetingOn:(int)dayNum;

@end
