//
//  YHBaseChartMethodProtocol.h
//
//  Created by 杨虎 on 2018/2/8.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YHBaseChartMethodProtocol <NSObject>
@required
- (id)initWithFrame:(CGRect)frame configure:(NSDictionary *)configureDict; //必须实现的初始化方法

- (void)dealStyleDict:(NSDictionary *)styleDict; //处理具体视图独有的样式
- (CGSize)gestureScrollContentSize; //
- (void)chartDidZooming:(UIPinchGestureRecognizer *)pinGesture; //视图正在缩放
- (NSDictionary *)tappedGroupAndItem:(CGPoint)tapP; //处理选中的信息
- (void)saveTapPointRatio:(CGPoint)tapP group:(NSUInteger)group item:(NSUInteger)item; //保存选中的信息
- (CGPoint)adjustTipViewLocation:(NSUInteger)group item:(NSUInteger)item; //

- (void)findGroupAndItemIndex; //寻找显示在屏幕上的第一个group和最后一个group，以及第一个group里显示出来的第一个item，和最后一个group里显示出来的最后一个item
- (void)calculateMaxAndMinValue; //寻找当前屏幕显示的数据的最大和最小值
- (CGFloat)dataItemUnitScale;
- (void)addAxisLayer; //绘制标题轴的文字
- (void)addAxisScaleLayer; //绘制标题轴线和每个标题的参考线
- (void)addDataLayer; //绘制数据轴的文字
- (void)addDataScaleLayer; //绘制数据轴线和每个数据段的参考线
- (void)drawDataPoint; //绘制数据点

@optional
- (void)adjustScale:(CGRect)origionFrame newFrame:(CGRect)newFrame; //处理横竖屏旋转时，处理视图的缩放倍率
- (void)updateSelectedGroup:(NSUInteger)group item:(NSUInteger)item; //更新点击的位置
@end
