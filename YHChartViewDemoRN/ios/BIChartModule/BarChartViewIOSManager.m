//
//  BarChartViewManager.m
//  ingage
//
//  Created by 杨虎 on 2018/2/2.
//  Copyright © 2018年 com. All rights reserved.
//

#import "BarChartViewIOSManager.h"
#import "XSYBarChartView.h"

@interface BarChartViewIOSManager ()
@end

@implementation BarChartViewIOSManager
RCT_EXPORT_MODULE()
RCT_EXPORT_VIEW_PROPERTY(data, NSString)
RCT_EXPORT_VIEW_PROPERTY(onSelect, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(hideTipView, BOOL)

- (UIView *)view {
    XSYBarChartView *barChart = [[XSYBarChartView alloc] init];
    return barChart;
}

@end
