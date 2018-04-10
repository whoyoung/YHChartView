//
//  YHCommonHeader.h
//  YHDailyDemo
//
//  Created by 杨虎 on 2018/2/7.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#ifndef YHCommonHeader_h
#define YHCommonHeader_h

static const float TopEdge = 10;
static const float LeftEdge = 35;
static const float RightEdge = 10;
static const float BottomEdge = 20;
static const float AxistTextFont = 9;
static const float DataTextFont = 9;
static const float TipTextFont = 9;
static const float ReferenceLineWidth = 0.5;
static const float LoadAnimationTime = 0.5;
static const float BarAlpha = 0.9;
static const float TipViewPadding = 10;

#define ChartWidth (self.bounds.size.width - self.leftEdge - RightEdge)
#define ChartHeight (self.bounds.size.height - TopEdge - BottomEdge)
#define AxisTextColor [UIColor hexChangeFloat:@"8C8C8C"]
#define AxisScaleColor [UIColor hexChangeFloat:@"D9D9D9"]
#define DataTextColor [UIColor hexChangeFloat:@"8C8C8C"]
#define TipTextColor [UIColor whiteColor]
#define ZeroLineColor [UIColor hexChangeFloat:@"CCCCCC"]
#define AxisTextHeight (self.axisTextFontSize+4)

#import "UIColor+YHCategory.h"
#import "NSString+YHCategory.h"

#endif /* YHCommonHeader_h */
