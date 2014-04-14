//
//  IHWDay.h
//  iHW
//
//  Created by Jonathan Burns on 7/10/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IHWDate.h"

@interface IHWDay : NSObject

@property (strong, nonatomic) IHWDate *date;
@property (strong, nonatomic) NSMutableArray *periods;
@property (strong, nonatomic) NSString *caption;
@property (strong, nonatomic) NSString *captionLink;

- (id)initWithDate:(IHWDate *)date;
- (id)initWithJSONDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)saveDay;
- (NSString *)title;

@end
