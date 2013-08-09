//
//  IHWPeriod.h
//  iHW
//
//  Created by Andrew Friedman on 7/10/13.
//  Copyright (c) 2013 Andrew Friedman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IHWTime.h"
#import "IHWDate.h"

@interface IHWPeriod : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) IHWTime *startTime;
@property (strong, nonatomic) IHWTime *endTime;
@property (strong, nonatomic) IHWDate *date;
@property int periodNum;

- (id)initWithName:(NSString *)name date:(IHWDate *)date start:(IHWTime *)start end:(IHWTime *)end number:(int)periodNum;
- (id)initWithJSONDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)savePeriod;

@end
