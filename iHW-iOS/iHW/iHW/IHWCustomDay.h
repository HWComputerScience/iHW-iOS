//
//  IHWCustomDay.h
//  iHW
//
//  Created by Jonathan Burns on 7/10/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import "IHWDay.h"

@interface IHWCustomDay : IHWDay

- (id)initWithTests:(NSArray *)tests onDate:(IHWDate *)date;
- (id)initWithJSONDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)saveDay;

@end
