//
//  DirectionsTableViewController.m
//  Insight
//
//  Created by Krishna Bharathala on 11/8/15.
//  Copyright © 2015 Krishna Bharathala. All rights reserved.
//

#import "DirectionsTableViewController.h"

@interface DirectionsTableViewController ()

@end

@implementation DirectionsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"%@", self.directions);
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.bounces = NO;
    self.tableView.allowsSelection = NO;
    
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [self.view addGestureRecognizer:gr];
}

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.directions count]+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: cellIdentifier];
    
    if(indexPath.row == 0) {
        cell.textLabel.text = [NSString stringWithFormat: @"Directions to %@", self.destination];
    } else {
        NSString *direction = [[self.directions objectAtIndex:indexPath.row-1] objectForKey:@"text"];
        NSString *distance = [[self.directions objectAtIndex:indexPath.row-1] objectForKey:@"distance"];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.text = [NSString stringWithFormat: @"%@ -- %@", distance, direction];
    }

    return cell;
}


@end
