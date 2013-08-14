//
//  IHWFileManager.h
//  iHW
//
//  Created by Jonathan Burns on 8/8/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IHWFileManager : NSObject

+ (BOOL)saveScheduleJSON:(NSData *)json forYear:(int)year campus:(NSString *)campusChar;
+ (NSData *)loadScheduleJSONForYear:(int)year campus:(NSString *)campusChar;

+ (BOOL)saveYearJSON:(NSData *)json forYear:(int)year campus:(NSString *)campusChar;
+ (NSData *)loadYearJSONForYear:(int)year campus:(NSString *)campusChar;

+ (BOOL)saveWeekJSON:(NSData *)json forWeekNumber:(int)weekNumber year:(int)year campus:(NSString *)campusChar;
+ (NSData *)loadWeekJSONForWeekNumber:(int)weekNumber year:(int)year campus:(NSString *)campusChar;

@end
