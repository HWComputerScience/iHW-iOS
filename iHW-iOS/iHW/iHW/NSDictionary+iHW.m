//
//  NSDictionary+iHW.m
//  
//
//  Created by Lara Bagdasarian on 2/27/16.
//
//

#import "NSDictionary+iHW.h"

@implementation NSDictionary(weather)

- (NSDictionary *)currentCondition
{
    //we have a dictionary full of commaed things like current condition, etc. called dicts
    NSDictionary *dict = self[@"data"];//transcend a collectionblocked by "data"
    NSArray* ar = dict[@"current_condition"];//transcend the array blocked by current condition
    return ar[0];
}

-(NSDictionary*)categoryOne
{
    NSDictionary* dict = self[@"id"];
    return dict;
}
@end