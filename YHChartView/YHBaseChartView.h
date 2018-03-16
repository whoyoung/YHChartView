//
//  YHBaseChartView.h
//
//  Created by 杨虎 on 2018/2/2.
//  Copyright © 2018年 杨虎. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "YHBaseChartMethodProtocol.h"
#import "YHCommonChartViewDelegate.h"
#import "YHCommonHeader.h"

typedef NS_ENUM(NSUInteger, YHAnimationType) {
    YHAnimationTypeChangeValue = 0, //数据轴延展
    YHAnimationTypeChangeNum = 1, //标题轴延展
    YHAnimationTypeChangeValueAndNum = 2 //数据轴和标题轴同步延展
    
};

typedef struct YHTapPointRatioInItem {
    CGFloat xRatio;
    CGFloat yRatio;
} YHTapPointRatioInItem;

CG_INLINE YHTapPointRatioInItem
YHTapPointRatioInItemMake(CGFloat x, CGFloat y) {
    YHTapPointRatioInItem pointRatio; pointRatio.xRatio = x; pointRatio.yRatio = y; return pointRatio;
}

@interface YHBaseChartView : UIView <YHBaseChartMethodProtocol>

@property (nonatomic, weak) id<YHCommonChartViewDelegate> delegate;
@property (nonatomic, weak) UIScrollView *gestureScroll; //置于chartView的最顶层，用于处理滚动、缩放、点击事件
@property (nonatomic, strong, readonly) UIView *containerView; //绘图区域

@property (nonatomic, strong, readonly) NSMutableArray<NSString *> *AxisArray; //坐标轴标题数组
@property (nonatomic, strong, readonly) NSArray<NSArray *> *Datas; //坐标轴数据数组，是一个二维数组
@property (nonatomic, strong, readonly) NSArray *groupMembers; //分组成员
@property (nonatomic, copy, readonly) NSString *groupDimension; //分组维度，用于点击弹窗视图的信息展示
@property (nonatomic, copy, readonly) NSString *axisTitle; //标题轴的标题，用于点击弹窗视图的信息展示
@property (nonatomic, copy, readonly) NSString *dataTitle; //数据轴的标题，用于点击弹窗视图的信息展示
@property (nonatomic, strong, readonly) NSArray *itemColors; //用于区分分组内成员的颜色数组
@property (nonatomic, assign, readonly) NSUInteger valueInterval; //坐标轴正轴或负轴刻度线的最大条数

@property (nonatomic, assign, readonly) NSUInteger dataPostiveSegmentNum; //坐标轴正轴刻度线条数
@property (nonatomic, assign, readonly) NSUInteger dataNegativeSegmentNum; //坐标轴负轴刻度线条数
@property (nonatomic, assign, readonly) CGFloat dataItemUnitScale;
@property (nonatomic, assign, readonly) CGFloat zoomedItemAxis;
@property (nonatomic, assign, readonly) CGFloat zeroLine;

@property (nonatomic, assign, readonly) CGFloat minItemWidth; //以柱状图为例：每个柱子的宽度小于minItemWidth时，便不可继续缩小
@property (nonatomic, assign, readonly) BOOL showDataDashLine; //显示数据轴实线刻度线
@property (nonatomic, assign, readonly) BOOL showDataHardLine; //显示数据轴虚线刻度线
@property (nonatomic, assign, readonly) BOOL showAxisDashLine; //显示标题轴实线分组线
@property (nonatomic, assign, readonly) BOOL showAxisHardLine; //显示标题轴虚线分组线
@property (nonatomic, assign, readonly) BOOL showDataEdgeLine; //显示数据轴最边沿的短刻度线

@property (nonatomic, assign) NSInteger beginGroupIndex; //视图中显示的第一个分组的index
@property (nonatomic, assign) NSInteger endGroupIndex; //视图中显示的最后一个分组的index
@property (nonatomic, assign) NSInteger beginItemIndex; //beginGroupIndex中显示的第一个item的index
@property (nonatomic, assign) NSInteger endItemIndex; //endGroupIndex中显示的最后一个item的index
@property (nonatomic, assign) CGFloat itemAxisScale; //
@property (nonatomic, assign) NSUInteger itemDataScale; //
@property (nonatomic, assign) CGFloat maxDataValue; //数值数组中的最大值
@property (nonatomic, assign) CGFloat minDataValue; //数值数组中的最小值

@property (nonatomic, assign) CGFloat oldPinScale; //上一次缩放的倍率
@property (nonatomic, assign) CGFloat newPinScale; //在上一次缩放倍率的基础上，再次缩放的倍率
@property (nonatomic, assign) CGFloat pinCenterToLeftDistance; //缩放中心点距数据轴左边沿的距离
@property (nonatomic, assign) CGFloat pinCenterRatio; //缩放中心点在gestureScroll.contentSize中的比例
@property (nonatomic, assign) YHTapPointRatioInItem pointRatio; //点击的点在选中的item中的相对位置比例
@property (nonatomic, assign) BOOL hadTapped; //用于判断是否需要清除选中状态
@property (nonatomic, assign, readonly) NSUInteger tappedGroup; //点击的点所在的group
@property (nonatomic, assign, readonly) NSUInteger tappedItem; //点击的点所在的item
@property (nonatomic, assign, readonly) CGFloat referenceLineWidth; //各种辅助线的宽度
@property (nonatomic, strong, readonly) UIColor *referenceLineColor; //各种辅助线的颜色
@property (nonatomic, strong, readonly) UIColor *axisTextColor; //标题轴文字的颜色
@property (nonatomic, strong, readonly) UIColor *dataTextColor; //数据轴文字的颜色
@property (nonatomic, assign, readonly) CGFloat axisTextFontSize; //标题轴文字的大小
@property (nonatomic, assign, readonly) CGFloat dataTextFontSize; //数据轴文字的大小

@property (nonatomic, assign, readonly) BOOL showLoadAnimation; //显示首次加载视图动画
@property (nonatomic, assign, readonly) CGFloat loadAnimationTime; //首次加载视图动画
@property (nonatomic, assign, readonly) CGFloat dataNumFactor; //标题轴延展动画因子
@property (nonatomic, assign, readonly) CGFloat dataValueFactor; //数据轴延展动画因子
@property (nonatomic, assign, readonly) YHAnimationType animationType; //加载动画类型：数据轴延展、标题轴延展、数据轴和标题轴同步延展

@property (nonatomic, assign, readonly) BOOL showTipViewArrow; //显示tipview的箭头
@property (nonatomic, assign, readonly) CGFloat minWidthHideAxisText; //若 每组item的宽度 < minWidthHideAxisText, 则不绘制坐标轴文本

- (void)redraw; //重新绘制
- (void)compareBeginAndEndItemValue:(NSUInteger)beginItem endItem:(NSUInteger)endItem isBeginGroup:(BOOL)isBeginGroup;
- (void)campareMaxAndMinValue:(NSUInteger)leftIndex rightIndex:(NSUInteger)rightIndex;
- (void)findMaxAndMinValue:(NSUInteger)leftIndex rightIndex:(NSUInteger)rightIndex compareA:(NSArray *)compareA;
- (NSString *)adjustScaleValue:(NSUInteger)scaleValue; //将数据转换成有单位的数据
- (CATextLayer *)getTextLayerWithString:(NSString *)text
                              textColor:(UIColor *)textColor
                               fontSize:(NSInteger)fontSize
                        backgroundColor:(UIColor *)bgColor
                                  frame:(CGRect)frame
                          alignmentMode:(NSString *)alignmentMode; //绘制文本
- (CGFloat)zoomedItemAxis;
- (void)removeTipView;
- (void)removeSelectedLayer;
- (void)updateChartFrame:(CGRect)frame; //更新图表的frame，可用于屏幕旋转等情形
- (CGFloat)dataAtGroup:(NSUInteger)group item:(NSUInteger)item;
- (CGFloat)verifyDataValue:(id)value;
- (NSArray *)defaultColors; //默认的分组内成员的颜色数组
- (NSString *)layerTag:(NSUInteger)group item:(NSUInteger)item;
- (BOOL)shouldHideAxisText;
- (CGFloat)axisUnitScale;
+ (BOOL)respondsFloatValueSelector:(id)idValue;
@end
