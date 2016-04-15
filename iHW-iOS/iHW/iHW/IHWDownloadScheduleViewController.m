//
//  IHWDownloadScheduleViewController.m
//  iHW
//
//  Created by Jonathan Burns on 8/12/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import "IHWDownloadScheduleViewController.h"
#import "IHWAppDelegate.h"
#import "HTMLParser.h"
#import "IHWCourse.h"
#import "IHWCurriculum.h"
#import "IHWFirstRunViewController.h"
#import "IHWGuidedCoursesViewController.h"
#import "IHWNormalCoursesViewController.h"
#import "IHWScheduleViewController.h"
#import "IHWUtils.h"
#import "AFNetworking.h"
#import "NSDictionary+iHW.h"
#import "NSDictionary+iHW_auth.h"
#import "NSArray+iHW_data.h"
#import "IHWJSONInfo.h"
@interface IHWDownloadScheduleViewController()
@property(strong) NSDictionary *iHW;
@property(strong) NSArray *iHW2;
@property(strong) NSArray *iHW3;
@property(strong) NSString* accessToken;
@property(strong) IHWJSONInfo* theData;
@end

//This class controls the screen where the user logs into HW.com and downloads their schedule into the app.
@implementation IHWDownloadScheduleViewController {
    BOOL alreadyLoaded;
    BOOL hasCourseCode;
    NSMutableArray* courseCodesArray;
    NSMutableArray* courseNamesArray;
    NSMutableArray* conventionalScheduleArray;
    NSMutableArray* scheduleArray;

    int n;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        alreadyLoaded = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.accessToken=@"1~FIe4zybFqbqUX7vysUhzfCIv5LckEhrChukr81uQNgkAHtlHFqMznhCaUSKgy9DW";//some token in this format
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
        //Make sure they actually have to log in each time
    }
    self.webView.delegate = self;
    self.webView.keyboardDisplayRequiresUserAction = NO;
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        self.topSpaceConstraint.constant = 0;
    }
    //Load the login page
    
    
   
    //[self.webView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://hub.hw.com/login/oauth2/auth?client_id=10000000000502&response_type=code&redirect_uri=https://ihwoauth.hwtechcouncil.com"]]];//to auth and get auth code
 //  [self.webView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://hub.hw.com/api/v1/courses?access_token=1~FIe4zybFqaqUX7vysUhzfCIv5LckEhrChukr89uQNgkAHtlHFqMznhCaUSKgy9DW"]]];
   
    //first synchronous request to courses page
    _theData = [[IHWJSONInfo alloc] init];
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"https://hub.hw.com/api/v1/courses?access_token=%@",self.accessToken]];
    NSURLRequest* urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30];
    
    NSData* urlData;
    NSURLResponse* response;
    NSError* error;
    
    //make the synchronous request
    urlData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    
    NSArray* courseObject = [NSJSONSerialization JSONObjectWithData:urlData options:0 error:&error];
 //   NSLog(@"it's working until this point %@", courseObject);

    for (int x = 0; x< courseObject.count; x++)
    {
        NSDictionary* dict = courseObject[x];
        NSString* b =dict[@"id"];
        //NSLog(@"<<<<<<<<%@",b);

        NSString* d = dict[@"name"];
      //  NSLog(@">>>>%@",d);
        //NSLog(@"number to check %lu", (unsigned long)courseObject.count);

        if ([d characterAtIndex:1] == '5'){
         //    NSString* a = [NSString stringWithFormat: @"%@\n%@",b,d];
           [_theData.courseID addObject:b];
            [_theData.courseName addObject:d];
        }
    }
    
    NSLog(@"%@",_theData.courseID);
    NSLog(@"%@",_theData.courseName);

    
    
    //second synchronous request to enrollments page with auth header
    NSURL* url2 = [NSURL URLWithString:@"https://hub.hw.com/api/v1/users/self/enrollments?per_page=500"];//if needed add header and add ?per_page =500
    NSMutableURLRequest* urlRequest2 = [NSMutableURLRequest requestWithURL:url2 cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30];
    [urlRequest2 setValue:[NSString stringWithFormat:@"Bearer %@", self.accessToken] forHTTPHeaderField:@"Authorization"];//add header to request

    NSData* urlData2;
    NSURLResponse* response2;
    NSError* error2;
    
    //make the synchronous request
    urlData2 = [NSURLConnection sendSynchronousRequest:urlRequest2 returningResponse:&response2 error:&error2];
    
    courseObject = [NSJSONSerialization JSONObjectWithData:urlData2 options:0 error:&error2];
    NSLog(@"it's working until this point2 %@", courseObject);
/**    _theData.courseSectionID=[[NSMutableArray alloc ]initWithCapacity:_theData.courseName.count];
    _theData.courseCode=[[NSMutableArray alloc ]initWithCapacity:_theData.courseName.count];
    _theData.courseSectionID=[[NSMutableArray alloc ]initWithCapacity:_theData.courseName.count];
*/
    for (int x = 0; x<_theData.courseName.count; x++)
    {
        _theData.courseSectionID[x] = @" ";
    }
    
    for (int x = 0; x< courseObject.count; x++)
    {
        NSDictionary* dict = courseObject[x];
        NSString* b =dict[@"course_id"];
   //     NSLog(@"<<<<<<<<%@",b);
        
        NSString* d = dict[@"course_section_id"];
   //     NSLog(@">>>>%@",d);
        //NSLog(@"number to check %lu", (unsigned long)courseObject.count);
        BOOL inIt = false;
      //  NSLog(@"size %lu", (unsigned long)_theData.courseID.count);
        int cou = 0;
        for (cou = 0; cou<_theData.courseID.count; cou++){
            if(_theData.courseID[cou] ==b)
            {
                inIt = true;
                break;
            }
        }
        if (inIt){
            _theData.courseSectionID[cou] =d;
        }
    }
    
    NSLog(@"%@",_theData.courseSectionID);
    
  //  NSLog(@"we are done2 . . .");
    
    
    //third request for actual section and course code -- this one is looped
    for (int counter = 0; counter<_theData.courseSectionID.count; counter++){
        NSURL* url3 = [NSURL URLWithString:[NSString stringWithFormat:@"https://hub.hw.com/api/v1/sections/%@",_theData.courseSectionID[counter]]];//if needed add header and add ?per_page =500
        NSMutableURLRequest* urlRequest3 = [NSMutableURLRequest requestWithURL:url3 cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30];
        [urlRequest3 setValue: [ NSString stringWithFormat:@"Bearer %@",self.accessToken] forHTTPHeaderField:@"Authorization"];//add header to request
        
        NSData* urlData3;
        NSURLResponse* response3;
        NSError* error3;
        NSLog(@"url that's being called:%@", [url3 absoluteString]);
        //make the synchronous request
        urlData3 = [NSURLConnection sendSynchronousRequest:urlRequest3 returningResponse:&response3 error:&error3];
        NSDictionary* courseObject3 = [NSJSONSerialization JSONObjectWithData:urlData3 options:0 error:&error3];
     //   NSLog(@"it's working until this point3 %@", courseObject3);
        
        NSString* b = courseObject3[@"name"];
            NSLog(@"<<<<<<<<%@",b);
        NSArray* nameInTwoParts = [b componentsSeparatedByString:@", "];
        if (nameInTwoParts[0]!=nil)
            [_theData.courseCode addObject:nameInTwoParts[0]];
        if (nameInTwoParts[1]!=nil)
            [_theData.courseSection addObject:nameInTwoParts[1]];
    }
    
    NSLog(@"%@",_theData.courseCode);
    NSLog(@"%@",_theData.courseSection);
    
    NSLog(@"we are done3 . . .");
    /*dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //DATA Processing

        dispatch_sync(dispatch_get_main_queue(), ^{
           //update UI here
        });
        
        
    });*/
   
   [self saveStuff];
    
    //load page https://hub.hw.com/login/oauth2/auth?client_id=10000000000502&response_type=code&redirect_uri=https://ihwoauth.hwtechcouncil.com
   // [self.webView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://hub.hw.com/login/oauth2/auth?client_id=10000000000502&response_type=code&redirect_uri=https://ihwoauth.hwtechcouncil.com"]]];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (IBAction)backPressed:(id)sender {
    if ([IHWCurriculum isFirstRun]) [self.navigationController popViewControllerAnimated:YES];
    else [self.navigationController setViewControllers:@[[[IHWScheduleViewController alloc] initWithNibName:@"IHWScheduleViewController" bundle:nil]] animated:YES];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {//to redirect so parse token here
    //Make sure that the UIWebView can only access these three URLs
   // NSLog(@"%@%@",@"jkljlkj",request.URL);
    //    BOOL result = ([request.URL isEqual:[NSURL URLWithString:@"https://hub.hw.com/login/oauth2/confirm"]]
    //                || [request.URL isEqual:[NSURL URLWithString:@"https://auth.hw.com/LoginFormIdentityProvider/Login.aspx?ReturnUrl=%2fLoginFormIdentityProvider%2fDefault.aspx"]]
    //               || [request.URL isEqual:[NSURL URLWithString:@"https://hub.hw.com/login/oauth2/auth?client_id=10000000000502&response_type=code&redirect_uri=https://ihwoauth.ihwapp.com"]]
    //  || [request.URL isEqual:[NSURL URLWithString:@"https://hub.hw.com/login/saml"]]
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:request.URL.absoluteString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);// 3
        if ([request.URL.absoluteString rangeOfString:@"https://ihwoauth.hwtechcouncil.com/?code="].location !=NSNotFound){
        self.iHW = (NSDictionary *)responseObject;//response object as an array of all of the courses
        NSLog(@"json retreived!!!!");
        n = 0;
        //        NSLog(@"%@%@",@"ACCOUNT_ID IS ",[self.iHW2 accountID]);
        NSString* accessKey = self.iHW [@"access_token"];
        NSLog(@"%@%@",@"ACCESSKEY IS ",accessKey);
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        // 4
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Data"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
  
      [(IHWAppDelegate *)[UIApplication sharedApplication].delegate performSelectorOnMainThread:@selector(showNetworkIcon) withObject:nil waitUntilDone:NO];    [(IHWAppDelegate *)[UIApplication sharedApplication].delegate performSelectorOnMainThread:@selector(showNetworkIcon) withObject:nil waitUntilDone:NO];
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    [(IHWAppDelegate *)[UIApplication sharedApplication].delegate performSelectorOnMainThread:@selector(hideNetworkIcon) withObject:nil waitUntilDone:NO];
    // NSURL* URL2 = [NSURL URLWithString:@"https://canvas.instructure.com/api/v1/courses/10000001661076/sections?access_token=1~i6dRCWGZSIX7PeE1qNjDtfWY8pRNukTKtztnszsmSAKxShcpfYKUt0kkcdWuvAdZ"];
    //   NSURL *url = webView.request.mainDocumentURL;
    //NSLog(@"URL did finish load: %@", url.description);
    //    if ([url isEqual:[NSURL URLWithString:@"https://<canvas-install-url>/login/oauth2/auth?client_id=XXX&response_type=code&redirect_uri=https://example.com/oauth_complete&state=YY"]]) {
    //If the login page just loaded, show the UIWebView and prompt the user to log in.
    self.webView.hidden = NO;
    self.loginPromptLabel.hidden = NO;
    if (!alreadyLoaded) {
        //This is the first time the "My Schedule" page loaded, so we haven't injected the JavaScript to find the schedule URL yet.
        alreadyLoaded = YES;
        self.loadingText.text = @"Please wait, finding schedule...";
        //This string of JavaScript simulates clicking the "View" button on the "My Schedule" page.
        //That triggers a reload of the page, but once the page is reloaded, it contains the schedule URL.
        [self.webView stringByEvaluatingJavaScriptFromString:@"__doPostBack(\"dnn$ctr8420$InteractiveSchedule$lnkStudentScheduleHTML\", \"\");"];
        
    }
    
    //now we're actually doing the saving stufff
    
    
}
-(void)saveStuff{
    NSString *lastCode = _theData.courseCode[0];
    NSString *lastName = _theData.courseName[0];
    NSArray *lastPeriodList = [(NSString*)[_theData.courseSection objectAtIndex:0] componentsSeparatedByString:@"."];
    NSLog(@"last Period list,%@",lastPeriodList);
    BOOL shouldShowWarning = NO;
    //NSLog(@"Last PERIODLISTCOUNT%lusomecampus thing%d",(unsigned long)lastPeriodList.count,[IHWCurriculum currentCurriculum].campus);
   if ((int)lastPeriodList.count != [IHWCurriculum currentCurriculum].campus) {
        //The course period list doesn't have the same number of days as the campus the user chose earlier.
        [[[UIAlertView alloc] initWithTitle:@"Wrong Campus!" message:@"You chose the wrong campus during the setup. Please start again." delegate:self cancelButtonTitle:@"Back" otherButtonTitles:nil] show];
        return;
    }
    //NSLog(@"number of iterations%lu", (unsigned long)scheduleArray.count);
    for (int ccount = 0; ccount<_theData.courseSection.count; ccount++)
    {
        
        lastCode = _theData.courseCode[ccount];
        lastName = _theData.courseName[ccount];
        lastPeriodList = [(NSString*)[_theData.courseSection objectAtIndex:ccount] componentsSeparatedByString:@"."];
    //    NSArray* testArray = [NSArray arrayWithObjects:@"3",@"x",@"3",@"3",@"3", nil];
        
        IHWCourse *c = parseCourse(lastCode, lastName, lastPeriodList);
        //NSLog(@"%@%@%@%@",@"hello",lastCode,lastName,lastPeriodList);
        
        if (c != nil) {
            //Course is valid -- add it
            if (![[IHWCurriculum currentCurriculum] addCourse:c]) NSLog(@"WARNING: Course Conflict!");//problem here!!!!!3/1
        }
        //reset the variables for the next time through the loop
       
        //Save the courses
        
        NSLog(@"waiting");
        
    }
    [[IHWCurriculum currentCurriculum] saveCourses];
    if (shouldShowWarning) {
        //Show a warning if the schedule was a preliminary schedule
        [[[UIAlertView alloc] initWithTitle:@"Full Schedule Unavailable" message:@"The full schedule is not yet available, so you will need to edit the courses that are not full-year and set the right semester/trimester." delegate:self cancelButtonTitle:@"Edit Courses" otherButtonTitles:nil] show];
    } else {
        //Otherwise go directly to the main schedule page
        IHWScheduleViewController *svc = [[IHWScheduleViewController alloc] initWithNibName:@"IHWScheduleViewController" bundle:nil];
        [self.navigationController pushViewController:svc animated:YES];
        //Clear the ViewController stack
        [self.navigationController setViewControllers:[NSArray arrayWithObject:svc]];
        
        
    }
    
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [(IHWAppDelegate *)[UIApplication sharedApplication].delegate performSelectorOnMainThread:@selector(hideNetworkIcon) withObject:nil waitUntilDone:NO];
    NSURL *failingURL = [[error userInfo] objectForKey:@"NSErrorFailingURLKey"];
    NSLog(@"ERROR loading URL into webView: %@", error.debugDescription);
    if ([failingURL.description hasPrefix:@"http://www.hw.com/Default.aspx?tabid=3215&error="]) {
        //If HW.com gave us an error, then we pass the error on to the user:
        [[[UIAlertView alloc] initWithTitle:@"Schedule Unavailable" message:@"Your schedule is not currently available on HW.com. You can still enter your courses manually, though:" delegate:self cancelButtonTitle:@"Add Courses Manually" otherButtonTitles:nil] show];
        
    }
}

//Handles the error messages for the HW.com error and the errors in schedule parsing (above and below)
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Add Courses Manually"]) {
        UINavigationController *c = self.navigationController;
        [c popToRootViewControllerAnimated:NO];
        [c pushViewController:[[IHWGuidedCoursesViewController alloc] initWithNibName:@"IHWGuidedCoursesViewController" bundle:nil] animated:YES];
    } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Edit Courses"]){
        IHWNormalCoursesViewController *ncvc = [[IHWNormalCoursesViewController alloc] initWithNibName:@"IHWNormalCoursesViewController" bundle:nil];
        IHWScheduleViewController *svc = [[IHWScheduleViewController alloc] initWithNibName:@"IHWScheduleViewController" bundle:nil];
        [self.navigationController pushViewController:svc animated:YES];
        [svc presentViewController:ncvc animated:YES completion:nil];
        [self.navigationController setViewControllers:[NSArray arrayWithObject:svc]];
    } else {
        self.navigationController.viewControllers = [NSArray arrayWithObjects:[[IHWFirstRunViewController alloc] initWithNibName:@"IHWFirstRunViewController" bundle:nil], self, nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)downloadScheduleFromURL:(NSString *)urlStr {
    self.loadingText.text = @"Schedule found. Downloading...";
    [(IHWAppDelegate *)[UIApplication sharedApplication].delegate performSelectorOnMainThread:@selector(showNetworkIcon) withObject:nil waitUntilDone:NO];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection self]; //to stop "unused" warnings
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    //Annoyingly, we have to handle the data bit by bit as it comes in.
    [self.resultData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [(IHWAppDelegate *)[UIApplication sharedApplication].delegate performSelectorOnMainThread:@selector(hideNetworkIcon) withObject:nil waitUntilDone:NO];
    
    //Schedule has finished loading -- parse it
    //You should really take a look at the HTML source of the schedule page before even attempting to understand how this works.
    NSError *error = nil;
    HTMLParser *parser = [[HTMLParser alloc] initWithData:self.resultData error:&error];
    if (error != nil) { NSLog(@"ERROR parsing schedule HTML: %@", error.debugDescription); return; }
    //Remove courses to prepare for new ones to be added
    [[IHWCurriculum currentCurriculum] removeAllCourses];
    NSArray *divs = [[parser body] findChildTags:@"div"];
    NSString *lastCode = courseCodesArray[n];
    NSString *lastName = courseNamesArray[n];
    NSArray *lastPeriodList = [(NSString*)[scheduleArray objectAtIndex:n] componentsSeparatedByString:@"."];
    BOOL shouldShowWarning = NO;
    
    
    //Break the list into components by day
    if (lastPeriodList.count != [IHWCurriculum currentCurriculum].campus) {
        //The course period list doesn't have the same number of days as the campus the user chose earlier.
        [[[UIAlertView alloc] initWithTitle:@"Wrong Campus!" message:@"You chose the wrong campus during the setup. Please start again." delegate:self cancelButtonTitle:@"Back" otherButtonTitles:nil] show];
        return;
    }
    //Create the course object once we have a course code, name, and period list
    IHWCourse *c = parseCourse(lastCode, lastName, lastPeriodList);
    if (c != nil) {
        //Course is valid -- add it
        if (![[IHWCurriculum currentCurriculum] addCourse:c]) NSLog(@"WARNING: Course Conflict!");
    }
    //reset the variables for the next time through the loop
    lastCode = nil;
    lastName = nil;
    lastPeriodList = nil;
    n++;
    
    //Save the courses
    [[IHWCurriculum currentCurriculum] saveCourses];
    if (shouldShowWarning) {
        //Show a warning if the schedule was a preliminary schedule
        [[[UIAlertView alloc] initWithTitle:@"Full Schedule Unavailable" message:@"The full schedule is not yet available, so you will need to edit the courses that are not full-year and set the right semester/trimester." delegate:self cancelButtonTitle:@"Edit Courses" otherButtonTitles:nil] show];
    } else {
        //Otherwise go directly to the main schedule page
        IHWScheduleViewController *svc = [[IHWScheduleViewController alloc] initWithNibName:@"IHWScheduleViewController" bundle:nil];
        [self.navigationController pushViewController:svc animated:YES];
        //Clear the ViewController stack
        [self.navigationController setViewControllers:[NSArray arrayWithObject:svc]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    self.webView.delegate = nil;
    //[super dealloc];
}

@end

