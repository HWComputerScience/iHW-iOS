//
//  NSArray+iHW_data.h
//  iHW
//
//  Created by Lara Bagdasarian on 2/28/16.
//  Copyright © 2016 Jonathan Burns. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IHWJSONInfo.h"
@interface NSArray (iHW_data)
-(NSMutableArray*)accountID;
-(void)courseNumberID:(IHWJSONInfo*) jsonObject;
-(NSMutableArray*)schedule;
-(NSMutableArray*)conventionalCode;
@end
