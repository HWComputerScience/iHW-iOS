//
//  IHWNormalDay.h
//  iHW
//
//  Created by Andrew Friedman on 7/10/13.
//  Copyright (c) 2013 Andrew Friedman. All rights reserved.
//

#import "IHWDay.h"
#import "IHWCurriculum.h"

@interface IHWNormalDay : IHWDay

@property int dayNum;
@property BOOL hasBreak;
@property int numPeriods;
@property int periodsBeforeBreak;
@property int periodsAfterBreak;
@property int periodLength;
@property int breakLength;
@property (strong, nonatomic) NSString *breakName;

- (id)initWithBreak:(NSString *)breakName OnDate:(IHWDate *)date
             dayNum:(int)dayNum
 periodsBeforeBreak:(int)pbb
         afterBreak:(int)pab
        breakLength:(int)blength
       periodLength:(int)plength;

- (id)initWithDate:(IHWDate *)date
            dayNum:(int)dayNum
        numPeriods:(int)numPeriods
      periodLength:(int)plength;

- (id)initWithJSONDictionary:(NSDictionary *)dictionary;
- (void)fillPeriodsFromCurriculum:(IHWCurriculum *)c;
- (NSDictionary *)saveDay;
- (NSString *)title;

@end
