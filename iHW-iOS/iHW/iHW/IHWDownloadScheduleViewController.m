//
//  IHWDownloadScheduleViewController.m
//  iHW
//
//  Created by Jonathan Burns on 8/12/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import "IHWDownloadScheduleViewController.h"
#import "HTMLParser.h"
#import "IHWCourse.h"
#import "IHWCurriculum.h"
#import "IHWFirstRunViewController.h"
#import "IHWGuidedCoursesViewController.h"
#import "IHWNormalCoursesViewController.h"
#import "IHWScheduleViewController.h"

IHWCourse *parseCourse(NSString *code, NSString *name, NSArray *periodComponents) {
    int term = TERM_FULL_YEAR;
    if (code.length >= 6) term = [[code substringWithRange:NSMakeRange(5, 1)] intValue];
    
    //parse period list
    int numDays = [IHWCurriculum currentCampus];
    int numPeriods = numDays+3;
    BOOL periods[numDays][numPeriods+1];
    for (int d=0; d<numDays; d++) for (int p=0; p<=numPeriods; p++) {
        periods[d][p] = NO;
    }
    int periodFrequency[numPeriods+1];
    for (int p=0; p<=numPeriods; p++) {
        periodFrequency[p] = 0;
    }
    int minPeriod = numPeriods+1;
    int maxPeriod = 0;
    int day = 0;
    for (NSString *component in periodComponents) {
        for (int i=0; i<component.length; i++) {
            int period = [[component substringWithRange:NSMakeRange(i, 1)] intValue];
            if (period > 0) {
                periods[day][period] = YES;
                minPeriod = MIN(minPeriod, period);
                maxPeriod = MAX(maxPeriod, period);
                periodFrequency[period]++;
            }
        }
        day++;
    }
    //determine course period
    int coursePeriod;
    if (minPeriod == maxPeriod) coursePeriod = minPeriod;
    else if (maxPeriod-minPeriod == 2) coursePeriod = maxPeriod-1;
    else if (maxPeriod-minPeriod == 1 && periodFrequency[maxPeriod] > periodFrequency[minPeriod]) coursePeriod = maxPeriod;
    else if (maxPeriod-minPeriod == 1 && periodFrequency[maxPeriod] <= periodFrequency[minPeriod]) coursePeriod = minPeriod;
    else return nil;
    //create meetings array
    NSMutableArray *meetings = [NSMutableArray array];
    for (int i=0; i<numDays; i++) {
        if (!periods[i][coursePeriod]) [meetings setObject:[NSNumber numberWithInt:MEETING_X_DAY] atIndexedSubscript:i];
        else if (coursePeriod-1 > 0 && periods[i][coursePeriod-1]) [meetings setObject:[NSNumber numberWithInt:MEETING_DOUBLE_BEFORE] atIndexedSubscript:i];
        else if (coursePeriod+1 <= numPeriods && periods[i][coursePeriod+1]) [meetings setObject:[NSNumber numberWithInt:MEETING_DOUBLE_AFTER] atIndexedSubscript:i];
        else [meetings setObject:[NSNumber numberWithInt:MEETING_SINGLE_PERIOD] atIndexedSubscript:i];
    }
    return [[IHWCourse alloc] initWithName:name period:coursePeriod term:term meetings:meetings];
}

@implementation IHWDownloadScheduleViewController {
    BOOL alreadyLoaded;
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
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    self.webView.delegate = self;
    [self.webView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://www.hw.com/students/Login/tabid/2279/Default.aspx?returnurl=%2fstudents%2fSchoolResources%2fMyScheduleEvents.aspx"]]];
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return ([request.URL isEqual:[NSURL URLWithString:@"https://www.hw.com/students/Login/tabid/2279/Default.aspx?returnurl=%2fstudents%2fSchoolResources%2fMyScheduleEvents.aspx"]]
            || [request.URL isEqual:[NSURL URLWithString:@"http://www.hw.com/students/SchoolResources/MyScheduleEvents.aspx"]]
            || [request.URL isEqual:[NSURL URLWithString:@"https://www.hw.com/students/SchoolResources/MyScheduleEvents.aspx"]]);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSURL *url = webView.request.mainDocumentURL;
    NSLog(@"URL did finish load: %@", url.description);
    if ([url isEqual:[NSURL URLWithString:@"https://www.hw.com/students/Login/tabid/2279/Default.aspx?returnurl=%2fstudents%2fSchoolResources%2fMyScheduleEvents.aspx"]]) {
        self.webView.hidden = NO;
        self.loginPromptLabel.hidden = NO;
    } else if ([url isEqual:[NSURL URLWithString:@"http://www.hw.com/students/SchoolResources/MyScheduleEvents.aspx"]]) {
        self.webView.hidden = YES;
        self.loginPromptLabel.hidden = YES;
        if (!alreadyLoaded) {
            alreadyLoaded = YES;
            self.loadingText.text = @"Please wait, finding schedule...";
            [self.webView stringByEvaluatingJavaScriptFromString:@"__doPostBack(\"dnn$ctr8420$InteractiveSchedule$lnkStudentScheduleHTML\", \"\");"];
        } else {
            NSString *scheduleURL = [self.webView stringByEvaluatingJavaScriptFromString:@"document.getElementById(\"dnn_ctr8420_InteractiveSchedule_txtWindowPopupUrl\").value"];
            self.resultData = [NSMutableData data];
            [self downloadScheduleFromURL:scheduleURL];
        }
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSURL *failingURL = [[error userInfo] objectForKey:@"NSErrorFailingURLKey"];
    NSLog(@"ERROR loading URL into webView: %@", error.debugDescription);
    if ([failingURL.description hasPrefix:@"http://www.hw.com/Default.aspx?tabid=3215&error="]) {
        [[[UIAlertView alloc] initWithTitle:@"Schedule Unavailable" message:@"Your schedule is not currently available on HW.com. You can still enter your courses manually, though:" delegate:self cancelButtonTitle:@"Add Courses Manually" otherButtonTitles:nil] show];
    }
}

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
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection self]; //to stop warnings
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.resultData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSError *error = nil;
    HTMLParser *parser = [[HTMLParser alloc] initWithData:self.resultData error:&error];
    if (error != nil) { NSLog(@"ERROR parsing schedule HTML: %@", error.debugDescription); return; }
    NSArray *divs = [[parser body] findChildTags:@"div"];
    NSString *lastCode = nil;
    NSString *lastName = nil;
    NSString *lastPeriodList = nil;
    BOOL shouldShowWarning = NO;
    for (HTMLNode *div in divs) {
        if ([[div getAttributeNamed:@"id"] isEqualToString:@"nameStudentName1-0"]) {
            NSLog(@"Welcome, %@", [[[div findChildTags:@"span"] objectAtIndex:0] contents]);
        } else if ([[div getAttributeNamed:@"id"] isEqualToString:@"sectCode1"]) {
            lastCode = [[[div findChildTags:@"span"] objectAtIndex:0] contents];
            if (lastCode.length <= 4) shouldShowWarning = YES;
        } else if ([[div getAttributeNamed:@"id"] isEqualToString:@"sectTitle1"]) {
            lastName = [[[div findChildTags:@"span"] objectAtIndex:0] contents];
        } else if ([[div getAttributeNamed:@"id"] isEqualToString:@"sectPeriodList1"]) {
            lastPeriodList = [[[div findChildTags:@"span"] objectAtIndex:0] contents];
            NSArray *lastPeriodComponents = [lastPeriodList componentsSeparatedByString:@"."];
            if (lastPeriodComponents.count != [IHWCurriculum currentCurriculum].campus) {
                [[[UIAlertView alloc] initWithTitle:@"Wrong Campus!" message:@"You chose the wrong campus during the setup. Please start again." delegate:self cancelButtonTitle:@"Back" otherButtonTitles:nil] show];
                return;
            }
            IHWCourse *c = parseCourse(lastCode, lastName, lastPeriodComponents);
            if (c != nil) {
                if (![[IHWCurriculum currentCurriculum] addCourse:c]) NSLog(@"Course Conflict!");
            }
            lastCode = nil;
            lastName = nil;
            lastPeriodList = nil;
        } else if ([[div getAttributeNamed:@"id"] isEqualToString:@"Subreport8"]) {
            break;
        }
    }
    [[IHWCurriculum currentCurriculum] saveCourses];
    if (shouldShowWarning) {
        [[[UIAlertView alloc] initWithTitle:@"Full Schedule Unavailable" message:@"The full schedule is not yet available, so you will need to edit the courses that are not full-year and set the right semester/trimester." delegate:self cancelButtonTitle:@"Edit Courses" otherButtonTitles:nil] show];
    } else {
        IHWScheduleViewController *svc = [[IHWScheduleViewController alloc] initWithNibName:@"IHWScheduleViewController" bundle:nil];
        [self.navigationController pushViewController:svc animated:YES];
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
