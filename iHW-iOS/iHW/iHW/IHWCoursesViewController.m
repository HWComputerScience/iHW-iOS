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
}

- (void)showNewCourseView {
    [self.navigationController pushViewController:[[IHWEditCourseViewController alloc] initWithCourse:nil] animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.isEditing) return self.courseNames.count+1;
    else return self.courseNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"courseName"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"courseName"];
    }
    NSString *text;
    if (indexPath.row < self.courseNames.count) text = [self.courseNames objectAtIndex:indexPath.row];
    else text = @"Add a course";
    cell.textLabel.text = text;
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.navigationController pushViewController:[[IHWEditCourseViewController alloc] initWithCourse:[[IHWCurriculum currentCurriculum] courseWithName:[self.courseNames objectAtIndex:indexPath.row]]] animated:YES];
    return nil;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [tableView numberOfRowsInSection:indexPath.section]-1)return UITableViewCellEditingStyleDelete;
    else return UITableViewCellEditingStyleInsert;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
