//
//  IHWLogic.m
//  iHW
//
//  Created by Andrew Friedman on 7/10/13.
//  Copyright (c) 2013 Andrew Friedman. All rights reserved.
//

#import "IHWCurriculum.h"
#import "IHWDate.h"
#import "IHWDay.h"
#import "CJSONSerializer.h"
#import "CJSONDeserializer.h"
#import "IHWFileManager.h"
#import "IHWHoliday.h"
#import "IHWNormalDay.h"
#import "IHWCustomDay.h"

static IHWCurriculum *currentCurriculum;

#pragma mark ***********************UTILITIES***************************

NSString *getCampusChar(int campus) {
    NSString *campusChar = nil;
    if (campus==CAMPUS_MIDDLE) campusChar = @"m";
    else if (campus==CAMPUS_UPPER) campusChar = @"u";
    return campusChar;
}

int getWeekNumber(int year, IHWDate *d) {
    IHWDate *firstDate = [[[IHWDate alloc] initWithMonth:7 day:1 year:year] dateOfNextSunday];
    if ([d compare:firstDate] == NSOrderedAscending && [d compare:[[IHWDate alloc] initWithMonth:7 day:1 year:year]] != NSOrderedAscending) return 0;
    else if ([d compare:[[IHWDate alloc] initWithMonth:7 day:1 year:year+1]] == NSOrderedAscending) return ([firstDate daysUntilDate:d]/7)+1;
    else return -1;
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

#pragma mark -
#pragma mark ****************PRIVATE INSTANCE VARS*****************

@implementation IHWCurriculum {
    BOOL currentlyCaching;
}

#pragma mark -
#pragma mark *******************STATIC STUFF***********************

+ (IHWCurriculum *)currentCurriculum {
    return currentCurriculum;
}

+ (IHWCurriculum *)getCurriculumWithCampus:(int)campus andYear:(int)year {
    if (currentCurriculum == nil || currentCurriculum.campus != campus || currentCurriculum.year != year)
        currentCurriculum = [[IHWCurriculum alloc] initWithCampus:campus year:year startingDate:[[IHWDate alloc] init]];
    return currentCurriculum;
}

+ (int)currentYear {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"currentYear"];
}

+ (int)currentCampus {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"currentCampus"];
}

+ (void)setCurrentYear:(int)year {
    [[NSUserDefaults standardUserDefaults] setInteger:year forKey:@"currentYear"];
}

+ (void)setCurrentCampus:(int)campus {
    [[NSUserDefaults standardUserDefaults] setInteger:campus forKey:@"currentCampus"];
}

+ (BOOL)isFirstRun {
    if ([IHWCurriculum currentYear] == 0 || [IHWCurriculum currentCampus] == 0) return YES;
    else
       /* NSString *campusChar = getCampusChar([IHWCurriculum currentCampus]);
        SharedPreferences prefs = ctx.getSharedPreferences(getCurrentYear() + campusChar, Context.MODE_PRIVATE);
        NSString *yearJSON = prefs.getString("yearJSON", "");
        if (yearJSON.equals("")) return true;
        return new JSONObject(yearJSON).getJSONArray("courses").length() == 0;*/
    return false;
}

#pragma mark -
#pragma mark ******************INSTANCE STUFF**********************

- (id)initWithCampus:(int)campus year:(int)year startingDate:(IHWDate *)date
{
    self = [super init];
    if (self) {
#pragma mark TODO init
    }
    return self;
}

- (void)loadEverything {
#pragma mark TODO load everything!
}

- (IHWDate *)firstLoadedDate {
    if (self.loadedDays == nil || self.loadedDays.count == 0) return nil;
    else return [self.loadedDays keyAtIndex:0];
}

- (IHWDate *)lastLoadedDate {
    if (self.loadedDays == nil || self.loadedDays.count == 0) return nil;
    else return [self.loadedDays keyAtIndex:self.loadedDays.count];
}

- (BOOL)dayIsLoaded:(IHWDate *)date {
    return (self.loadedDays != nil
            && [self.loadedDays objectForKey:date] != nil
            && self.loadedWeeks != nil
            && [self.loadedWeeks objectForKey:getWeekStart(self.year, date)] != nil);
}

- (BOOL)downloadParseScheduleJSON:(BOOL)important {
#pragma mark TODO download and parse schedule JSON
    return NO;
}

- (BOOL)parseScheduleJSON {
#pragma mark TODO parse schedule JSON
    return NO;
}

- (BOOL)loadCourses {
#pragma mark TODO load courses
    return NO;
}

- (BOOL)loadDayNumbers {
#pragma mark TODO load day numbers
    return NO;
}

- (BOOL)loadWeekAndDay:(IHWDate *)date {
    BOOL success = [self loadWeek:date];
    if (!success) { NSLog(@"ERROR loading week: %@", date.description); return NO; }
    success = [self loadDay:date];
    if (!success) { NSLog(@"ERROR loading day: %@", date.description); return NO; }
    return YES;
}

- (BOOL)loadWeek:(IHWDate *)date {
    int weekNumber = getWeekNumber(self.year, date);
    IHWDate *weekStart = getWeekStart(self.year, date);
    if (self.loadedWeeks != nil && [self.loadedWeeks objectForKey:weekStart] != nil) return YES;
    if (weekNumber == -1) return NO;
    NSData *weekJSON = [IHWFileManager loadWeekJSONForWeekNumber:weekNumber year:self.year campus:getCampusChar(self.campus)];
    if (weekJSON == nil) weekJSON = generateBlankWeekJSON(weekStart);
    NSError *error = nil;
    NSDictionary *weekDict = [[CJSONDeserializer deserializer] deserializeAsDictionary:weekJSON error:&error];
    if (error == nil) {
        if (self.loadedWeeks == nil) self.loadedWeeks = [MutableOrderedDictionary dictionary];
        [self.loadedWeeks insertObject:weekDict forKey:weekStart sortedUsingComparator:[IHWDate comparator]];
    }
    else NSLog(@"%@", error.localizedDescription);
    return error == nil;
}

- (BOOL)loadDay:(IHWDate *)date {
    if (![self dateInBounds:date]) return NO;
    if (self.loadedDays == nil) self.loadedDays = [MutableOrderedDictionary dictionary];
    if ([date compare:[self.semesterEndDates objectAtIndex:0]] == NSOrderedAscending
        || [date compare:[self.semesterEndDates objectAtIndex:2]] == NSOrderedDescending) {
        //Date is during Summer
        [self.loadedDays insertObject:[[IHWHoliday alloc] initWithName:@"Summer" onDate:date] forKey:date sortedUsingComparator:[IHWDate comparator]];
    } else if (date.isWeekend) {
        [self.loadedDays insertObject:[[IHWHoliday alloc] initWithName:@"" onDate:date] forKey:date sortedUsingComparator:[IHWDate comparator]];
    }
    NSDictionary *template = [self.specialDayTemplates objectForKey:date];
    if (template==nil && date.isMonday) {
        NSMutableDictionary *dict = [self.normalMondayTemplate mutableCopy];
        [dict setObject:date.description forKey:@"date"];
        [dict setObject:[self.dayNumbers objectForKey:date] forKey:@"dayNumber"];
        template = dict;
    } else if (template==nil) {
        NSMutableDictionary *dict = [self.normalDayTemplate mutableCopy];
        [dict setObject:date.description forKey:@"date"];
        [dict setObject:[self.dayNumbers objectForKey:date] forKey:@"dayNumber"];
        template = dict;
    }
    NSString *type = [template objectForKey:@"type"];
    IHWDay *day;
    if ([type isEqualToString:@"normal"]) {
        day = [[IHWNormalDay alloc] initWithJSONDictionary:template];
        [(IHWNormalDay *)day fillPeriodsFromCurriculum:self];
    } else if ([type isEqualToString:@"test"]) {
        day = [[IHWNormalDay alloc] initWithJSONDictionary:template];
    } else if ([type isEqualToString:@"holiday"]) {
        day = [[IHWHoliday alloc] initWithJSONDictionary:template];
    } else return NO;
    [self.loadedDays insertObject:day forKey:date sortedUsingComparator:[IHWDate comparator]];
    return YES;
}

- (IHWDay *)getDayWithDate:(IHWDate *)date {
    if (![self dateInBounds:date]) return nil;
    if (![self dayIsLoaded:date]) {
        BOOL success = [self loadWeekAndDay:date];
        if (!success) return nil;
    }
    if (![self dayIsLoaded:date]) return nil;
    return [self.loadedDays objectForKey:date];
}

- (void)clearUnneededItems:(IHWDate *)date {
    IHWDate *weekStart = getWeekStart(self.year, date);
    NSMutableSet *weeksNeeded = [NSMutableSet setWithCapacity:3];
    [weeksNeeded addObject:getWeekStart(self.year, [weekStart dateByAddingDays:-1])];
    [weeksNeeded addObject:weekStart];
    [weeksNeeded addObject:getWeekStart(self.year, [weekStart dateByAddingDays:7])];
    if (self.loadedWeeks != nil) [self.loadedWeeks filterKeysFromSet:weeksNeeded];
    NSMutableSet *daysNeeded = [NSMutableSet setWithCapacity:7];
    for (int i=-3; i<=3; i++) [daysNeeded addObject:[date dateByAddingDays:i]];
    if (self.loadedDays != nil) [self.loadedDays filterKeysFromSet:daysNeeded];
}

- (BOOL)dateInBounds:(IHWDate *)date {
    return (date != nil
            && [date compare:[[IHWDate alloc] initWithMonth:7 day:1 year:self.year]] != NSOrderedAscending
            && [date compare:[[IHWDate alloc] initWithMonth:7 day:1 year:self.year+1]] == NSOrderedAscending);
}

@end
