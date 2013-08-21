//
//  IHWPeriod.h
//  iHW
//
//  Created by Jonathan Burns on 7/10/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IHWTime.h"
#import "IHWDate.h"

@interface IHWPeriod : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) IHWTime *startTime;
@property (strong, nonatomic) IHWTime *endTime;
@property (strong, nonatomic) IHWDate *date;
@property (strong, nonatomic) NSMutableArray *notes;
@property int periodNum;
@property int index;

- (id)initWithName:(NSString *)name date:(IHWDate *)date start:(IHWTime *)start end:(IHWTime *)end number:(int)periodNum index:(int)periodIndex;
- (id)initWithJSONDictionary:(NSDictionary *)dictionary;
- (void)loadNotesFromCurriculum;
- (void)saveNotes;
- (NSDictionary *)savePeriod;

@end
