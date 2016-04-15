//
//  IHWUtils.m
//  iHW
//
//  Created by Jonathan Burns on 8/15/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import "IHWUtils.h"

NSString *getCampusChar(int campus) {
    NSString *campusChar = nil;
    if (campus==CAMPUS_MIDDLE) campusChar = @"m";
    else if (campus==CAMPUS_UPPER) campusChar = @"u";
    return campusChar;
}

int getWeekNumber(int year, IHWDate *d) {
    IHWDate *firstDate = [[[IHWDate alloc] initWithMonth:7 day:1 year:year] dateOfNextSunday];
    if ([d compare:firstDate] == NSOrderedAscending && [d compare:[[IHWDate alloc] initWithMonth:7 day:1 year:year]] != NSOrderedAscending) {
        //Week zero starts on 7/1 and goes until the Sunday after 7/1
        return 0;
    } else if ([d compare:[[IHWDate alloc] initWithMonth:7 day:1 year:year+1]] == NSOrderedAscending) {
        //Count weeks: the week starting with firstDate is one, increments every 7 days
        return ([firstDate daysUntilDate:d]/7)+1;
    } else {
        //Week is out of bounds
        return -1;
    }
}

IHWDate *getWeekStart(int year, IHWDate *d) {
    IHWDate *weekStart = [d dateOfPreviousSunday];
    IHWDate *july1 = [[IHWDate alloc] initWithMonth:7 day:1 year:year];
    if ([weekStart compare:july1] == NSOrderedAscending) weekStart = july1;
    return weekStart;
}

NSData *generateBlankYearJSON(int campus, int year) {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSNumber numberWithInt:year] forKey:@"year"];
    [dict setObject:[NSNumber numberWithInt:campus] forKey:@"campus"];
    [dict setObject:[NSMutableArray array] forKey:@"courses"];
    NSError *error = nil;
    NSData *result = [[CJSONSerializer serializer] serializeDictionary:dict error:&error];
    if (error==nil) return result;
    else return nil;
}

NSData *generateBlankWeekJSON(IHWDate *startingDate) {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:startingDate.description forKey:@"startingDate"];
    [dict setObject:[NSMutableDictionary dictionary] forKey:@"notes"];
    NSError *error = nil;
    NSData *result = [[CJSONSerializer serializer] serializeDictionary:dict error:&error];
    if (error==nil) return result;
    else return nil;
}

BOOL termsCompatible(int a, int b) {
    if (a==b) return NO;
    if (a==TERM_FULL_YEAR || b==TERM_FULL_YEAR) return NO;
    if (a==TERM_FIRST_SEMESTER) {
        if (b==TERM_FIRST_TRIMESTER || b==TERM_SECOND_TRIMESTER) return NO;
    } else if (a==TERM_SECOND_SEMESTER) {
        if (b==TERM_SECOND_TRIMESTER || b==TERM_THIRD_TRIMESTER) return NO;
    }
    if (b==TERM_FIRST_SEMESTER) {
        if (a==TERM_FIRST_TRIMESTER || a==TERM_SECOND_TRIMESTER) return NO;
    } else if (b==TERM_SECOND_SEMESTER) {
        if (a==TERM_SECOND_TRIMESTER || a==TERM_THIRD_TRIMESTER) return NO;
    }
    return YES;
}

NSString *stringForTerm(int term) {
    if (term==0) return @"Full Year";
    else if (term==1) return @"First Semester";
    else if (term==2) return @"Second Semester";
    else if (term==3) return @"First Trimester";
    else if (term==4) return @"Second Trimester";
    else if (term==5) return @"Third Trimester";
    else return @"";
}

NSString *getOrdinal(int num) {
    NSString *suffix;
    if (num%10==1) suffix = @"st";
    else if (num%10==2) suffix = @"nd";
    else if (num%10==3) suffix = @"rd";
    else suffix = @"th";
    return [NSString stringWithFormat:@"%d%@", num, suffix];
}

IHWCourse *parseCourse(NSString *code, NSString *name, NSArray *periodComponents) {
    //find term
    int term = TERM_FULL_YEAR;
    if (code.length >= 6) term = [[code substringWithRange:NSMakeRange(5, 1)] intValue];
    //parse period list
    int numDays = [IHWCurriculum currentCampus];
    int numPeriods = numDays+3;
    
    //parse class meetings into a 2-d C array
    BOOL meetingsArr[numDays][numPeriods+1];
    for (int d=0; d<numDays; d++) for (int p=0; p<=numPeriods; p++) {
        meetingsArr[d][p] = NO;
    }
    //We have to find which period the course meets the most
    int periodFrequency[numPeriods+1];
    for (int p=0; p<=numPeriods; p++) {
        periodFrequency[p] = 0;
    }
    int minPeriod = numPeriods+1;
    int maxPeriod = 0;
    int day = 0;
    NSLog(@"%@pcompons",periodComponents);
    for (NSString *component in periodComponents) {
        NSLog(@"component:%@",component);
        for (int i=0; i<component.length; i++) {
            //For each day,
            int period = [[component substringWithRange:NSMakeRange(i, 1)] intValue];
            if (period > 0) {
                //Add the periods it meets to the meetings array
                meetingsArr[day][period] = YES;
                //Update the min and max
                minPeriod = MIN(minPeriod, period);
                maxPeriod = MAX(maxPeriod, period);
                //Update the frequency
                periodFrequency[period]++;
            }
        }
        day++;
    }
    
    //determine course period
    int coursePeriod;
    NSLog(@"this is from parseCourse min period:%d,%d",minPeriod,maxPeriod);

    if (minPeriod == maxPeriod) {
        //course has no double periods
        coursePeriod = minPeriod;
    } else if (maxPeriod-minPeriod == 2) {
        //course doubles into the period before and the period after
        coursePeriod = maxPeriod-1;
    } else if (maxPeriod-minPeriod == 1 && periodFrequency[maxPeriod] > periodFrequency[minPeriod]) {
        //course doubles only into the period before
        coursePeriod = maxPeriod;
    } else if (maxPeriod-minPeriod == 1 && periodFrequency[maxPeriod] <= periodFrequency[minPeriod]) {
        //course doubles only into the period after
        coursePeriod = minPeriod;
    } else return nil;
    
    //create meetings array
    NSMutableArray *meetings = [NSMutableArray array];
    for (int i=0; i<numDays; i++) {
        if (!meetingsArr[i][coursePeriod]) {
            //no meeting today
            [meetings setObject:[NSNumber numberWithInt:MEETING_X_DAY] atIndexedSubscript:i];
        } else if (coursePeriod-1 > 0 && meetingsArr[i][coursePeriod-1]) {
            //double meeting into the period before
            [meetings setObject:[NSNumber numberWithInt:MEETING_DOUBLE_BEFORE] atIndexedSubscript:i];
        } else if (coursePeriod+1 <= numPeriods && meetingsArr[i][coursePeriod+1]) {
            //double period into the period after
            [meetings setObject:[NSNumber numberWithInt:MEETING_DOUBLE_AFTER] atIndexedSubscript:i];
        } else {
            //single period
            [meetings setObject:[NSNumber numberWithInt:MEETING_SINGLE_PERIOD] atIndexedSubscript:i];
        }
    }
    NSLog(@"this is from parseCourse%@, %d", name, coursePeriod);
    
    return [[IHWCourse alloc] initWithName:name period:coursePeriod term:term meetings:meetings];
}

