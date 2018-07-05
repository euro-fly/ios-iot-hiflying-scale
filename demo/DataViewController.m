//
//  DataViewController.m
//  Demo
//
//  Created by Jacob on 2018/07/04.
//  Copyright © 2018 Peter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataViewController.h"
#import "Demo-Swift.h"


@implementation DataViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [TCPHelper ReadData:[defaults objectForKey:@"macAddress"]];
    self.data = [defaults objectForKey:@"dataSet"];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myCell" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ %@", _data[indexPath.row][0], _data[indexPath.row][1], _data[indexPath.row][2]];
    return cell;
    
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}


@end

