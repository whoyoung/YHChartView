//
//  YHBaseBarChartView.h
//  YHChartViewDemo
//
//  Created by 杨虎 on 2018/3/7.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YHBaseChartView.h"

typedef NS_ENUM(NSUInteger, BarChartType) {
    BarChartTypeSingle = 0, //单柱状图
    BarChartTypeGroup = 1, //分组柱状图
    BarChartTypeStack = 2 //堆叠图
    
};

@interface YHBaseBarChartView : YHBaseChartView
@property (nonatomic, assign, readonly) BarChartType chartType; //用于柱状图，柱状图类型：单柱状图、分组柱状图、堆叠图

@property (nonatomic, assign, readonly) CGFloat groupSpaceDivideBarWidth; //用于柱状图，分组间距与BarWidth的比例
@property (nonatomic, assign, readonly) CGFloat barColorAlpha; //用于柱状图，柱子颜色透明度
@property (nonatomic, assign, readonly) BOOL showBarGroupSeparateLine; //用于柱状图，显示两组柱子间的分割线
@property (nonatomic, assign, readonly) CGFloat separateLineDivideGroupSpace; //用于柱状图，若 分割线宽度/分组间距 > separateLineDivideGroupSpace ，则不绘制分割线
@property (nonatomic, assign, readonly) CGFloat seperateLineWidth; //用于柱状图，分割线宽度

- (CGFloat)groupSpace;
@end
