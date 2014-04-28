//
//  IHWLogic.h
//  iHW
//
//  Created by Jonathan Burns on 7/10/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "MutableOrderedDictionary.h"
#import "IHWDate.h"
#import "IHWTime.h"
#import "IHWDay.h"
#import "IHWCourse.h"
#import "IHWConstants.h"

@interface IHWCurriculum : NSObject

//Curriculum is a Singleton object
+ (IHWCurriculum *)currentCurriculum;
+ (IHWCurriculum *)reloadCurrentCurriculum;
+ (IHWCurriculum *)curriculumWithCampus:(int)campus andYear:(int)year;

+ (int)currentYear;
+ (int)currentCampus;
+ (void)setCurrentYear:(int)year;
+ (void)setCurrentCampus:(int)campus;
+ (BOOL)isFirstRun;

@property int campus;
@property int year;
@property int passingPeriodLength;
@property int loadingProgress;
@property (strong, nonatomic) NSMutableArray *courses;
@property (strong, nonatomic) IHWTime *dayStartTime;
@property (strong, nonatomic) NSDictionary *normalDayTemplate;
@property (strong, nonatomic) NSDictionary *normalMondayTemplate;
@property (strong, nonatomic) NSDictionary *specialDayTemplates;
@property (strong, nonatomic) NSDictionary *dayCaptions;
@property (strong) NSMutableDictionary *loadedWeeks; //Keys: IHWDate / Values: NSDictionary
@property (strong) NSMutableDictionary *loadedDays;  //Keys: IHWDate / Values: IHWDay
@property (strong, nonatomic) NSMutableDictionary *dayNumbers; //Keys: IHWDate / Values: NSNumber
@property (strong, nonatomic) NSArray *semesterEndDates; //Values: IHWDate
@property (strong, nonatomic) NSArray *trimesterEndDates; //Values: IHWDate
@property (strong) NSMutableSet *curriculumLoadingListeners; //Values: IHWCurriculumLoadingListener
@property (strong, nonatomic) NSOperationQueue *loadingQueue;

- (void)loadEverythingWithStartingDate:(IHWDate *)date;
- (BOOL)isLoading;
- (BOOL)isLoaded;
//- (IHWDate *)firstLoadedDate;
//- (IHWDate *)lastLoadedDate;
- (BOOL)dayIsLoaded:(IHWDate *)date;
- (IHWDay *)dayWithDate:(IHWDate *)date;
- (BOOL)dateInBounds:(IHWDate *)date;

- (NSArray *)allCourseNames;
- (BOOL)addCourse:(IHWCourse *)c;
- (void)removeCourse:(IHWCourse *)c;
- (void)removeAllCourses;
//- (BOOL)replaceCourseWithName:(NSString *)oldName withCourse:(IHWCourse *)c;
//- (IHWCourse *)courseWithName:(NSString *)name;
- (BOOL)replaceCourseAtIndex:(NSInteger)index withCourse:(IHWCourse *)c;
- (IHWCourse *)courseAtIndex:(NSInteger)index;
- (IHWCourse *)courseMeetingOnDate:(IHWDate *)d period:(int)period;
- (NSArray *)courseListForDate:(IHWDate *)d;
- (NSArray *)termsFromDate:(IHWDate *)d;

- (void)constructNotifications;

- (NSArray *)notesOnDate:(IHWDate *)date period:(int)period;
- (void)setNotes:(NSArray *)notes onDate:(IHWDate *)date period:(int)period;

- (void)saveWeekWithDate:(IHWDate *)d;
- (void)saveCourses;

@end

//Any class can implement this protocol to get notified when the IHWCurriculum finishes loading or fails to load
@protocol IHWCurriculumLoadingListener <NSObject>
@optional
- (void)curriculumFinishedLoading:(IHWCurriculum *)curriculum;
- (void)curriculumFailedToLoad:(IHWCurriculum *)curriculum;
@end
