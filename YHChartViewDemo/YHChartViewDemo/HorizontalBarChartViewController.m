//
//  HorizontalBarChartViewController.m
//
//  Created by 杨虎 on 2018/1/30.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "HorizontalBarChartViewController.h"
#import "YHHorizontalBarChartView.h"
@interface HorizontalBarChartViewController ()
@end

@implementation HorizontalBarChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *dict = @{
                           @"axis":@[@"Mon",@"Tues",@"Wed",@"Thu",@"Fri",@"Sat",@"Sun"],
                           @"datas":@[
                                   @[@"9883.6",[NSNull null],@"980.3",@"-3330.4",[NSNull null],@"-330.6",@"4444"],
                                   @[[NSNull null],@"2222",@"12533.6",[NSNull null],@"-91.9",@"-1066.12",[NSNull null]],
                                   @[@"333",@"3332",[NSNull null],@"-1066.12",@"-166.12",[NSNull null],[NSNull null]]
                                   ],
                           @"groupMembers":@[@"zhang",@"yang",@"li"],
                           @"groupDimension":@"成交人",
                           @"axisTitle":@"星期",
                           @"dataTitle":@"成交量",
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
                                           @"stack": @YES
                               },
                               @"lineStyle": @{
                                   @"lineWidth":@"1"
                               }
                           }
                        };
    self.chartView = [[YHHorizontalBarChartView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64) configure:dict];
    self.chartView.delegate = self;
    [self.view addSubview:self.chartView];
}

@end
