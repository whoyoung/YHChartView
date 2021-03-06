//
//  YHHorizontalBarChartView.m
//  YHDailyDemo
//
//  Created by 杨虎 on 2018/1/30.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "YHHorizontalBarChartView.h"

@interface YHHorizontalBarChartView ()
@property (nonatomic, assign) CGFloat scrollContentSizeWidth;
@end

@implementation YHHorizontalBarChartView

- (CGSize)gestureScrollContentSize {
    return CGSizeMake(self.scrollContentSizeWidth, ChartHeight);
}

- (void)chartDidZooming:(UIPinchGestureRecognizer *)pinGesture {
    switch (pinGesture.state) {
        case UIGestureRecognizerStateBegan: {
            CGPoint pinCenterContainer = [pinGesture locationInView:self.containerView];
            self.pinCenterToLeftDistance = pinCenterContainer.x - self.leftEdge;
            CGPoint pinCenterScrollView = [pinGesture locationInView:self.gestureScroll];
            self.pinCenterRatio = pinCenterScrollView.x / self.gestureScroll.contentSize.width;
        } break;
        case UIGestureRecognizerStateChanged: {
            if (pinGesture.scale < 1) {
                CGFloat testZoomedWidth = 0;
                if (self.chartType == BarChartTypeGroup) {
                    testZoomedWidth = ([self.Datas count] * [self calculateItemAxisScale] * self.oldPinScale * pinGesture.scale +
                                       self.groupSpace) *
                                      [self.Datas[0] count];
                } else {
                    testZoomedWidth = ([self calculateItemAxisScale] * self.oldPinScale * pinGesture.scale + self.groupSpace) *
                                      [self.Datas[0] count];
                }
                if (testZoomedWidth < ChartWidth) {
                    if (self.chartType == BarChartTypeGroup) {
                        self.newPinScale = (ChartWidth / [self.Datas[0] count] - self.groupSpace) / self.Datas.count /
                                       [self calculateItemAxisScale] / self.oldPinScale;
                    } else {
                        self.newPinScale = (ChartWidth / [self.Datas[0] count] - self.groupSpace) / [self calculateItemAxisScale] /
                                       self.oldPinScale;
                    }
                } else {
                    self.newPinScale = pinGesture.scale;
                }
            } else {
                self.newPinScale = pinGesture.scale;
            }
            [self adjustScroll];
            [self redraw];
        } break;
        case UIGestureRecognizerStateEnded: {
            self.oldPinScale *= self.newPinScale;
            self.newPinScale = 1.0;
        } break;

        default:
            break;
    }
}

- (void)adjustScroll {
    self.gestureScroll.contentSize = CGSizeMake(self.scrollContentSizeWidth, ChartHeight);
    CGFloat offsetX = self.gestureScroll.contentSize.width * self.pinCenterRatio - self.pinCenterToLeftDistance;
    if (offsetX < 0) {
        offsetX = 0;
    }
    if (self.gestureScroll.contentSize.width > ChartWidth) {
        if (offsetX > self.gestureScroll.contentSize.width - ChartWidth) {
            offsetX = self.gestureScroll.contentSize.width - ChartWidth;
        }
    } else {
        offsetX = 0;
    }
    self.gestureScroll.contentOffset = CGPointMake(offsetX, 0);
}

- (NSDictionary *)tappedGroupAndItem:(CGPoint)tapP {
    NSUInteger group = 0, item = 0;
    if (self.chartType == BarChartTypeGroup) {
        group = floorf(tapP.x / (self.Datas.count * self.zoomedItemAxis + self.groupSpace));
        item =
        floorf((tapP.x - group * (self.Datas.count * self.zoomedItemAxis + self.groupSpace)) / self.zoomedItemAxis);
        if (item > self.Datas.count - 1) {
            item = self.Datas.count - 1;
        }
        if(![[self.Datas[item] objectAtIndex:group] respondsToSelector:@selector(floatValue)]) return nil;
    } else if (self.chartType == BarChartTypeSingle) {
        group = floorf(tapP.x / (self.zoomedItemAxis + self.groupSpace));
        item = 0;
        if(![[self.Datas[item] objectAtIndex:group] respondsToSelector:@selector(floatValue)]) return nil;
    } else { // BarChartTypeStack
        group = floorf(tapP.x / (self.zoomedItemAxis + self.groupSpace));
        
        for(NSUInteger i=0;i<self.Datas.count;) {
            if ([[self.Datas[i] objectAtIndex:group] respondsToSelector:@selector(floatValue)]) {
                item = i;
                break;
            }
            if (i == self.Datas.count - 1) return nil;
            i += 1;
        }
        
        CGFloat tempY = self.zeroLine;
        for (NSUInteger i = item; i < self.Datas.count; i++) {
            if (![[self.Datas[i] objectAtIndex:group] respondsToSelector:@selector(floatValue)]) continue;
            CGFloat h = [self dataAtGroup:group item:i] * self.dataItemUnitScale;
            if (tapP.y > self.zeroLine) {
                if (h < 0) {
                    item = i;
                    if (tapP.y <= (tempY - h) || i == self.Datas.count - 1) {
                        break;
                    } else {
                        tempY -= h;
                    }
                }
            } else {
                if (h >= 0) {
                    item = i;
                    if (tapP.y >= (tempY - h) || i == self.Datas.count - 1) {
                        break;
                    } else {
                        tempY -= h;
                    }
                }
            }
        }
    }
    
    return @{
             @"group":@(group),
             @"item":@(item)
             };

}
- (void)saveTapPointRatio:(CGPoint)tapP group:(NSUInteger)group item:(NSUInteger)item {
    CGFloat xRatio = 1.0, yRatio = 1.0;
    if (self.chartType == BarChartTypeStack) {
        xRatio = (tapP.x - group*(self.zoomedItemAxis + self.groupSpace))/self.zoomedItemAxis;
        xRatio = xRatio > 1 ? 1 : xRatio;
        CGFloat dataY = [self dataAtGroup:group item:item]*self.dataItemUnitScale;
        CGFloat difference = self.zeroLine;
        if (dataY >= 0) {
            for (NSUInteger i=0; i<item; i++) {
                if ([self dataAtGroup:group item:i] > 0) {
                    difference -= [self dataAtGroup:group item:i]*self.dataItemUnitScale;
                }
            }
        } else {
            for (NSUInteger i=0; i<item; i++) {
                if ([self dataAtGroup:group item:i] < 0) {
                    difference -= [self dataAtGroup:group item:i]*self.dataItemUnitScale;
                }
            }
        }
        yRatio = (difference - tapP.y)/dataY;
    } else {
        if (self.chartType == BarChartTypeGroup) {
            xRatio = (tapP.x - group*(self.Datas.count * self.zoomedItemAxis + self.groupSpace) - item*self.zoomedItemAxis)/self.zoomedItemAxis;
        } else {
            xRatio = (tapP.x - group*(self.zoomedItemAxis + self.groupSpace))/self.zoomedItemAxis;
        }
        xRatio = xRatio > 1 ? 1 : xRatio;
        CGFloat dataY = [self dataAtGroup:group item:item]*self.dataItemUnitScale;
        if (dataY > 0) {
            if (tapP.y > (self.zeroLine - dataY) && tapP.y < self.zeroLine) {
                yRatio = (self.zeroLine-tapP.y)/dataY;
            } else if (tapP.y >= self.zeroLine) {
                yRatio = 0;
            }
        } else {
            if (tapP.y <= (self.zeroLine - dataY) && tapP.y >= self.zeroLine) {
                yRatio = (tapP.y-self.zeroLine)/fabs(dataY);
            } else if (tapP.y < self.zeroLine) {
                yRatio = 0;
            }
        }
    }
    if (yRatio > 1) {
        yRatio = 1;
    } else if (yRatio < 0) {
        yRatio = 0;
    }
    self.pointRatio = YHTapPointRatioInItemMake(xRatio, yRatio);
}
- (CGPoint)adjustTipViewLocation:(NSUInteger)group item:(NSUInteger)item {
    CGFloat dataValue = [self dataAtGroup:group item:item];
    CGPoint tempP;
    if (self.chartType == BarChartTypeStack) {
        tempP =
        CGPointMake((self.zoomedItemAxis + self.groupSpace) * group + self.zoomedItemAxis * self.pointRatio.xRatio,
                    self.zeroLine);
        
        if (dataValue >= 0) {
            for (NSUInteger i = 0; i < item; i++) {
                if ([self dataAtGroup:group item:i] > 0) {
                    tempP.y -= [self dataAtGroup:group item:i] * self.dataItemUnitScale;
                }
            }
        } else {
            for (NSUInteger i = 0; i < item; i++) {
                if ([self dataAtGroup:group item:i] < 0) {
                    tempP.y -= [self dataAtGroup:group item:i] * self.dataItemUnitScale;
                }
            }
        }
    } else {
        tempP = CGPointMake((self.Datas.count * self.zoomedItemAxis + self.groupSpace) * group +
                            self.zoomedItemAxis * (self.pointRatio.xRatio + item),
                            self.zeroLine);
    }
    tempP.y -= dataValue * self.dataItemUnitScale * self.pointRatio.yRatio;
    tempP = [self.gestureScroll convertPoint:tempP toView:self.containerView];
    
    return tempP;
}

- (void)findGroupAndItemIndex {
    CGPoint offset = self.gestureScroll.contentOffset;
    if (self.chartType == BarChartTypeGroup) {
        self.beginGroupIndex = floor(offset.x / (self.zoomedItemAxis * self.Datas.count + self.groupSpace));
        CGFloat itemBeginOffsetX =
        offset.x - self.beginGroupIndex * (self.zoomedItemAxis * self.Datas.count + self.groupSpace);
        if (floor(itemBeginOffsetX / self.zoomedItemAxis) < self.Datas.count) {
            self.beginItemIndex = floor(itemBeginOffsetX / self.zoomedItemAxis);
        } else {
            self.beginItemIndex = self.Datas.count - 1;
        }
        
        self.endGroupIndex =
        floor((offset.x + ChartWidth) / (self.zoomedItemAxis * self.Datas.count + self.groupSpace));
        if (self.endGroupIndex >= [self.Datas[0] count]) {
            self.endGroupIndex = [self.Datas[0] count] - 1;
        }
        CGFloat itemEndOffsetX =
        offset.x + ChartWidth - self.endGroupIndex * (self.zoomedItemAxis * self.Datas.count + self.groupSpace);
        if (floor(itemEndOffsetX / self.zoomedItemAxis) < self.Datas.count) {
            self.endItemIndex = floor(itemEndOffsetX / self.zoomedItemAxis);
        } else {
            self.endItemIndex = self.Datas.count - 1;
        }
    } else {
        self.beginGroupIndex = floor(offset.x / (self.zoomedItemAxis + self.groupSpace));
        self.endGroupIndex = floor((offset.x + ChartWidth) / (self.zoomedItemAxis + self.groupSpace));
    }
}

- (CGFloat)dataItemUnitScale {
    if (self.itemDataScale == 0) return 0;
    return ChartHeight / (self.itemDataScale * (self.dataPostiveSegmentNum + self.dataNegativeSegmentNum));
}

- (void)drawDataPoint {
    UIView *subContainerV = [[UIView alloc] initWithFrame:CGRectMake(self.leftEdge, TopEdge, ChartWidth, ChartHeight)];
    subContainerV.layer.masksToBounds = YES;
    subContainerV.tag = 102;
    [self.containerView addSubview:subContainerV];
    [self drawGroupSeparateLine];
    
    NSUInteger drawNum = lroundf(self.endGroupIndex * self.dataNumFactor);
    switch (self.chartType) {
        case BarChartTypeSingle: {
            NSArray *array = self.Datas[0];
            CGFloat offsetX = self.gestureScroll.contentOffset.x;
            for (NSUInteger i = self.beginGroupIndex; i <= drawNum; i++) {
                CAShapeLayer *yValueLayer = [CAShapeLayer layer];
                CGFloat dataV = [self verifyDataValue:array[i]] * self.dataValueFactor;
                CGFloat yPoint = self.zeroLine - dataV * self.dataItemUnitScale;
                if (dataV < 0) {
                    yPoint = self.zeroLine;
                }
                UIBezierPath *yValueBezier =
                    [UIBezierPath bezierPathWithRect:CGRectMake(i * (self.zoomedItemAxis + self.groupSpace) - offsetX,
                                                                yPoint, self.zoomedItemAxis,
                                                                fabs(dataV) * self.dataItemUnitScale)];
                yValueLayer.path = yValueBezier.CGPath;
                yValueLayer.lineWidth = 0;
                yValueLayer.strokeColor = [[UIColor hexChangeFloat:self.itemColors[0] alpha:self.barColorAlpha] CGColor];
                yValueLayer.fillColor = [[UIColor hexChangeFloat:self.itemColors[0] alpha:self.barColorAlpha] CGColor];
                yValueLayer.name = [self layerTag:i item:0];
                [subContainerV.layer addSublayer:yValueLayer];
            }
        } break;
        case BarChartTypeStack: {
            CGFloat offsetX = self.gestureScroll.contentOffset.x;
            for (NSUInteger i = self.beginGroupIndex; i <= drawNum; i++) {
                CGFloat positiveY = self.zeroLine, negativeY = self.zeroLine, yPoint = self.zeroLine;
                for (NSUInteger j = 0; j < self.Datas.count; j++) {
                    NSArray *array = self.Datas[j];
                    if (![YHBaseChartView respondsFloatValueSelector:array[i]]) continue;
                    CGFloat dataV = [self verifyDataValue:array[i]] * self.dataValueFactor;
                    CAShapeLayer *yValueLayer = [CAShapeLayer layer];
                    if (dataV >= 0) {
                        positiveY -= dataV * self.dataItemUnitScale;
                        yPoint = positiveY;
                    }
                    if (dataV < 0 && 0 <= yPoint && yPoint < self.zeroLine) {
                        yPoint = self.zeroLine;
                    }
                    UIBezierPath *yValueBezier = [UIBezierPath
                        bezierPathWithRect:CGRectMake(i * (self.zoomedItemAxis + self.groupSpace) - offsetX, yPoint,
                                                      self.zoomedItemAxis,
                                                      fabs(dataV) * self.dataItemUnitScale)];
                    yValueLayer.path = yValueBezier.CGPath;
                    yValueLayer.lineWidth = 0;
                    yValueLayer.strokeColor = [[UIColor hexChangeFloat:self.itemColors[j] alpha:self.barColorAlpha] CGColor];
                    yValueLayer.fillColor = [[UIColor hexChangeFloat:self.itemColors[j] alpha:self.barColorAlpha] CGColor];
                    yValueLayer.name = [self layerTag:i item:j];
                    [subContainerV.layer addSublayer:yValueLayer];

                    if (dataV < 0) {
                        negativeY -= dataV * self.dataItemUnitScale;
                        yPoint = negativeY;
                    }
                }
            }
        } break;
        case BarChartTypeGroup: {
            CGFloat offsetX = self.gestureScroll.contentOffset.x;
            if (self.beginItemIndex >= self.Datas.count) break;
            NSUInteger rightLoopIndex = self.endItemIndex;
            if (self.endItemIndex >= self.Datas.count) {
                rightLoopIndex = self.Datas.count - 1;
            }
            if (self.beginGroupIndex == self.endGroupIndex) {
                if (self.beginItemIndex > self.endItemIndex) break;
                [self drawBeginAndEndItemLayer:self.beginItemIndex
                                    rightIndex:rightLoopIndex
                                       isBegin:YES
                                 containerView:subContainerV];
                break;
            }

            [self drawBeginAndEndItemLayer:self.beginItemIndex
                                rightIndex:self.Datas.count - 1
                                   isBegin:YES
                             containerView:subContainerV];

            for (NSUInteger i = self.beginGroupIndex + 1; i < drawNum; i++) {
                for (NSUInteger j = 0; j < self.Datas.count; j++) {
                    NSArray *array = self.Datas[j];
                    CGFloat dataV = [self verifyDataValue:array[i]] * self.dataValueFactor;
                    CAShapeLayer *yValueLayer = [CAShapeLayer layer];
                    CGFloat yPoint = self.zeroLine - dataV * self.dataItemUnitScale;
                    if (dataV < 0) {
                        yPoint = self.zeroLine;
                    }
                    UIBezierPath *yValueBezier = [UIBezierPath
                        bezierPathWithRect:CGRectMake(i * (self.zoomedItemAxis * self.Datas.count + self.groupSpace) +
                                                          j * self.zoomedItemAxis - offsetX,
                                                      yPoint, self.zoomedItemAxis,
                                                      fabs(dataV) * self.dataItemUnitScale)];
                    yValueLayer.path = yValueBezier.CGPath;
                    yValueLayer.lineWidth = 0;
                    yValueLayer.strokeColor = [[UIColor hexChangeFloat:self.itemColors[j] alpha:self.barColorAlpha] CGColor];
                    yValueLayer.fillColor = [[UIColor hexChangeFloat:self.itemColors[j] alpha:self.barColorAlpha] CGColor];
                    yValueLayer.name = [self layerTag:i item:j];
                    [subContainerV.layer addSublayer:yValueLayer];
                }
            }
            if(drawNum == self.endGroupIndex) {
                [self drawBeginAndEndItemLayer:0 rightIndex:rightLoopIndex isBegin:NO containerView:subContainerV];
            }
        } break;

        default:
            break;
    }
}
- (void)drawBeginAndEndItemLayer:(NSInteger)leftIndex
                      rightIndex:(NSInteger)rightIndex
                         isBegin:(BOOL)isBegin
                   containerView:(UIView *)subContainerV {
    CGFloat offsetX = self.gestureScroll.contentOffset.x;

    for (NSUInteger i = leftIndex; i <= rightIndex; i++) {
        NSArray *array = self.Datas[i];
        CAShapeLayer *yValueLayer = [CAShapeLayer layer];
        CGFloat itemValue = isBegin ? [self verifyDataValue:array[self.beginGroupIndex]] : [self verifyDataValue:array[self.endGroupIndex]];
        itemValue *= self.dataValueFactor;
        CGFloat yPoint = self.zeroLine - itemValue * self.dataItemUnitScale;
        if (itemValue < 0) {
            yPoint = self.zeroLine;
        }
        NSUInteger leftIndex = isBegin ? self.beginGroupIndex : self.endGroupIndex;
        CGFloat x =
            leftIndex * (self.zoomedItemAxis * self.Datas.count + self.groupSpace) + i * self.zoomedItemAxis - offsetX;
        UIBezierPath *yValueBezier = [UIBezierPath
            bezierPathWithRect:CGRectMake(x, yPoint, self.zoomedItemAxis, fabs(itemValue) * self.dataItemUnitScale)];
        yValueLayer.path = yValueBezier.CGPath;
        yValueLayer.lineWidth = 0;
        yValueLayer.strokeColor = [[UIColor hexChangeFloat:self.itemColors[i] alpha:self.barColorAlpha] CGColor];
        yValueLayer.fillColor = [[UIColor hexChangeFloat:self.itemColors[i] alpha:self.barColorAlpha] CGColor];
        yValueLayer.name = [self layerTag:leftIndex item:i];
        [subContainerV.layer addSublayer:yValueLayer];
    }
}

- (void)addAxisLayer {
    if ([self shouldHideAxisText]) return;
    CGFloat offsetX = self.gestureScroll.contentOffset.x;
    for (NSUInteger i = self.beginGroupIndex; i <= self.endGroupIndex; i++) {
        CGRect textFrame;
        if (self.chartType == BarChartTypeGroup) {
            if ((self.Datas.count * self.zoomedItemAxis + self.groupSpace) * (i + 0.5) - offsetX < 0) continue;
            textFrame =
                CGRectMake(self.leftEdge + (self.Datas.count * self.zoomedItemAxis + self.groupSpace) * i - offsetX,
                           self.bounds.size.height - self.axisTextFontSize-2, self.Datas.count * self.zoomedItemAxis, self.axisTextFontSize+1);
        } else {
            if ((self.zoomedItemAxis + self.groupSpace) * (i + 0.5) - offsetX < 0) continue;
            textFrame = CGRectMake(self.leftEdge + (self.zoomedItemAxis + self.groupSpace) * i - offsetX,
                                   self.bounds.size.height - self.axisTextFontSize-2, self.zoomedItemAxis, self.axisTextFontSize+1);
        }
        CATextLayer *text = [self getTextLayerWithString:self.AxisArray[i]
                                               textColor:self.dataTextColor
                                                fontSize:self.axisTextFontSize
                                         backgroundColor:[UIColor clearColor]
                                                   frame:textFrame
                                           alignmentMode:kCAAlignmentCenter];
        //        text.transform = CATransform3DMakeRotation(-M_PI_4/2,0,0,1);

        [self.containerView.layer addSublayer:text];
    }
}
- (void)addAxisScaleLayer {
    CAShapeLayer *xScaleLayer = [CAShapeLayer layer];
    UIBezierPath *xScaleBezier = [UIBezierPath bezierPath];
    [xScaleBezier moveToPoint:CGPointMake(self.leftEdge, self.bounds.size.height - BottomEdge)];
    [xScaleBezier addLineToPoint:CGPointMake(self.bounds.size.width-RightEdge, self.bounds.size.height - BottomEdge)];
    xScaleLayer.path = xScaleBezier.CGPath;
    xScaleLayer.lineWidth = self.referenceLineWidth;
    xScaleLayer.strokeColor = self.referenceLineColor.CGColor;
    xScaleLayer.fillColor = [UIColor clearColor].CGColor;
    [self.containerView.layer addSublayer:xScaleLayer];
}

- (void)addDataLayer {
    for (NSUInteger i = 0; i < self.dataNegativeSegmentNum; i++) {
        CGRect textFrame =
            CGRectMake(0, self.bounds.size.height - 1.5 * BottomEdge - i * [self axisUnitScale], self.leftEdge-5, BottomEdge);
        NSString *str =
            [NSString stringWithFormat:@"-%@", [self adjustScaleValue:(self.dataNegativeSegmentNum - i) * self.itemDataScale]];
        CATextLayer *text = [self getTextLayerWithString:str
                                               textColor:self.dataTextColor
                                                fontSize:self.dataTextFontSize
                                         backgroundColor:[UIColor clearColor]
                                                   frame:textFrame
                                           alignmentMode:kCAAlignmentRight];
        [self.containerView.layer addSublayer:text];
    }
    for (NSInteger i = 0; i <= self.dataPostiveSegmentNum; i++) {
        CGRect textFrame = CGRectMake(
            0, self.bounds.size.height - 1.5 * BottomEdge - (self.dataNegativeSegmentNum + i) * [self axisUnitScale],
            self.leftEdge-5, BottomEdge);
        NSString *str = [NSString stringWithFormat:@"%@", [self adjustScaleValue:i * self.itemDataScale]];
        CATextLayer *text = [self getTextLayerWithString:str
                                               textColor:self.dataTextColor
                                                fontSize:self.dataTextFontSize
                                         backgroundColor:[UIColor clearColor]
                                                   frame:textFrame
                                           alignmentMode:kCAAlignmentRight];
        [self.containerView.layer addSublayer:text];
    }
}

- (void)addDataScaleLayer {
    if (self.showDataEdgeLine) {
        CAShapeLayer *yScaleLayer = [CAShapeLayer layer];
        UIBezierPath *yScaleBezier = [UIBezierPath bezierPath];
        [yScaleBezier moveToPoint:CGPointMake(self.leftEdge + 1, TopEdge)];
        [yScaleBezier addLineToPoint:CGPointMake(self.leftEdge + 1, self.bounds.size.height - BottomEdge)];

        yScaleLayer.path = yScaleBezier.CGPath;
        yScaleLayer.lineWidth = self.referenceLineWidth;
        yScaleLayer.strokeColor = self.referenceLineColor.CGColor;
        yScaleLayer.fillColor = [UIColor clearColor].CGColor;
        [self.containerView.layer addSublayer:yScaleLayer];
    }

    if (self.showDataDashLine || self.showDataHardLine) {
        CAShapeLayer *dashLineLayer = [CAShapeLayer layer];
        UIBezierPath *dashLineBezier = [UIBezierPath bezierPath];
        for (NSUInteger i = 0; i < self.dataNegativeSegmentNum + self.dataPostiveSegmentNum; i++) {
            if (i == self.dataPostiveSegmentNum) continue;
            [dashLineBezier moveToPoint:CGPointMake(self.leftEdge, TopEdge + i * [self axisUnitScale])];
            [dashLineBezier addLineToPoint:CGPointMake(self.bounds.size.width-RightEdge, TopEdge + i * [self axisUnitScale])];
        }
        dashLineLayer.path = dashLineBezier.CGPath;
        if (self.showDataDashLine) {
            [dashLineLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:5],
                                                                        [NSNumber numberWithInt:5], nil]];
        }
        dashLineLayer.lineWidth = self.referenceLineWidth;
        dashLineLayer.strokeColor = self.referenceLineColor.CGColor;
        dashLineLayer.fillColor = [UIColor clearColor].CGColor;
        [self.containerView.layer addSublayer:dashLineLayer];
        
        CAShapeLayer *zeroLineLayer = [CAShapeLayer layer];
        UIBezierPath *zeroLineBezier = [UIBezierPath bezierPath];
        [zeroLineBezier moveToPoint:CGPointMake(self.leftEdge, TopEdge + self.dataPostiveSegmentNum * [self axisUnitScale])];
        [zeroLineBezier addLineToPoint:CGPointMake(self.bounds.size.width-RightEdge, TopEdge + self.dataPostiveSegmentNum * [self axisUnitScale])];
        zeroLineLayer.lineWidth = self.referenceLineWidth*2;
        zeroLineLayer.strokeColor = ZeroLineColor.CGColor;
        zeroLineLayer.path = zeroLineBezier.CGPath;
        if (self.showDataDashLine) {
            [zeroLineLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:5], [NSNumber numberWithInt:5], nil]];
        }
        zeroLineLayer.fillColor = [UIColor clearColor].CGColor;
        [self.containerView.layer addSublayer:zeroLineLayer];
    }
}

- (CGFloat)calculateItemAxisScale {
    if (self.itemAxisScale == 0) {
        if (self.chartType == BarChartTypeGroup) {
            CGFloat w =
                ChartWidth / [self.Datas[0] count] / (self.Datas.count + self.groupSpaceDivideBarWidth);
            self.itemAxisScale = w > self.minItemWidth ? w : self.minItemWidth;
        } else {
            self.itemAxisScale = ChartWidth / [self.Datas[0] count] /(1+self.groupSpaceDivideBarWidth) > self.minItemWidth
                                 ? ChartWidth / [self.Datas[0] count] / (1+self.groupSpaceDivideBarWidth) : self.minItemWidth;
        }
    }
    return self.itemAxisScale;
}

- (CGFloat)scrollContentSizeWidth {
    if (self.chartType == BarChartTypeGroup) {
        return (self.Datas.count * self.zoomedItemAxis + self.groupSpace) * [self.Datas[0] count];
    }
    return (self.zoomedItemAxis + self.groupSpace) * [self.Datas[0] count];
}
- (CGFloat)zeroLine {
    return self.dataPostiveSegmentNum * [self axisUnitScale];
}
- (void)adjustScale:(CGRect)origionFrame newFrame:(CGRect)newFrame {
    self.itemAxisScale *=
    (newFrame.size.width - self.leftEdge - RightEdge) / (origionFrame.size.width - self.leftEdge - RightEdge);
    
    if ([self gestureScrollContentSize].width < (newFrame.size.width - self.leftEdge - RightEdge)) {
        if (self.chartType == BarChartTypeGroup) {
            self.oldPinScale *=
            ((newFrame.size.width - self.leftEdge - RightEdge) / [self.Datas[0] count] - self.groupSpace) /
            self.Datas.count / self.itemAxisScale / self.oldPinScale;
        } else {
            self.oldPinScale *=
            ((newFrame.size.width - self.leftEdge - RightEdge) / [self.Datas[0] count] - self.groupSpace) /
            self.itemAxisScale / self.oldPinScale;
        }
    }
}

- (void)drawGroupSeparateLine {
    if (self.showBarGroupSeparateLine && self.chartType == BarChartTypeGroup && self.seperateLineWidth/self.groupSpace <= self.separateLineDivideGroupSpace) {
        UIView *subContainer = [self.containerView viewWithTag:102];
        CGFloat groupWidth = self.groupSpace + self.Datas.count * self.zoomedItemAxis;
        CGFloat offsetX = self.gestureScroll.contentOffset.x;
        for (NSUInteger i=self.beginGroupIndex; i<self.endGroupIndex; i++) {
            CAShapeLayer *separateLine = [CAShapeLayer layer];
            UIBezierPath *bezier = [UIBezierPath bezierPath];
            CGFloat x = (i+1)*groupWidth-self.groupSpace/2.0-self.seperateLineWidth/2.0 - offsetX;
            [bezier moveToPoint:CGPointMake(x, 0)];
            [bezier addLineToPoint:CGPointMake(x, ChartHeight)];
            separateLine.lineWidth = self.seperateLineWidth;
            separateLine.fillColor = self.referenceLineColor.CGColor;
            separateLine.strokeColor = self.referenceLineColor.CGColor;
            separateLine.path = bezier.CGPath;
            [separateLine setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:5],[NSNumber numberWithInt:5], nil]];
            [subContainer.layer addSublayer:separateLine];
        }
    }
}

@end
