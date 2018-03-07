//
//  VerticalBarChartViewController.m
//
//  Created by 杨虎 on 2018/1/31.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "VerticalBarChartViewController.h"
#import "YHVerticalBarChartView.h"
@interface VerticalBarChartViewController ()

@end

@implementation VerticalBarChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDictionary *dict = @{
                           @"axis":@[@"Mon",@"Tues",@"Wed",@"Thu",@"Fri",@"Sat",@"Sun"],
                           @"datas":@[
                                   @[@"9883.6",[NSNull null],@"980.3",@"-3330.4",@"1340.5",@"330.6",[NSNull null]],
                                   @[@"2222",@"12533.6",[NSNull null],@"91.9",@"1066.12",@"250.13",@"-6033.14"]
                                   ],
                           @"groupMembers":@[@"zhang",@"yang"],
                           @"groupDimension":@"成交人",
                           @"axisTitle":@"星期",
                           @"dataTitle":@"成交量",
                           @"stack":@NO,
                           @"valueInterval": @"3",
                           @"referenceLineWidth": @2,
                           @"referenceLineColor": @"dddddd",
                           @"axisTextColor": @"000000",
                           @"dataTextColor": @"000000",
                           @"showLoadAnimation": @YES,
                           @"loadAnimationTime": @0.8,
                           @"animationType": @(YHAnimationTypeChangeValueAndNum),
                           @"styles": @{
                                   @"barStyle": @{
                                           @"minBarWidth":@"5",
                                           @"barGroupSpace":@"5"
                                           },
                                   @"lineStyle": @{
                                           @"lineWidth":@"1"
                                           }
                                   }
                           };
    self.chartView = [[YHVerticalBarChartView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64) configure:dict];
    self.chartView.delegate = self;
    [self.view addSubview:self.chartView];
}

@end
