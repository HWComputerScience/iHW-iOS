//
//  IHWLogic.m
//  iHW
//
//  Created by Jonathan Burns on 7/10/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import "IHWCurriculum.h"
#import "CJSONSerializer.h"
#import "CJSONDeserializer.h"
#import "IHWFileManager.h"
#import "IHWHoliday.h"
#import "IHWNormalDay.h"
#import "IHWCustomDay.h"
#import "IHWUtils.h"

static IHWCurriculum *currentCurriculum;

#pragma mark ****************PRIVATE INSTANCE VARS*****************

@implementation IHWCurriculum {
    BOOL currentlyCaching;
}

#pragma mark -
#pragma mark *******************STATIC STUFF***********************

+ (IHWCurriculum *)currentCurriculum {
    return [self curriculumWithCampus:[self currentCampus] andYear:[self currentYear]];
}

+ (IHWCurriculum *)curriculumWithCampus:(int)campus andYear:(int)year {
    if (currentCurriculum == nil || currentCurriculum.campus != campus || currentCurriculum.year != year) {
        [self setCurrentCampus:campus];
        [self setCurrentYear:year];
        NSLog(@"Creating current curriculum: %@", [IHWDate IHWDate]);
        currentCurriculum = [[IHWCurriculum alloc] initWithCampus:campus year:year startingDate:[IHWDate IHWDate]];
    } else {
        if (!currentCurriculum.isLoaded && !currentCurriculum.isLoading) [currentCurriculum loadEverythingWithStartingDate:[IHWDate IHWDate]];
    }
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
    else {
        NSString *campusChar = getCampusChar([IHWCurriculum currentCampus]);
        NSData *yearJSON = [IHWFileManager loadYearJSONForYear:[IHWCurriculum currentYear] campus:campusChar];
        if (yearJSON == nil || [yearJSON isEqualToData:[NSData data]]) return YES;
        NSError *error;
        NSDictionary *yearDict = [[CJSONDeserializer deserializer] deserializeAsDictionary:yearJSON error:&error];
        if (error != nil || yearDict == nil) return YES;
        if ([yearDict objectForKey:@"courses"] == nil || [[yearDict objectForKey:@"courses"] count] == 0) return YES;
    }
    return NO;
}

#pragma mark -
#pragma mark ******************INSTANCE STUFF**********************
#pragma mark -
#pragma mark ******************LOADING STUFF***********************

- (id)initWithCampus:(int)campus year:(int)year startingDate:(IHWDate *)date
{
    self = [super init];
    if (self) {
        self.campus = campus;
        self.year = year;
        self.loadingProgress = -1;
        self.curriculumLoadingListeners = [[NSMutableSet alloc] init];
        IHWDate *earliest = [[IHWDate alloc] initWithMonth:7 day:1 year:year];
        IHWDate *latest = [[[IHWDate alloc] initWithMonth:7 day:1 year:year+1] dateByAddingDays:-1];
        if ([date compare:earliest] == NSOrderedAscending) date = earliest;
        else if ([date compare:latest] == NSOrderedDescending) date = latest;
        [self loadEverythingWithStartingDate:date];
    }
    return self;
}

- (void)loadEverythingWithStartingDate:(IHWDate *)date {
    NSLog(@">loading everything");
    if (self.loadingProgress >= 0) return;
    self.loadingProgress = 0;
    self.loadingQueue = [[NSOperationQueue alloc] init];
    NSBlockOperation *loadSchedule = [NSBlockOperation blockOperationWithBlock:^{
        if (![self downloadParseScheduleJSON]) [self performSelectorOnMainThread:@selector(loadingFailed) withObject:nil waitUntilDone:NO];
    }];
    NSBlockOperation *loadCourses = [NSBlockOperation blockOperationWithBlock:^{
        if (![self loadCourses]) [self performSelectorOnMainThread:@selector(loadingFailed) withObject:nil waitUntilDone:NO];
    }];
    NSBlockOperation *loadDayNumbers = [NSBlockOperation blockOperationWithBlock:^{
        if (![self loadDayNumbers]) [self performSelectorOnMainThread:@selector(loadingFailed) withObject:nil waitUntilDone:NO];
    }];
    [loadDayNumbers addDependency:loadSchedule];
    NSBlockOperation *loadWeekAndDay = [NSBlockOperation blockOperationWithBlock:^{
        if (![self loadWeekAndDay:date]) [self performSelectorOnMainThread:@selector(loadingFailed) withObject:nil waitUntilDone:NO];
    }];
    [loadWeekAndDay addDependency:loadSchedule];
    [loadWeekAndDay addDependency:loadDayNumbers];
    [loadWeekAndDay addDependency:loadCourses];
    [self.loadingQueue addOperation:loadSchedule];
    [self.loadingQueue addOperation:loadCourses];
    [self.loadingQueue addOperation:loadDayNumbers];
    [self.loadingQueue addOperation:loadWeekAndDay];
    [self.loadingQueue addObserver:self forKeyPath:@"operationCount" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)loadingFailed {
    [self.loadingQueue setSuspended:YES];
    self.loadingProgress = -1;
    for (NSObject<IHWCurriculumLoadingListener> *mll in self.curriculumLoadingListeners) {
        if ([mll respondsToSelector:@selector(curriculumFailedToLoad:)]) [mll performSelectorOnMainThread:@selector(curriculumFailedToLoad:) withObject:self waitUntilDone:NO];
    }
}

- (BOOL)isLoading {
    return (self.loadingProgress == 0);
}

- (BOOL)isLoaded {
    return (self.loadingProgress == 1);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"operationCount"] && object == self.loadingQueue) {
        NSLog(@"loading queue changed count: %d", self.loadingQueue.operationCount);
        if (self.loadingQueue.operationCount == 0) {
            [self.loadingQueue removeObserver:self forKeyPath:@"operationCount"];
            self.loadingQueue = nil;
            self.loadingProgress = 1;
            for (NSObject<IHWCurriculumLoadingListener> *mll in self.curriculumLoadingListeners) {
                if ([mll respondsToSelector:@selector(curriculumFinishedLoading:)]) [mll performSelectorOnMainThread:@selector(curriculumFinishedLoading:) withObject:self waitUntilDone:NO];
                
            }
        }
    }
}

/*
- (IHWDate *)firstLoadedDate {
    if (self.loadedDays == nil || self.loadedDays.count == 0) return nil;
    else return [self.loadedDays keyAtIndex:0];
}

- (IHWDate *)lastLoadedDate {
    if (self.loadedDays == nil || self.loadedDays.count == 0) return nil;
    else return [self.loadedDays keyAtIndex:self.loadedDays.count];
}*/

- (BOOL)dayIsLoaded:(IHWDate *)date {
    return (self.loadedDays != nil
            && [self.loadedDays objectForKey:date] != nil
            && self.loadedWeeks != nil
            && [self.loadedWeeks objectForKey:getWeekStart(self.year, date)] != nil);
}

- (BOOL)downloadParseScheduleJSON {
    NSLog(@">downloading schedule JSON");
    NSError *error = nil;
    NSURLResponse *response = nil;
    NSString *urlStr = [NSString stringWithFormat:@"http://www.burnsfamily.info/curriculum%d%@.hws", self.year, getCampusChar(self.campus)];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
    NSData *scheduleJSON = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    //NSData *scheduleJSON = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr] options:0 error:&error];
    NSString *campusChar = getCampusChar(self.campus);
    if (error != nil) {
        NSLog(@"ERROR downloading schedule JSON: %@", error.debugDescription);
        scheduleJSON = [IHWFileManager loadScheduleJSONForYear:self.year campus:campusChar];
    }
    if (scheduleJSON == nil) return NO;
    else [self parseScheduleJSON:scheduleJSON];
    [IHWFileManager saveScheduleJSON:scheduleJSON forYear:self.year campus:campusChar];
    return YES;
}

- (BOOL)parseScheduleJSON:(NSData *)scheduleJSON {
    NSLog(@">parsing schedule JSON");
    NSError *error = nil;
    NSDictionary *scheduleDict = [[CJSONDeserializer deserializer] deserializeAsDictionary:scheduleJSON error:&error];
    if (error != nil) { NSLog(@"ERROR parsing schedule JSON: %@", error.debugDescription); return NO; }
    NSMutableArray *semesterEndDates = [NSMutableArray array];
    for (NSString *str in [scheduleDict objectForKey:@"semesterEndDates"]) {
        [semesterEndDates addObject:[[IHWDate alloc] initFromString:str]];
    }
    self.semesterEndDates = semesterEndDates;
    NSMutableArray *trimesterEndDates = [NSMutableArray array];
    for (NSString *str in [scheduleDict objectForKey:@"trimesterEndDates"]) {
        [trimesterEndDates addObject:[[IHWDate alloc] initFromString:str]];
    }
    self.trimesterEndDates = trimesterEndDates;
    self.normalDayTemplate = [scheduleDict objectForKey:@"normalDay"];
    self.normalMondayTemplate = [scheduleDict objectForKey:@"normalMonday"];
    self.passingPeriodLength = [[scheduleDict objectForKey:@"passingPeriodLength"] intValue];
    
    NSMutableDictionary *specialDays = [[NSMutableDictionary alloc] init];
    NSDictionary *specialDaysJSON = [scheduleDict objectForKey:@"specialDays"];
    for (NSString *dateStr in [specialDaysJSON allKeys]) {
        [specialDays setObject:[specialDaysJSON objectForKey:dateStr] forKey:[[IHWDate alloc] initFromString:dateStr]];
    }
    self.specialDayTemplates = [NSDictionary dictionaryWithDictionary:specialDays];
    return YES;
}

- (BOOL)loadCourses {
    NSLog(@">loading courses");
    NSMutableSet *courseSet = [NSMutableSet set];
    NSError *error = nil;
    NSData *json = [IHWFileManager loadYearJSONForYear:self.year campus:getCampusChar(self.campus)];
    if (json == nil || [json isEqualToData:[NSData data]]) json = generateBlankYearJSON(self.campus, self.year);
    NSDictionary *fromJSON = [[CJSONDeserializer deserializer] deserializeAsDictionary:json error:&error];
    NSArray *coursesJSON = [fromJSON objectForKey:@"courses"];
    if (error != nil) { NSLog(@"ERROR loading courses: %@", error.debugDescription); return NO; }
    for (NSDictionary *dict in coursesJSON) {
        IHWCourse *course = [[IHWCourse alloc] initWithJSONDictionary:dict];
        [courseSet addObject:course];
    }
    self.courses = courseSet;
    return YES;
}

- (BOOL)loadDayNumbers {
    NSLog(@">loading day numbers");
    if (self.specialDayTemplates == nil || self.semesterEndDates == nil) return NO;
    NSMutableDictionary *dayNums = [[NSMutableDictionary alloc] init];
    IHWDate *d = [self.semesterEndDates objectAtIndex:0];
    int dayNum = 1;
    while ([d compare:[self.semesterEndDates objectAtIndex:2]] != NSOrderedDescending) {
        if ([self.specialDayTemplates objectForKey:d] != nil) {
            if ([[[self.specialDayTemplates objectForKey:d] objectForKey:@"type"] isEqualToString:@"normal"]) {
                int thisNum = [[[self.specialDayTemplates objectForKey:d] objectForKey:@"dayNumber"] intValue];
                if (thisNum != 0) dayNum = thisNum+1;
                [dayNums setObject:[NSNumber numberWithInt:thisNum] forKey:d];
            } else {
                [dayNums setObject:[NSNumber numberWithInt:0] forKey:d];
            }
        } else if (![d isWeekend]) {
            [dayNums setObject:[NSNumber numberWithInt:dayNum] forKey:d];
            dayNum++;
        }
        if (dayNum > self.campus) dayNum -= self.campus;
        d = [d dateByAddingDays:1];
    }
    self.dayNumbers = dayNums;
    return YES;
}

- (BOOL)loadWeekAndDay:(IHWDate *)date {
    NSLog(@">loading week and day");
    BOOL success = [self loadWeek:date];
    if (!success) { NSLog(@"ERROR loading week: %@", date.description); return NO; }
    success = [self loadDay:date];
    if (!success) { NSLog(@"ERROR loading day: %@", date.description); return NO; }
    return YES;
}

- (BOOL)loadWeek:(IHWDate *)date {
    NSLog(@">loading week");
    int weekNumber = getWeekNumber(self.year, date);
    IHWDate *weekStart = getWeekStart(self.year, date);
    if (self.loadedWeeks != nil && [self.loadedWeeks objectForKey:weekStart] != nil) return YES;
    if (weekNumber == -1) return NO;
    NSData *weekJSON = [IHWFileManager loadWeekJSONForWeekNumber:weekNumber year:self.year campus:getCampusChar(self.campus)];
    if (weekJSON == nil) weekJSON = generateBlankWeekJSON(weekStart);
    NSError *error = nil;
    NSDictionary *weekDict = [[CJSONDeserializer deserializer] deserializeAsDictionary:weekJSON error:&error];
    if (error == nil) {
        if (self.loadedWeeks == nil) self.loadedWeeks = [NSMutableDictionary dictionary];
        //[self.loadedWeeks insertObject:weekDict forKey:weekStart sortedUsingComparator:[IHWDate comparator]];
        [self.loadedWeeks setObject:weekDict forKey:weekStart];
    }
    else NSLog(@"ERROR loading week: %@", error.debugDescription);
    return error == nil;
}

- (BOOL)loadDay:(IHWDate *)date {
    NSLog(@">loading day: %@", date);
    if (![self dateInBounds:date]) return NO;
    if (self.loadedDays == nil) self.loadedDays = [NSMutableDictionary dictionary];
    if ([date compare:[self.semesterEndDates objectAtIndex:0]] == NSOrderedAscending
        || [date compare:[self.semesterEndDates objectAtIndex:2]] == NSOrderedDescending) {
        //Date is during Summer
        //[self.loadedDays insertObject:[[IHWHoliday alloc] initWithName:@"Summer" onDate:date] forKey:date sortedUsingComparator:[IHWDate comparator]];
        [self.loadedDays setObject:[[IHWHoliday alloc] initWithName:@"Summer" onDate:date] forKey:date];
        return YES;
    } else if (date.isWeekend) {
        //[self.loadedDays insertObject:[[IHWHoliday alloc] initWithName:@"" onDate:date] forKey:date sortedUsingComparator:[IHWDate comparator]];
        [self.loadedDays setObject:[[IHWHoliday alloc] initWithName:@"" onDate:date] forKey:date];
        return YES;
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
    //[self.loadedDays insertObject:day forKey:date sortedUsingComparator:[IHWDate comparator]];
    [self.loadedDays setObject:day forKey:date];
    return YES;
}

- (IHWDay *)dayWithDate:(IHWDate *)date {
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
#pragma mark todo replace this
    //if (self.loadedWeeks != nil) [self.loadedWeeks filterKeysFromSet:weeksNeeded];
    NSMutableSet *daysNeeded = [NSMutableSet setWithCapacity:7];
    for (int i=-3; i<=3; i++) [daysNeeded addObject:[date dateByAddingDays:i]];
    //if (self.loadedDays != nil) [self.loadedDays filterKeysFromSet:daysNeeded];
}

- (BOOL)dateInBounds:(IHWDate *)date {
    return (date != nil
            && [date compare:[[IHWDate alloc] initWithMonth:7 day:1 year:self.year]] != NSOrderedAscending
            && [date compare:[[IHWDate alloc] initWithMonth:7 day:1 year:self.year+1]] == NSOrderedAscending);
}

#pragma mark -
#pragma mark *******************COURSES STUFF**********************

- (NSArray *)allCourseNames {
    NSMutableArray *array = [NSMutableArray array];
    for (IHWCourse *c in self.courses) {
        [array addObject:c.name];
    }
    return [NSArray arrayWithArray:array];
}

- (BOOL)addCourse:(IHWCourse *)c {
    for (IHWCourse *check in self.courses) {
        if (!termsCompatible(check.term, c.term)) {
            if (check.period == c.period) {
                for (int i=1; i<=self.campus; i++) {
                    if ([c meetingOn:i] != MEETING_X_DAY && [check meetingOn:i] != MEETING_X_DAY) return NO;
                }
            } else {
                IHWCourse *later;
                IHWCourse *earlier;
                if (c.period > check.period) {
                    later = c;
                    earlier = check;
                } else {
                    later = check;
                    earlier = c;
                }
                if (ABS(c.period-check.period) == 1) {
                    for (int i=1; i<=self.campus; i++) {
                        if ([earlier meetingOn:i] == MEETING_DOUBLE_AFTER && [later meetingOn:i] != MEETING_X_DAY) return NO;
                        if ([later meetingOn:i] == MEETING_DOUBLE_BEFORE && [earlier meetingOn:i] != MEETING_X_DAY) return NO;
                    }
                } else if (ABS(c.period-check.period) == 2) {
                    for (int i=1; i<=self.campus; i++) {
                        if ([earlier meetingOn:i] == MEETING_DOUBLE_AFTER && [later meetingOn:i] == MEETING_DOUBLE_BEFORE) return NO;
                    }
                }
            }
        }
    }
    [self.courses addObject:c];
    [self.loadedDays removeAllObjects];
    return YES;
}

- (void)removeCourse:(IHWCourse *)c {
    [self.courses removeObject:c];
    [self.loadedDays removeAllObjects];
}

- (void)removeAllCourses {
    [self.courses removeAllObjects];
    [self.loadedDays removeAllObjects];
}

- (BOOL)replaceCourseWithName:(NSString *)oldName withCourse:(IHWCourse *)c {
    IHWCourse *oldCourse = [self courseWithName:oldName];
    [self removeCourse:oldCourse];
    if ([self addCourse:c]) return YES;
    else {
        [self addCourse:oldCourse];
        return NO;
    }
}

- (IHWCourse *)courseWithName:(NSString *)name {
    for (IHWCourse *c in self.courses) if ([c.name isEqualToString:name]) return c;
    return nil;
}

- (IHWCourse *)courseMeetingOnDate:(IHWDate *)d period:(int)period {
    if ([d compare:[self.semesterEndDates objectAtIndex:0]] == NSOrderedAscending
        || [d compare:[self.semesterEndDates objectAtIndex:2]] == NSOrderedDescending) return nil;
    int dayNum = [[self.dayNumbers objectForKey:d] intValue];
    NSArray *terms = [self termsFromDate:d];
    if (dayNum == 0) {
        IHWCourse *maxMeetings = nil;
        int max = 1;
        for (IHWCourse *c in self.courses) {
            BOOL termFound = NO;
            for (NSNumber *term in terms) if ([term intValue] == c.term) {
                termFound = YES;
                break;
            }
            if (!termFound) continue;
            if (c.period == period && c.totalMeetings > max) {
                maxMeetings = c;
                max = c.totalMeetings;
            }
        }
        return maxMeetings;
    }
    for (IHWCourse *c in self.courses) {
        BOOL termFound = NO;
        for (NSNumber *term in terms) if ([term intValue] == c.term) {
            termFound = YES;
            break;
        }
        if (!termFound) continue;
        if (c.period == period) {
            if ([c meetingOn:dayNum] != MEETING_X_DAY) return c;
        } else if (period == c.period-1) {
            if ([c meetingOn:dayNum] == MEETING_DOUBLE_BEFORE) return c;
        } else if (period == c.period+1) {
            if ([c meetingOn:dayNum] == MEETING_DOUBLE_AFTER) return c;
        }
    }
    return nil;
}

- (NSArray *)courseListForDate:(IHWDate *)d {
    if ([d compare:[self.semesterEndDates objectAtIndex:0]] == NSOrderedAscending
        || [d compare:[self.semesterEndDates objectAtIndex:2]] == NSOrderedDescending) return nil;
    int dayNum = [[self.dayNumbers objectForKey:d] intValue];
    NSArray *terms = [self termsFromDate:d];
    NSMutableArray *courseList = [NSMutableArray arrayWithCapacity:self.campus+4];
    NSMutableArray *maxMeetings = [NSMutableArray arrayWithCapacity:self.campus+4];
    for (int i=0; i<self.campus+4; i++) {
        [courseList setObject:[NSNull null] atIndexedSubscript:i];
        [maxMeetings setObject:[NSNumber numberWithInt:0] atIndexedSubscript:i];
    }
    for (IHWCourse *c in self.courses) {
        if (![terms containsObject:[NSNumber numberWithInt:c.term]]) continue;
        if (dayNum == 0) {
            int meetings = c.totalMeetings;
            if (meetings > [[maxMeetings objectAtIndex:c.period] intValue]) {
                [courseList setObject:c atIndexedSubscript:c.period];
                [maxMeetings setObject:[NSNumber numberWithInt:meetings] atIndexedSubscript:c.period];
            }
        } else if ([c meetingOn:dayNum] != MEETING_X_DAY) {
            [courseList setObject:c atIndexedSubscript:c.period];
            if ([c meetingOn:dayNum] == MEETING_DOUBLE_BEFORE)
                [courseList setObject:c atIndexedSubscript:c.period-1];
            else if ([c meetingOn:dayNum] == MEETING_DOUBLE_AFTER)
                [courseList setObject:c atIndexedSubscript:c.period+1];
        }
    }
    return [NSArray arrayWithArray:courseList];
}

- (NSArray *)termsFromDate:(IHWDate *)d {
    NSMutableArray *array = [NSMutableArray array];
    if ([d compare:[self.semesterEndDates objectAtIndex:0]] != NSOrderedAscending) {
        if ([d compare:[self.semesterEndDates objectAtIndex:1]] != NSOrderedDescending) {
            [array addObject:[NSNumber numberWithInt:TERM_FULL_YEAR]];
            [array addObject:[NSNumber numberWithInt:TERM_FIRST_SEMESTER]];
        } else if ([d compare:[self.semesterEndDates objectAtIndex:2]] != NSOrderedDescending) {
            [array addObject:[NSNumber numberWithInt:TERM_FULL_YEAR]];
            [array addObject:[NSNumber numberWithInt:TERM_SECOND_SEMESTER]];
        }
    }
    if ([d compare:[self.trimesterEndDates objectAtIndex:0]] != NSOrderedAscending) {
        if ([d compare:[self.trimesterEndDates objectAtIndex:1]] != NSOrderedDescending)
            [array addObject:[NSNumber numberWithInt:TERM_FIRST_TRIMESTER]];
        else if ([d compare:[self.trimesterEndDates objectAtIndex:2]] != NSOrderedDescending)
            [array addObject:[NSNumber numberWithInt:TERM_SECOND_TRIMESTER]];
        else if ([d compare:[self.trimesterEndDates objectAtIndex:1]] != NSOrderedDescending)
            [array addObject:[NSNumber numberWithInt:TERM_THIRD_TRIMESTER]];
    }
    return [NSArray arrayWithArray:array];
}

#pragma mark -
#pragma mark *********************NOTES STUFF*********************



#pragma mark -
#pragma mark ********************SAVING STUFF*********************

- (void)saveWeekWithDate:(IHWDate *)d {
#pragma mark TODO save week
}

- (void)saveCourses {
    NSString *campusChar = getCampusChar(self.campus);
    NSMutableDictionary *yearDict = [NSMutableDictionary dictionary];
    [yearDict setObject:[NSNumber numberWithInt:self.year] forKey:@"year"];
    [yearDict setObject:[NSNumber numberWithInt:self.campus] forKey:@"campus"];
    NSMutableArray *courseDicts = [NSMutableArray array];
    for (IHWCourse *c in self.courses) [courseDicts addObject:[c saveCourse]];
    [yearDict setObject:courseDicts forKey:@"courses"];
    NSError *error = nil;
    NSData *yearJSON = [[CJSONSerializer serializer] serializeDictionary:yearDict error:&error];
    if (error != nil) { NSLog(@"ERROR serializing courses: %@", error.debugDescription); return; }
    [IHWFileManager saveYearJSON:yearJSON forYear:self.year campus:campusChar];
}

@end
