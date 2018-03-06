//
//  YHBaseChartMethodProtocol.h
//
//  Created by 杨虎 on 2018/2/8.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YHBaseChartMethodProtocol <NSObject>
@required
- (id)initWithFrame:(CGRect)frame configure:(NSDictionary *)configureDict;

- (void)dealStyleDict:(NSDictionary *)styleDict;
- (CGSize)gestureScrollContentSize;
- (void)chartDidZooming:(UIPinchGestureRecognizer *)pinGesture;
- (NSDictionary *)tappedGroupAndItem:(CGPoint)tapP;
- (void)saveTapPointRatio:(CGPoint)tapP group:(NSUInteger)group item:(NSUInteger)item;
- (CGPoint)adjustTipViewLocation:(NSUInteger)group item:(NSUInteger)item;

- (void)findGroupAndItemIndex;
- (void)calculateMaxAndMinValue;
- (CGFloat)dataItemUnitScale;
- (void)addAxisLayer;
- (void)addAxisScaleLayer;
- (void)addDataLayer;
- (void)addDataScaleLayer;
- (void)drawDataPoint;

@optional
- (void)adjustScale:(CGRect)origionFrame newFrame:(CGRect)newFrame;
- (void)updateSelectedGroup:(NSUInteger)group item:(NSUInteger)item;
@end
