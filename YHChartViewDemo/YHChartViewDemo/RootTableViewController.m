//
//  RootTableViewController.m
//
//  Created by 杨虎 on 2018/1/18.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "RootTableViewController.h"
@interface RootTableViewController ()
@property (nonatomic, strong) NSArray *controllers;
@end

@implementation RootTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"RootViewController"];
    
}
- (NSArray *)controllers {
    if (!_controllers) {
        _controllers = @[@"LineChartViewController",@"HorizontalBarChartViewController",@"VerticalBarChartViewController"];
    }
    return _controllers;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.controllers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuseIdentifier"];
    }
    cell.textLabel.text = self.controllers[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Class cls = NSClassFromString(self.controllers[indexPath.row]);
    [self.navigationController pushViewController:[[cls alloc] init] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
