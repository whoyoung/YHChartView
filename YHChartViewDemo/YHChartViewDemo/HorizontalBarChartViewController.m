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
                                     @[@"-9.6",[NSNull null],@"990.3",@"-0.4",@"10.5",@"0.6",@"-0.7"],
                                     @[@"0.5",@"125.6",@"-0.7",@"91.9",@"10.12",@"0.13",@"-0.14"]
                                    ],
                           @"groupMembers":@[@"zhang",@"yang"],
                           @"groupDimension":@"成交人",
                           @"axisTitle":@"星期",
                           @"dataTitle":@"成交量",
                           @"stack":@YES, 
                           @"valueInterval": @"3",
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
    self.chartView = [[YHHorizontalBarChartView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64) configure:dict];
    self.chartView.delegate = self;
    [self.view addSubview:self.chartView];
}

@end
