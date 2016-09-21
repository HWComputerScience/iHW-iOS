//
//  IHWCalendarEvent.m
//  iHW
//
//  Created by Jonathan Damico on 8/12/16.
//  Copyright © 2016 Jonathan Burns. All rights reserved.
//

#import "IHWCalendarEvent.h"
#import "IHWFileManager.h"
#import "IHWUtils.h"
#import "IHWCurriculum.h"
#import "CJSONDeserializer.h"

@implementation IHWCalendarEvent
-(id)init
{
    self = [super init];
    if (self) {
        self.title = nil;
        self.courseID = nil;
        self.contextCode = nil;
        self.date = nil;
    }
    return self;
}

- (id)initWithJSONDictionary: (NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.title = dict[@"title"];
        self.courseID = dict[@"courseID"];
        self.contextCode = dict[@"contextCode"];
        self.date = dict[@"date"];
    }
    return self;
}

- (NSDictionary *)saveCalendarEvent {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:self.title forKey:@"title"];
    [dict setObject:self.courseID forKey:@"courseID"];
    [dict setObject:self.contextCode forKey:@"contextCode"];
    [dict setObject:self.date forKey:@"date"];
    return [NSDictionary dictionaryWithDictionary:dict];
}
+(void) downloadCalendarEvents:(NSMutableArray *) contextCodes {
    NSMutableArray *calendar = [[NSMutableArray alloc] init];
    NSString *contextCode = nil;
    NSString *eventType = nil;
    NSArray *eventTypes = [NSArray arrayWithObjects: @"event", @"assignment", nil];
    NSString *accessToken = [self getCanvasAccessToken];
    for(eventType in eventTypes) {
        for(contextCode in contextCodes) {
            NSString *urlString = [NSString stringWithFormat:@"https://hub.hw.com/api/v1/calendar_events?per_page=500&all_events=true&context_codes[]=%@&access_token=%@&type=%@", contextCode, accessToken,eventType];
            NSDictionary *headers = @{ @"cache-control": @"no-cache",
                                       @"postman-token": @"15389f09-d1b4-7f18-6601-3d651b762198" };
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                                   cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                               timeoutInterval:10.0];
            [request setHTTPMethod:@"GET"];
            [request setAllHTTPHeaderFields:headers];
            
            NSURLSession *session = [NSURLSession sharedSession];
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
                                                            if (error) {
                                                                NSLog(@"%@", error);
                                                            } else {
                                                                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                                                NSLog(@"%@", httpResponse);
                                                                NSError *error = nil;
                                                                NSArray *dataJSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                                                if (error != nil) {
                                                                    NSLog(@"Error parsing JSON.");
                                                                } else {
                                                                    //NSLog(@"%@", dataJSON);
                                                                    for(NSDictionary *event in dataJSON) {
                                                                        IHWCalendarEvent *eventObj = [[self alloc ]init];
                                                                        eventObj.title = event[@"title"];
                                                                        eventObj.contextCode = event[@"context_code"];
                                                                        eventObj.date = event[@"all_day_date"];
                                                                        
                                                                        NSDictionary *assignment = event[@"assignment"];
                                                                        if(assignment!=nil)
                                                                            eventObj.courseID = assignment[@"course_id"];
                                                                        else
                                                                            eventObj.courseID = [event[@"context_code"] substringFromIndex:7];
                                                                        [calendar addObject:[eventObj saveCalendarEvent]];
                                                                    }
                                                                }
                                                            }
                                                            dispatch_semaphore_signal(sema);
                                                        }];
            [dataTask resume];
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        }
    }
    NSDictionary *eventsDict = @{ @"events":calendar };
    NSError *error = nil;
    NSData *eventsJSON = [[CJSONSerializer serializer] serializeDictionary:eventsDict error:&error];
    if (error != nil) { NSLog(@"ERROR serializing courses: %@", error.debugDescription); return; }
    [IHWFileManager saveCalendarJSON:eventsJSON forYear:[IHWCurriculum currentYear] campus:getCampusChar([IHWCurriculum currentCampus])];
}

+(NSString *)getCanvasAccessToken {
    __block NSString *accessToken = nil;
    NSDictionary *headers = @{ @"cache-control": @"no-cache",
                               @"postman-token": @"1bb438ad-aff5-a8dd-2d5e-60d9ffb99222" };
    
    NSData *refreshTokenData = [IHWFileManager loadTokenJSON];
    NSError *error = nil;
    NSDictionary *fromJSON = [[CJSONDeserializer deserializer] deserializeAsDictionary:refreshTokenData error:&error];
    if(error == nil) {
        NSString *refreshToken = fromJSON[@"refresh_token"];
    NSString *urlString = [NSString stringWithFormat:@"https://ihwoauth.hwtechcouncil.com/?refresh_token=%@", refreshToken];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"GET"];
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSession *session = [NSURLSession sharedSession];
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (error) {
                                                        NSLog(@"%@", error);
                                                    } else {
                                                        NSError *error = nil;
                                                        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                                        if (error != nil) {
                                                            NSLog(@"Error parsing refresh token JSON.");
                                                        } else {
                                                            accessToken = dataDict[@"access_token"];
                                                        }
                                                    }
                                                    dispatch_semaphore_signal(sema);
                                                }];
        [dataTask resume];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    return(accessToken);
    
}

@end
