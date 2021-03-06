//
//  XSYBarChartView.m
//  ingage
//
//  Created by 杨虎 on 2018/2/2.
//  Copyright © 2018年 com. All rights reserved.
//

#import "XSYBarChartView.h"
#import "YHHorizontalBarChartView.h"
#import "YHVerticalBarChartView.h"
@interface XSYBarChartView () <YHCommonChartViewDelegate>
@property (nonatomic, strong) NSDictionary *dataDict;
@property (nonatomic, assign) BOOL isHorizontal;
@property (nonatomic, strong) YHBaseChartView *chartView;
@property (nonatomic, copy) NSString *lastDataMd5;
@property (nonatomic, assign) BOOL shouldChangeConfigure;
@end

@implementation XSYBarChartView
- (void)setData:(NSString *)data {
    NSData *strData = [data dataUsingEncoding:NSUTF8StringEncoding];
    _dataDict = [NSJSONSerialization JSONObjectWithData:strData options:NSJSONReadingMutableLeaves error:nil];
    self.isHorizontal = [[_dataDict objectForKey:@"horizontal"] boolValue];
    NSString *md5 = [NSString md5:data];
    if (self.lastDataMd5 && ![self.lastDataMd5 isEqualToString:md5]) {
      _shouldChangeConfigure = YES;
      [self setNeedsLayout];
    }
    self.lastDataMd5 = md5;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    NSArray *subviews = self.subviews;
    BOOL isExisted = NO;
    for (UIView *view in subviews) {
        if (([view isKindOfClass:[YHHorizontalBarChartView class]] && self.isHorizontal) ||
            ([view isKindOfClass:[YHVerticalBarChartView class]] && !self.isHorizontal)) {
            isExisted = YES;
            if (self.shouldChangeConfigure) {
              self.shouldChangeConfigure = NO;
              [(YHBaseChartView *)view updateChartConfigure:self.dataDict frame:self.frame];
              break;
            }
            [(YHBaseChartView *)view updateChartFrame:self.frame];
            break;
        }
    }
    if (!isExisted) {
        if (self.isHorizontal) {
            _chartView = [[YHHorizontalBarChartView alloc] initWithFrame:self.bounds configure:self.dataDict];
        } else {
            _chartView = [[YHVerticalBarChartView alloc] initWithFrame:self.bounds configure:self.dataDict];
        }
        _chartView.delegate = self;
        [self addSubview:_chartView];
    }
}

- (void)didTapChart:(id)chart group:(NSUInteger)group item:(NSUInteger)item {
    if (self.onSelect) {
        self.onSelect(@{ @"groupIndex": @(item), @"x": @(group) });
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
