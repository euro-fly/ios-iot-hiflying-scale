//
//  DataViewController.h
//  Demo
//
//  Created by Jacob on 2018/07/04.
//  Copyright © 2018 Peter. All rights reserved.
//
#import <UIKit/UIKit.h>
@interface DataViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) NSMutableArray *data;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
