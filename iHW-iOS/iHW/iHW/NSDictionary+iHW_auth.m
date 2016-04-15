//
//  NSDictionary+iHW_auth.m
//  iHW
//
//  Created by Lara Bagdasarian on 4/10/16.
//  Copyright © 2016 Jonathan Burns. All rights reserved.
//

#import "NSDictionary+iHW_auth.h"

@implementation NSDictionary (iHW_auth)

-(NSString*) accessToken
{
    return self[@"access_token"];
}
@end
