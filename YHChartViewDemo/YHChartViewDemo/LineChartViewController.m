//
//  LineChartViewController.m
//
//  Created by 杨虎 on 2018/1/29.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "LineChartViewController.h"
#import "YHLineChartView.h"
@interface LineChartViewController ()

@end

@implementation LineChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDictionary *dict = @{
                           @"axis":@[@"Mon",@"Tues",@"Wed",@"Thu",@"Fri",@"Sat",@"Sun"],
                           @"datas":@[
                                   @[[NSNull null],@"40.2",@"11190.3",[NSNull null],@"10.5",@"380.6",@"-2220.7"],
                                   @[@"10.5",@"125.6",@"-670.7",@"91.9",@"510.12",@"220.13",@"-770.14"]
                                   ],
                           @"groupMembers":@[@"zhang",@"yang"],
                           @"groupDimension":@"成交人",
                           @"axisTitle":@"星期",
                           @"dataTitle":@"成交量",
                           @"valueInterval": @"3",
                           @"styles": @{
                                   @"lineStyle": @{
                                           @"lineWidth":@"1"
                                           }
                                   }
                           };
    self.chartView = [[YHLineChartView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64) configure:dict];
    self.chartView.delegate = self;
    [self.view addSubview:self.chartView];
}

@end
