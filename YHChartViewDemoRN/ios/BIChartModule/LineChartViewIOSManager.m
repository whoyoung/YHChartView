//
//  LineChartViewIOSManager.m
//  ingage
//
//  Created by 杨虎 on 2018/2/8.
//  Copyright © 2018年 com. All rights reserved.
//

#import "LineChartViewIOSManager.h"
#import "XSYLineChartView.h"
@implementation LineChartViewIOSManager
RCT_EXPORT_MODULE()
RCT_EXPORT_VIEW_PROPERTY(data, NSString)
RCT_EXPORT_VIEW_PROPERTY(onSelect, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(hideTipView, BOOL)

- (UIView *)view {
    XSYLineChartView *excel = [[XSYLineChartView alloc] init];
    return excel;
}
@end
