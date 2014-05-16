//
//  IHWCoursesViewController.m
//  iHW
//
//  Created by Jonathan Burns on 8/12/13.
//  Copyright (c) 2013 Jonathan Burns. All rights reserved.
//

#import "IHWCoursesViewController.h"
#import "IHWCurriculum.h"
#import "IHWEditCourseViewController.h"
#import "IHWUtils.h"

//Basic, run-of-the-mill TableViewController with editing.
@implementation IHWCoursesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.coursesTable.delegate = self;
    self.coursesTable.dataSource = self;
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.6 green:0 blue:0 alpha:1];
    } else {
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.6 green:0 blue:0 alpha:1];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
        self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    self.courseNames = [[IHWCurriculum currentCurriculum] allCourseNames];
    [self.coursesTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)showNewCourseView {
    [self.navigationController pushViewController:[[IHWEditCourseViewController alloc] initWithCourse:nil] animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.courseNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"courseName"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"courseName"];
    }
    cell.textLabel.text = [self.courseNames objectAtIndex:indexPath.row];
    IHWCourse *c = [[IHWCurriculum currentCurriculum] courseAtIndex:indexPath.row];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Period %d (%@)", c.period, stringForTerm(c.term)];
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //[self.navigationController pushViewController:[[IHWEditCourseViewController alloc] initWithCourse:[[IHWCurriculum currentCurriculum] courseWithName:[self.courseNames objectAtIndex:indexPath.row]]] animated:YES];
    [self.navigationController pushViewController:[[IHWEditCourseViewController alloc] initWithCourse:[[IHWCurriculum currentCurriculum] courseAtIndex:indexPath.row]] animated:YES];
    return nil;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //IHWCourse *c = [[IHWCurriculum currentCurriculum] courseWithName:[self.courseNames objectAtIndex:indexPath.row]];
        IHWCourse *c = [[IHWCurriculum currentCurriculum] courseAtIndex:indexPath.row];
        [[IHWCurriculum currentCurriculum] removeCourse:c];
        [[IHWCurriculum currentCurriculum] saveCourses];
        self.courseNames = [[IHWCurriculum currentCurriculum] allCourseNames];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
