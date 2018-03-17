//
//  XSYLineChartView.m
//  ingage
//
//  Created by 杨虎 on 2018/2/8.
//  Copyright © 2018年 com. All rights reserved.
//

#import "XSYLineChartView.h"
#import "YHLineChartView.h"
@interface XSYLineChartView () <YHCommonChartViewDelegate>
@property (nonatomic, strong) NSDictionary *dataDict;
@property (nonatomic, strong) YHLineChartView *chartView;
@end
@implementation XSYLineChartView
- (void)setData:(NSString *)data {
    NSData *strData = [data dataUsingEncoding:NSUTF8StringEncoding];
    _dataDict = [NSJSONSerialization JSONObjectWithData:strData options:NSJSONReadingMutableLeaves error:nil];
}
- (void)layoutSubviews {
    [super layoutSubviews];
    NSArray *subviews = self.subviews;
    BOOL isExisted = NO;
    for (UIView *view in subviews) {
        if ([view isKindOfClass:[YHLineChartView class]]) {
            isExisted = YES;
            [(YHLineChartView *)view updateChartFrame:self.frame];
            break;
        }
    }
    if (!isExisted) {
        _chartView = [[YHLineChartView alloc] initWithFrame:self.bounds configure:self.dataDict];
        _chartView.delegate = self;
        [self addSubview:_chartView];
    }
}

- (void)didTapChart:(id)chart group:(NSUInteger)group item:(NSUInteger)item {
    if (self.onSelect) {
        self.onSelect(@{ @"x": @(group), @"groupIndex": @(item) });
    }
}
- (void)setHideTipView:(BOOL)hide {
    if (self.chartView.hadTapped) {
        self.chartView.hadTapped = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.chartView removeTipView];
            [self.chartView removeSelectedLayer];
        });
    }
}
@end
