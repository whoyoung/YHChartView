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
static const float LeftEdge = 50;
static const float RightEdge = 10;
static const float BottomEdge = 20;
static const float TextHeight = 11;
static const float TextWidth = 45;
static const float AxistTextFont = 9;
static const float DataTextFont = 8;
static const float TipTextFont = 9;
static const float ReferenceLineWidth = 0.5;
static const float LoadAnimationTime = 0.5;
#define ChartWidth (self.bounds.size.width - LeftEdge - RightEdge)
#define ChartHeight (self.bounds.size.height - TopEdge - BottomEdge)
#define AxisTextColor [UIColor hexChangeFloat:@"8899A6"]
#define AxisScaleColor [UIColor hexChangeFloat:@"EEEEEE"]
#define DataTextColor [UIColor hexChangeFloat:@"8FA1B2"]
#define TipTextColor [UIColor whiteColor]

#import "UIColor+YHCategory.h"
#import "NSString+YHCategory.h"

#endif /* YHCommonHeader_h */
