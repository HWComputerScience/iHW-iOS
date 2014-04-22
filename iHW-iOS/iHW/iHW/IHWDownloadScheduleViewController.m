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
    self.webView.keyboardDisplayRequiresUserAction = NO;
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        self.topSpaceConstraint.constant = 0;
    }
    [self.webView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://www.hw.com/students/Login/tabid/2279/Default.aspx?returnurl=%2fstudents%2fSchoolResources%2fMyScheduleEvents.aspx"]]];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (IBAction)backPressed:(id)sender {
    if ([IHWCurriculum isFirstRun]) [self.navigationController popViewControllerAnimated:YES];
    else [self.navigationController setViewControllers:@[[[IHWScheduleViewController alloc] initWithNibName:@"IHWScheduleViewController" bundle:nil]] animated:YES];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    BOOL result = ([request.URL isEqual:[NSURL URLWithString:@"https://www.hw.com/students/Login/tabid/2279/Default.aspx?returnurl=%2fstudents%2fSchoolResources%2fMyScheduleEvents.aspx"]]
            || [request.URL isEqual:[NSURL URLWithString:@"http://www.hw.com/students/SchoolResources/MyScheduleEvents.aspx"]]
            || [request.URL isEqual:[NSURL URLWithString:@"https://www.hw.com/students/SchoolResources/MyScheduleEvents.aspx"]]);
    if (result)
        [(IHWAppDelegate *)[UIApplication sharedApplication].delegate performSelectorOnMainThread:@selector(showNetworkIcon) withObject:nil waitUntilDone:NO];
    return result;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [(IHWAppDelegate *)[UIApplication sharedApplication].delegate performSelectorOnMainThread:@selector(hideNetworkIcon) withObject:nil waitUntilDone:NO];
    NSURL *url = webView.request.mainDocumentURL;
    //NSLog(@"URL did finish load: %@", url.description);
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
    [(IHWAppDelegate *)[UIApplication sharedApplication].delegate performSelectorOnMainThread:@selector(hideNetworkIcon) withObject:nil waitUntilDone:NO];
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
    [(IHWAppDelegate *)[UIApplication sharedApplication].delegate performSelectorOnMainThread:@selector(showNetworkIcon) withObject:nil waitUntilDone:NO];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection self]; //to stop warnings
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.resultData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [(IHWAppDelegate *)[UIApplication sharedApplication].delegate performSelectorOnMainThread:@selector(hideNetworkIcon) withObject:nil waitUntilDone:NO];
    [[IHWCurriculum currentCurriculum] removeAllCourses];
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
            //NSLog(@"Welcome, %@", [[[div findChildTags:@"span"] objectAtIndex:0] contents]);
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
                if (![[IHWCurriculum currentCurriculum] addCourse:c]) NSLog(@"WARNING: Course Conflict!");
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
