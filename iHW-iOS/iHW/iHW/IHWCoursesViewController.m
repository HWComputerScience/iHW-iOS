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

@implementation IHWCoursesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.coursesTable.delegate = self;
    self.coursesTable.dataSource = self;
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
