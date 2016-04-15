//
//  NSArray+iHW_data.m
//  iHW
//
//  Created by Lara Bagdasarian on 2/28/16.
//  Copyright © 2016 Jonathan Burns. All rights reserved.
//

#import "NSArray+iHW_data.h"
#
@implementation NSArray(iHW_data)

-(NSMutableArray*)accountID // like Malina Mamigonia::English III Honors :(
{
    NSMutableArray* a = [[NSMutableArray alloc]init];
    NSMutableArray* d = [[NSMutableArray alloc]init];

    for (int x = 0; x< self.count; x++)
    {
        NSString* b =self[x][@"course_code"];
        NSString* d = self[x][@"id"];
        if ([b characterAtIndex:1] == '5'){
       // a = [NSString stringWithFormat: @"%@\n%@",a,b];
            [a addObject:b];  
        }
    }
    return a;
}

//getSectionsCode
//

-(void) courseNumberID: (IHWJSONInfo*) jsonObject//like 1661020
{
    for (int x = 0; x<self.count;x++)
    {
   //     NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        if ([[[self accountID] objectAtIndex:x] characterAtIndex:1] == '5')
            [jsonObject.courseID addObject: (NSString*)self[x][@"id"]];
    }
}
-(NSMutableArray*)schedule //like 4.4.x.4.4
{
    NSMutableArray* a = [[NSMutableArray alloc] init];
    for (int x = 0; x<self.count;x++)
    {
        //     NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
            NSString* s = [self[x][@"name"] substringFromIndex:[self[x][@"name"] rangeOfString:@","].location+2];
        //if (!([s isEqualToString:@"3320-0C1, 8.8.8.8.8.x"]||[s isEqualToString:@"Latin II - Pike"]))
            [a addObject: s];
    }
    return a;
}

-(NSMutableArray*) conventionalCode //like 123A0
{
    NSMutableArray* a = [[NSMutableArray alloc] init];
    for (int x = 0; x<self.count;x++)
    {
        //     NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        [a addObject: [self[x][@"name"] substringToIndex:[self[x][@"name"] rangeOfString:@","].location]];
    }
    return a;
}
@end
