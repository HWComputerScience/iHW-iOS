//
//  IHWDay.h
//  iHW
//
//  Created by Andrew Friedman on 7/10/13.
//  Copyright (c) 2013 Andrew Friedman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IHWDate.h"

@interface IHWDay : NSObject

@property (strong, nonatomic) IHWDate *date;
@property (strong, nonatomic) NSMutableArray *periods;

- (id)initWithDate:(IHWDate *)date;
- (id)initWithJSONDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)saveDay;
- (NSString *)title;

@end
