//
//  IHWLogic.m
//  iHW
//
//  Created by Jonathan Burns on 7/10/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import "IHWCurriculum.h"
#import "IHWAppDelegate.h"
#import "CJSONSerializer.h"
#import "CJSONDeserializer.h"
#import "IHWFileManager.h"
#import "IHWHoliday.h"
#import "IHWNormalDay.h"
#import "IHWCustomDay.h"
#import "IHWUtils.h"
#import "IHWNote.h"
#import "IHWPeriod.h"

static NSString *curriculumDirectory = @"http://www.ihwapp.com/curriculum/";
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

+ (IHWCurriculum *)reloadCurrentCurriculum {
    currentCurriculum = nil;
    return [IHWCurriculum currentCurriculum];
}

+ (IHWCurriculum *)curriculumWithCampus:(int)campus andYear:(int)year {
    if (currentCurriculum == nil || currentCurriculum.campus != campus || currentCurriculum.year != year) {
        [self setCurrentCampus:campus];
        [self setCurrentYear:year];
        //NSLog(@"Creating current curriculum: %@", [IHWDate today]);
        currentCurriculum = [[IHWCurriculum alloc] initWithCampus:campus year:year startingDate:[IHWDate today]];
    } else {
        if (!currentCurriculum.isLoaded && !currentCurriculum.isLoading) [currentCurriculum loadEverythingWithStartingDate:[IHWDate today]];
    }
    return currentCurriculum;
}

+ (int)currentYear {
    return (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"currentYear"];
}

+ (int)currentCampus {
    return (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"currentCampus"];
}

+ (void)setCurrentYear:(int)year {
    [[NSUserDefaults standardUserDefaults] setInteger:year forKey:@"currentYear"];
    [[NSUserDefaults standardUserDefaults] setInteger:[[IHWDate today] dateByAddingDays:-365/2].year forKey:@"manualYear"];
}

+ (void)updateCurrentYear {
    [[NSUserDefaults standardUserDefaults] setInteger:[[IHWDate today] dateByAddingDays:-365/2].year forKey:@"currentYear"];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"manualYear"];
}

+ (BOOL)yearSetManually {
    return ([[NSUserDefaults standardUserDefaults] integerForKey:@"manualYear"] == [[IHWDate today] dateByAddingDays:-365/2].year);
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
        if ([date compare:earliest] == NSOrderedAscending) {
            //Starting date is earlier than this year's begin date
            date = earliest;
        } else if ([date compare:latest] == NSOrderedDescending) {
            //Starting date is later than this year's end date
            date = latest;
        }
        [self loadEverythingWithStartingDate:date];
    }
    return self;
}

- (void)loadEverythingWithStartingDate:(IHWDate *)date {
    //NSLog(@">loading everything");
    if (self.loadingProgress >= 0) return;
    self.loadingProgress = 0;
    self.loadingQueue = [[NSOperationQueue alloc] init];
    
    //Download and parse schedule JSON
    NSBlockOperation *loadSchedule = [NSBlockOperation blockOperationWithBlock:^{
        if (![self downloadParseScheduleJSON]) [self performSelectorOnMainThread:@selector(loadingFailed) withObject:nil waitUntilDone:NO];
    }];
    //Load user's courses
    NSBlockOperation *loadCourses = [NSBlockOperation blockOperationWithBlock:^{
        if (![self loadCourses]) [self performSelectorOnMainThread:@selector(loadingFailed) withObject:nil waitUntilDone:NO];
    }];
    //Calculate day numbers for the entire year
    NSBlockOperation *loadDayNumbers = [NSBlockOperation blockOperationWithBlock:^{
        if (![self loadDayNumbers]) [self performSelectorOnMainThread:@selector(loadingFailed) withObject:nil waitUntilDone:NO];
    }];
    //Load the notes for the current week and periods for the current day
    NSBlockOperation *loadWeekAndDay = [NSBlockOperation blockOperationWithBlock:^{
        if (![self loadWeekAndDay:date]) [self performSelectorOnMainThread:@selector(loadingFailed) withObject:nil waitUntilDone:NO];
    }];
    NSBlockOperation *constructNotifications = [NSBlockOperation blockOperationWithBlock:^{
        [self constructNotifications];
    }];
    
    //Need schedule before computing day numbers
    [loadDayNumbers addDependency:loadSchedule];
    //Need everything else before loading the current week and day
    [loadWeekAndDay addDependency:loadSchedule];
    [loadWeekAndDay addDependency:loadDayNumbers];
    [loadWeekAndDay addDependency:loadCourses];
    [constructNotifications addDependency:loadWeekAndDay];
    
    //Add all operations to queue
    [self.loadingQueue addOperation:loadSchedule];
    [self.loadingQueue addOperation:loadCourses];
    [self.loadingQueue addOperation:loadDayNumbers];
    [self.loadingQueue addOperation:loadWeekAndDay];
    [self.loadingQueue addOperation:constructNotifications];
    [self.loadingQueue addObserver:self forKeyPath:@"operationCount" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)loadingFailed {
    [self.loadingQueue setSuspended:YES];
    self.loadingProgress = -1;
    __block NSMutableSet *toSendSelector = [NSMutableSet set];
    for (NSObject<IHWCurriculumLoadingListener> *mll in self.curriculumLoadingListeners) {
        if ([mll respondsToSelector:@selector(curriculumFailedToLoad:)])
            [toSendSelector addObject:mll];
    }
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [toSendSelector makeObjectsPerformSelector:@selector(curriculumFailedToLoad:) withObject:self];
    }];
}

- (BOOL)isLoading {
    return (self.loadingProgress == 0);
}

- (BOOL)isLoaded {
    return (self.loadingProgress == 1);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"operationCount"] && object == self.loadingQueue) {
        //NSLog(@"loading queue changed count: %d", self.loadingQueue.operationCount);
        if (self.loadingQueue.operationCount == 0) {
            //Finished loading everything
            [self.loadingQueue removeObserver:self forKeyPath:@"operationCount"];
            self.loadingQueue = nil;
            self.loadingProgress = 1;
            __block NSMutableArray *toSendSelector = [NSMutableArray array];
            for (NSObject<IHWCurriculumLoadingListener> *mll in self.curriculumLoadingListeners) {
                if ([mll respondsToSelector:@selector(curriculumFinishedLoading:)]) {
                    [toSendSelector addObject:mll];
                }
            }
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [toSendSelector makeObjectsPerformSelector:@selector(curriculumFinishedLoading:) withObject:self];
            }];
        }
    }
}

- (BOOL)dayIsLoaded:(IHWDate *)date {
    if (self.loadedDays == nil || self.loadedWeeks == nil) return NO;
    if ([NSThread isMainThread]) {
        return ([self.loadedDays objectForKey:date] != nil
            && [self.loadedWeeks objectForKey:getWeekStart(self.year, date)] != nil);
    } else {
        __block BOOL result;
        NSOperation *oper = [NSBlockOperation blockOperationWithBlock:^{
            result = ([self.loadedDays objectForKey:date] != nil
                      && [self.loadedWeeks objectForKey:getWeekStart(self.year, date)] != nil);
        }];
        [[NSOperationQueue mainQueue] addOperation:oper];
        //If we're not on the main thread we can afford to wait until they're loaded
        [oper waitUntilFinished];
        return result;
    }
}

//THIS METHOD BLOCKS UNTIL THE SCHEDULE JSON IS LOADED
- (BOOL)downloadParseScheduleJSON {
    //NSLog(@">downloading schedule JSON");
    NSError *error = nil;
    NSURLResponse *response = nil;
    NSString *urlStr = [NSString stringWithFormat:@"%@%d%@.hws", curriculumDirectory, self.year, getCampusChar(self.campus)];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    [(IHWAppDelegate *)[UIApplication sharedApplication].delegate performSelectorOnMainThread:@selector(showNetworkIcon) withObject:nil waitUntilDone:NO];
    NSData *scheduleJSON = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    [(IHWAppDelegate *)[UIApplication sharedApplication].delegate performSelectorOnMainThread:@selector(hideNetworkIcon) withObject:nil waitUntilDone:NO];
    //NSData *scheduleJSON = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr] options:0 error:&error];
    NSString *campusChar = getCampusChar(self.campus);
    if (error != nil) {
        //If we can't download it, load a cached version
        NSLog(@"ERROR downloading schedule JSON: %@", error.debugDescription);
        scheduleJSON = [IHWFileManager loadScheduleJSONForYear:self.year campus:campusChar];
    } else {
        //Cache the JSON we just downloaded
        [IHWFileManager saveScheduleJSON:scheduleJSON forYear:self.year campus:campusChar];
    }
    if (scheduleJSON == nil) {
        //Couldn't download; no cached version
        return NO;
    } else {
        //Downloaded. Next step: parsing.
        [self parseScheduleJSON:scheduleJSON];
    }
    return YES;
}

- (BOOL)parseScheduleJSON:(NSData *)scheduleJSON {
    //NSLog(@">parsing schedule JSON");
    NSError *error = nil;
    NSDictionary *scheduleDict = [[CJSONDeserializer deserializer] deserializeAsDictionary:scheduleJSON error:&error];
    if (error != nil) { NSLog(@"ERROR parsing schedule JSON: %@", error.debugDescription); return NO; }
    //Load all the general parameters into the curriculum
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
    if ([scheduleDict objectForKey:@"dayStartTime"] != nil)
        self.dayStartTime = [[IHWTime alloc] initFromString:[scheduleDict objectForKey:@"dayStartTime"]];
    else self.dayStartTime = [[IHWTime alloc] initWithHour:8 andMinute:0];
    self.normalDayTemplate = [scheduleDict objectForKey:@"normalDay"];
    self.normalMondayTemplate = [scheduleDict objectForKey:@"normalMonday"];
    self.passingPeriodLength = [[scheduleDict objectForKey:@"passingPeriodLength"] intValue];
    
    //Load special days into curriculum
    NSMutableDictionary *specialDays = [[NSMutableDictionary alloc] init];
    NSDictionary *specialDaysJSON = [scheduleDict objectForKey:@"specialDays"];
    for (NSString *dateStr in [specialDaysJSON allKeys]) {
        [specialDays setObject:[specialDaysJSON objectForKey:dateStr] forKey:[[IHWDate alloc] initFromString:dateStr]];
    }
    self.specialDayTemplates = [NSDictionary dictionaryWithDictionary:specialDays];
    
    //Load day captions into curriculum
    NSMutableDictionary *captions = [[NSMutableDictionary alloc] init];
    NSDictionary *captionsJSON = [scheduleDict objectForKey:@"dayCaptions"];
    for (NSString *dateStr in [captionsJSON allKeys]) {
        [captions setObject:[captionsJSON objectForKey:dateStr] forKey:[[IHWDate alloc] initFromString:dateStr]];
    }
    self.dayCaptions = [NSDictionary dictionaryWithDictionary:captions];
    return YES;
}

- (BOOL)loadCourses {
    //NSLog(@">loading courses");
    NSMutableArray *courseArray = [NSMutableArray array];
    NSError *error = nil;
    NSData *json = [IHWFileManager loadYearJSONForYear:self.year campus:getCampusChar(self.campus)];
    if (json == nil || [json isEqualToData:[NSData data]]) json = generateBlankYearJSON(self.campus, self.year);
    NSDictionary *fromJSON = [[CJSONDeserializer deserializer] deserializeAsDictionary:json error:&error];
    NSArray *coursesJSON = [fromJSON objectForKey:@"courses"];
    if (error != nil) { NSLog(@"ERROR loading courses: %@", error.debugDescription); return NO; }
    for (NSDictionary *dict in coursesJSON) {
        IHWCourse *course = [[IHWCourse alloc] initWithJSONDictionary:dict];
        [courseArray addObject:course];
    }
    self.courses = courseArray;
    return YES;
}

- (BOOL)loadDayNumbers {
    //NSLog(@">loading day numbers");
    if (self.specialDayTemplates == nil || self.semesterEndDates == nil) return NO;
    NSMutableDictionary *dayNums = [[NSMutableDictionary alloc] init];
    //Start at the beginning of the first semester
    IHWDate *d = [self.semesterEndDates objectAtIndex:0];
    int dayNum = 1;
    while ([d compare:[self.semesterEndDates objectAtIndex:2]] != NSOrderedDescending) {
        //Loop over all days until the end of the second semester
        if ([self.specialDayTemplates objectForKey:d] != nil) {
            if ([[[self.specialDayTemplates objectForKey:d] objectForKey:@"type"] isEqualToString:@"normal"]) {
                //If special day listed as "normal," try to get its day number from the special day templates
                int thisNum = [[[self.specialDayTemplates objectForKey:d] objectForKey:@"dayNumber"] intValue];
                //Increment the counter starting at this day
                if (thisNum != 0) dayNum = thisNum+1;
                [dayNums setObject:[NSNumber numberWithInt:thisNum] forKey:d];
            } else {
                //Day is a special day without a day number
                [dayNums setObject:[NSNumber numberWithInt:0] forKey:d];
            }
        } else if (![d isWeekend]) {
            //normal days: use the counter and increment it
            [dayNums setObject:[NSNumber numberWithInt:dayNum] forKey:d];
            dayNum++;
        }
        //Reset the counter at the end of the cycle
        if (dayNum > self.campus) dayNum -= self.campus;
        //Increment the date
        d = [d dateByAddingDays:1];
    }
    self.dayNumbers = dayNums;
    return YES;
}

- (BOOL)loadWeekAndDay:(IHWDate *)date {
    if ([date compare:[[IHWDate alloc] initWithMonth:7 day:1 year:self.year]] == NSOrderedAscending) {
        //You can't load days before July 1 of the fall year!
        date = [[IHWDate alloc] initWithMonth:7 day:1 year:self.year];
    } else if ([date compare:[[IHWDate alloc] initWithMonth:7 day:1 year:self.year+1]] != NSOrderedAscending) {
        //You can't load days on or after July 1 of the spring year!
        date = [[[IHWDate alloc] initWithMonth:7 day:1 year:self.year+1] dateByAddingDays:-1];
    }
    BOOL success = [self loadWeek:date];
    if (!success) { NSLog(@"ERROR loading week: %@", date.description); return NO; }
    success = [self loadDay:date];
    if (!success) { NSLog(@"ERROR loading day: %@", date.description); return NO; }
    return YES;
}

- (BOOL)loadWeek:(IHWDate *)date {
    int weekNumber = getWeekNumber(self.year, date);
    IHWDate *weekStart = getWeekStart(self.year, date);
    //NSLog(@">loading week: %@", weekStart.description);
    //If we have already loaded the week, do nothing
    if (self.loadedWeeks != nil && [self.loadedWeeks objectForKey:weekStart] != nil) return YES;
    //If week is out of bounds
    if (weekNumber == -1) return NO;
    
    NSData *weekJSON = [IHWFileManager loadWeekJSONForWeekNumber:weekNumber year:self.year campus:getCampusChar(self.campus)];
    //NOTE: If the above line fails, it will print a scary-looking error. This is normal (and actually very common). It's taken care of below:
    if (weekJSON == nil) weekJSON = generateBlankWeekJSON(weekStart);
    NSError *error = nil;
    NSDictionary *weekDict = [[CJSONDeserializer deserializer] deserializeAsDictionary:weekJSON error:&error];
    if (error == nil) {
        if (self.loadedWeeks == nil) self.loadedWeeks = [NSMutableDictionary dictionary];
        //[self.loadedWeeks insertObject:weekDict forKey:weekStart sortedUsingComparator:[IHWDate comparator]];
        //Add the loaded week to the loadedWeeks dictionary
        [self.loadedWeeks setObject:weekDict forKey:weekStart];
    }
    else NSLog(@"ERROR loading week: %@", error.debugDescription);
    return error == nil;
}

- (BOOL)loadDay:(IHWDate *)date {
    //NSLog(@">loading day: %@", date);
    if (![self dateInBounds:date]) return NO;
    if (self.loadedDays == nil) self.loadedDays = [NSMutableDictionary dictionary];
    //First see if we have a template from the special days dictionary
    NSDictionary *template = [self.specialDayTemplates objectForKey:date];
    if (template == nil) {
        //Otherwise construct one based on when the date is
        if ([date compare:[self.semesterEndDates objectAtIndex:0]] == NSOrderedAscending
            || [date compare:[self.semesterEndDates objectAtIndex:2]] == NSOrderedDescending) {
            //If the date is during Summer, create a holiday with title "Summer".
            //[self.loadedDays insertObject:[[IHWHoliday alloc] initWithName:@"Summer" onDate:date] forKey:date sortedUsingComparator:[IHWDate comparator]];
            IHWHoliday *holiday = [[IHWHoliday alloc] initWithName:@"Summer" onDate:date];
            [self performSelectorOnMainThread:@selector(addLoadedDay:) withObject:holiday waitUntilDone:YES];
            
            //Add caption if necessary
            NSDictionary *captionDict = [self.dayCaptions objectForKey:date];
            if (captionDict != nil && holiday.caption == nil) {
                holiday.caption = [captionDict objectForKey:@"text"];
                if ([captionDict objectForKey:@"link"] != nil) {
                    holiday.captionLink = [captionDict objectForKey:@"link"];
                }
            }
            return YES;
        } else if (date.isWeekend) {
            //Weekends get a blank holiday
            //[self.loadedDays insertObject:[[IHWHoliday alloc] initWithName:@"" onDate:date] forKey:date sortedUsingComparator:[IHWDate comparator]];
            IHWHoliday *holiday = [[IHWHoliday alloc] initWithName:@"" onDate:date];
            [self performSelectorOnMainThread:@selector(addLoadedDay:) withObject:holiday waitUntilDone:YES];
            
            //Add caption if necessary
            NSDictionary *captionDict = [self.dayCaptions objectForKey:date];
            if (captionDict != nil && holiday.caption == nil) {
                holiday.caption = [captionDict objectForKey:@"text"];
                if ([captionDict objectForKey:@"link"] != nil) {
                    holiday.captionLink = [captionDict objectForKey:@"link"];
                }
            }
            return YES;
        }
    }
    //If we still haven't found a template yet, keep going...
    if (template==nil && date.isMonday) {
        //Regular monday
        NSMutableDictionary *dict = [self.normalMondayTemplate mutableCopy];
        [dict setObject:date.description forKey:@"date"];
        [dict setObject:[self.dayNumbers objectForKey:date] forKey:@"dayNumber"];
        template = dict;
    } else if (template==nil) {
        //Regular day
        NSMutableDictionary *dict = [self.normalDayTemplate mutableCopy];
        [dict setObject:date.description forKey:@"date"];
        [dict setObject:[self.dayNumbers objectForKey:date] forKey:@"dayNumber"];
        template = dict;
    }
    NSString *type = [template objectForKey:@"type"];
    //NSLog(@"Type: %@", type);
    IHWDay *day;
    //Create the day from the template based on its type
    if ([type isEqualToString:@"normal"]) {
        day = [[IHWNormalDay alloc] initWithJSONDictionary:template];
        [(IHWNormalDay *)day fillPeriodsFromCurriculum:self];
    } else if ([type isEqualToString:@"test"]) {
        day = [[IHWCustomDay alloc] initWithJSONDictionary:template];
    } else if ([type isEqualToString:@"holiday"]) {
        day = [[IHWHoliday alloc] initWithJSONDictionary:template];
    } else return NO;
    
    //Add caption if necessary
    NSDictionary *captionDict = [self.dayCaptions objectForKey:date];
    if (captionDict != nil && day.caption == nil) {
        day.caption = [captionDict objectForKey:@"text"];
        if ([captionDict objectForKey:@"link"] != nil) {
            day.captionLink = [captionDict objectForKey:@"link"];
        }
    }
    //[self.loadedDays insertObject:day forKey:date sortedUsingComparator:[IHWDate comparator]];
    [self performSelectorOnMainThread:@selector(addLoadedDay:) withObject:day waitUntilDone:YES];
    return YES;
}

- (void)addLoadedDay:(IHWDay *)day {
    [self.loadedDays setObject:day forKey:day.date];
}

- (IHWDay *)dayWithDate:(IHWDate *)date {
    //NSLog(@"Getting day with date %@", date.description);
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
    NSMutableArray *weeksNeeded = [NSMutableArray array];
    //Only keep this week, next week, and last week
    [weeksNeeded addObject:getWeekStart(self.year, [weekStart dateByAddingDays:-1])];
    [weeksNeeded addObject:weekStart];
    [weeksNeeded addObject:getWeekStart(self.year, [weekStart dateByAddingDays:7])];
    if (self.loadedWeeks != nil)
        self.loadedWeeks = [[self.loadedWeeks dictionaryWithValuesForKeys:weeksNeeded] mutableCopy];
    NSMutableArray *daysNeeded = [NSMutableArray array];
    //Only keep three days in either direction
    for (int i=-3; i<=3; i++) [daysNeeded addObject:[date dateByAddingDays:i]];
    if (self.loadedDays != nil)
        self.loadedDays = [[self.loadedDays dictionaryWithValuesForKeys:daysNeeded] mutableCopy];
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
        //Make sure no courses conflict with the new course
        if (!termsCompatible(check.term, c.term)) {
            //There could be a problem if the terms overlap
            if (check.period == c.period) {
                //There could be a problem if the periods are the same
                for (int i=1; i<=self.campus; i++) {
                    //There's a problem if the two courses meet on the same day
                    if ([c meetingOn:i] != MEETING_X_DAY && [check meetingOn:i] != MEETING_X_DAY) return NO;
                }
            } else {
                //Check for double periods
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
                    //Double periods could be a problem when the courses are in consecutive periods
                    for (int i=1; i<=self.campus; i++) {
                        if ([earlier meetingOn:i] == MEETING_DOUBLE_AFTER && [later meetingOn:i] != MEETING_X_DAY) return NO;
                        if ([later meetingOn:i] == MEETING_DOUBLE_BEFORE && [earlier meetingOn:i] != MEETING_X_DAY) return NO;
                    }
                } else if (ABS(c.period-check.period) == 2) {
                    //Double periods could also be a problem when the courses are two periods apart
                    for (int i=1; i<=self.campus; i++) {
                        if ([earlier meetingOn:i] == MEETING_DOUBLE_AFTER && [later meetingOn:i] == MEETING_DOUBLE_BEFORE) return NO;
                    }
                }
            }
        }
    }
    //No problems found
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

//Unnecessary methods

/*
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
}*/

- (BOOL)replaceCourseAtIndex:(NSInteger)index withCourse:(IHWCourse *)c {
    IHWCourse *oldCourse = [self courseAtIndex:index];
    [self removeCourse:oldCourse];
    if ([self addCourse:c]) return YES;
    else {
        [self addCourse:oldCourse];
        return NO;
    }
}

- (IHWCourse *)courseAtIndex:(NSInteger)index {
    return [self.courses objectAtIndex:index];
}

- (IHWCourse *)courseMeetingOnDate:(IHWDate *)d period:(int)period {
    if ([d compare:[self.semesterEndDates objectAtIndex:0]] == NSOrderedAscending
        || [d compare:[self.semesterEndDates objectAtIndex:2]] == NSOrderedDescending) return nil;
    int dayNum = [[self.dayNumbers objectForKey:d] intValue];
    NSArray *terms = [self termsFromDate:d];
    if (dayNum == 0) {
        //For "No X Periods" days, choose the course that meets the most
        IHWCourse *maxMeetings = nil;
        int max = 1;
        //If the course only meets once per cycle, it doesn't meet on "No X Periods" days
        for (IHWCourse *c in self.courses) {
            BOOL termFound = NO;
            for (NSNumber *term in terms) if ([term intValue] == c.term) {
                //Course meets during the current term
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
    //Normal numbered days
    for (IHWCourse *c in self.courses) {
        BOOL termFound = NO;
        for (NSNumber *term in terms) if ([term intValue] == c.term) {
            //course meets during the current term
            termFound = YES;
            break;
        }
        if (!termFound) continue;
        if (c.period == period) {
            //As long as the course doesn't X, it meets (obviously)
            if ([c meetingOn:dayNum] != MEETING_X_DAY) return c;
        } else if (period == c.period-1) {
            //The course doubles up into this period
            if ([c meetingOn:dayNum] == MEETING_DOUBLE_BEFORE) return c;
        } else if (period == c.period+1) {
            //The course doubles down into this period
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
    //Must find course that meets the most
    NSMutableArray *maxMeetings = [NSMutableArray arrayWithCapacity:self.campus+4];
    for (int i=0; i<self.campus+4; i++) {
        [courseList setObject:[NSNull null] atIndexedSubscript:i];
        //[NSNull null] represents an "X" period
        [maxMeetings setObject:[NSNumber numberWithInt:1] atIndexedSubscript:i];
    }
    for (IHWCourse *c in self.courses) {
        //For each course, add it to the courselist at its period index
        if (![terms containsObject:[NSNumber numberWithInt:c.term]]) continue;
        if (dayNum == 0) { //"No X Periods" day
            int meetings = c.totalMeetings;
            if (meetings > [[maxMeetings objectAtIndex:c.period] intValue]) {
                [courseList setObject:c atIndexedSubscript:c.period];
                [maxMeetings setObject:[NSNumber numberWithInt:meetings] atIndexedSubscript:c.period];
            }
        } else if ([c meetingOn:dayNum] != MEETING_X_DAY) {
            [courseList setObject:c atIndexedSubscript:c.period];
            //And if it's a double period, add it for those period indices also
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
        //After the beginning of first semester
        if ([d compare:[self.semesterEndDates objectAtIndex:1]] != NSOrderedDescending) {
            //Before the end of first semester
            [array addObject:[NSNumber numberWithInt:TERM_FULL_YEAR]];
            [array addObject:[NSNumber numberWithInt:TERM_FIRST_SEMESTER]];
        } else if ([d compare:[self.semesterEndDates objectAtIndex:2]] != NSOrderedDescending) {
            //After the end of first semester, before the end of second semester
            [array addObject:[NSNumber numberWithInt:TERM_FULL_YEAR]];
            [array addObject:[NSNumber numberWithInt:TERM_SECOND_SEMESTER]];
        }
    }
    if ([d compare:[self.trimesterEndDates objectAtIndex:0]] != NSOrderedAscending) {
        //After the beginning of first trimester
        if ([d compare:[self.trimesterEndDates objectAtIndex:1]] != NSOrderedDescending)
            //Before the end of first trimester
            [array addObject:[NSNumber numberWithInt:TERM_FIRST_TRIMESTER]];
        else if ([d compare:[self.trimesterEndDates objectAtIndex:2]] != NSOrderedDescending)
            //After the end of first trimester, before the end of second trimester
            [array addObject:[NSNumber numberWithInt:TERM_SECOND_TRIMESTER]];
        else if ([d compare:[self.trimesterEndDates objectAtIndex:1]] != NSOrderedDescending)
            //After the end of second trimester, before the end of third trimester
            [array addObject:[NSNumber numberWithInt:TERM_THIRD_TRIMESTER]];
    }
    return [NSArray arrayWithArray:array];
}

- (void)constructNotifications {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"allNotifications"]) {
        //User hasn't enabled notifications
        NSLog(@"Deleting notifications");
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        return;
    }
    NSLog(@"Constructing notifications");
    NSMutableArray *notifications = [NSMutableArray array];
    //Only add notifications for the next 7 days
    IHWDate *startDate = [IHWDate today];
    IHWDate *endDate = [startDate dateByAddingDays:7];
    BOOL isToday = true;
    for (IHWDate *d = startDate; [d compare:endDate] == NSOrderedAscending; d = [d dateByAddingDays:1]) {
        //For each day...
        IHWDay *day = [[IHWCurriculum currentCurriculum] dayWithDate:d];
        if (![day isKindOfClass:[IHWNormalDay class]]) {
            //No notifications on holidays or custom days
            isToday = false;
            continue;
        }
        for (int i=0; i<day.periods.count; i++) {
            //For each period...
            IHWPeriod *thisPeriod = ((IHWPeriod *)[day.periods objectAtIndex:i]);
            if (thisPeriod.isFreePeriod &&
                (!isToday || [thisPeriod.endTime secondsUntilTime:[IHWTime now]] < 0)) {
                //If period is a free period and ends sometime in the future...
                if (i < day.periods.count-1 &&
                    !((IHWPeriod *)[day.periods objectAtIndex:i+1]).isFreePeriod) {
                    //...and next period is not a free period...
                    //add the notification.
                    UILocalNotification *n = [[UILocalNotification alloc] init];
                    n.alertBody = [NSString stringWithFormat:@"%@ starts in %d minutes",((IHWPeriod *)[day.periods objectAtIndex:i+1]).name, [IHWCurriculum currentCurriculum].passingPeriodLength];
                    n.soundName = UILocalNotificationDefaultSoundName;
                    n.fireDate = [d NSDateWithTime:thisPeriod.endTime];
                    [notifications addObject:n];
                }
            }
        }
        isToday = false;
    }
    NSLog(@"Notifications: %@", notifications);
    //Schedule the notifications
    [UIApplication sharedApplication].scheduledLocalNotifications = notifications;
}

#pragma mark -
#pragma mark *********************NOTES STUFF*********************

- (NSArray *)notesOnDate:(IHWDate *)date period:(int)period {
    IHWDate *weekStart = getWeekStart(self.year, date);
    //Load week
    BOOL success = true;
    if ([self.loadedWeeks objectForKey:weekStart] == nil) success = [self loadWeek:date];
    if (!success) { NSLog(@"ERROR loading week"); return nil; }
    else {
        NSString *key = [NSString stringWithFormat:@"%@.%d", date.description, period];
        NSDictionary *weekJSON = [self.loadedWeeks objectForKey:weekStart];
        NSArray *notesArr = [[weekJSON objectForKey:@"notes"] objectForKey:key];
        if (notesArr != nil) {
            //Create an array of IHWNote objects from the notes JSON dictionaries
            NSMutableArray *notes = [NSMutableArray array];
            for (int i=0; i<notesArr.count; i++) {
                [notes addObject:[[IHWNote alloc] initWithJSONDictionary:[notesArr objectAtIndex:i]]];
            }
            return [NSArray arrayWithArray:notes];
        } else {
            return [NSArray array];
        }
    }
}

- (void)setNotes:(NSArray *)notes onDate:(IHWDate *)date period:(int)period {
    IHWDate *weekStart = getWeekStart(self.year, date);
    //Make sure day and week are loaded
    if (![self dayIsLoaded:date]) {
        BOOL success = true;
        if ([self.loadedWeeks objectForKey:weekStart] == nil) success = [self loadWeek:date];
        if (!success) NSLog(@"ERROR loading week");
        if ([self.loadedDays objectForKey:date] == nil) success = [self loadDay:date];
        if (!success) NSLog(@"ERROR loading day");
    }
    //Make sure day and week are loaded (again)
    if ([self dayIsLoaded:date]) {
        NSString *key = [NSString stringWithFormat:@"%@.%d", date.description, period];
        //Make a copy of everything
        NSMutableDictionary *weekJSON = [[self.loadedWeeks objectForKey:weekStart] mutableCopy];
        NSMutableDictionary *notesDict = [[weekJSON objectForKey:@"notes"] mutableCopy];
        //Create an array of JSON dictionaries from the IHWNotes
        NSMutableArray *notesArr = [NSMutableArray array];
        for (IHWNote *note in notes) {
            [notesArr addObject:[note saveNote]];
        }
        //Set the notes
        [notesDict setObject:notesArr forKey:key];
        [weekJSON setObject:notesDict forKey:@"notes"];
        [self.loadedWeeks setObject:weekJSON forKey:weekStart];
    }
}

#pragma mark -
#pragma mark ********************SAVING STUFF*********************

- (void)saveWeekWithDate:(IHWDate *)date {
    //NSLog(@"Saving week");
    IHWDate *weekStart = getWeekStart(self.year, date);
    NSDictionary *weekObj = [self.loadedWeeks objectForKey:weekStart];
    int weekNumber = getWeekNumber(self.year, weekStart);
    NSError *error = nil;
    //Serialize the week to JSON data
    NSData *data = [[CJSONSerializer serializer] serializeDictionary:weekObj error:&error];
    if (error != nil) { NSLog(@"ERROR saving week JSON"); return; }
    //Save the JSON data
    [IHWFileManager saveWeekJSON:data forWeekNumber:weekNumber year:self.year campus:getCampusChar(self.campus)];
}

- (void)saveCourses {
    NSString *campusChar = getCampusChar(self.campus);
    NSMutableDictionary *yearDict = [NSMutableDictionary dictionary];
    [yearDict setObject:[NSNumber numberWithInt:self.year] forKey:@"year"];
    [yearDict setObject:[NSNumber numberWithInt:self.campus] forKey:@"campus"];
    NSMutableArray *courseDicts = [NSMutableArray array];
    //Convert each course to a JSON dictionary and add it
    for (IHWCourse *c in self.courses) {
        [courseDicts addObject:[c saveCourse]];
    }
    [yearDict setObject:courseDicts forKey:@"courses"];
    //Serialize the year to JSON data
    NSError *error = nil;
    NSData *yearJSON = [[CJSONSerializer serializer] serializeDictionary:yearDict error:&error];
    if (error != nil) { NSLog(@"ERROR serializing courses: %@", error.debugDescription); return; }
    //Save the JSON data
    [IHWFileManager saveYearJSON:yearJSON forYear:self.year campus:campusChar];
}

@end
