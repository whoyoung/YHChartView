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

- (void)dealStyleDict:(NSDictionary *)styleDict {
    NSDictionary *barStyle = [styleDict objectForKey:@"barStyle"];
    self.minItemWidth =
    [barStyle objectForKey:@"minItemWidth"] ? [[barStyle objectForKey:@"minItemWidth"] floatValue] : 20;
    self.groupSpace = [barStyle objectForKey:@"groupSpace"] ? [[barStyle objectForKey:@"groupSpace"] floatValue] : 5;
    self.showAxisDashLine = [barStyle objectForKey:@"showAxisDashLine"] ? [[barStyle objectForKey:@"showAxisDashLine"] boolValue] : NO;
    self.showAxisHardLine = [barStyle objectForKey:@"showAxisHardLine"] ? [[barStyle objectForKey:@"showAxisHardLine"] boolValue] : NO;
    self.showDataDashLine = [barStyle objectForKey:@"showDataDashLine"] ? [[barStyle objectForKey:@"showDataDashLine"] boolValue] : NO;
    self.showDataHardLine = [barStyle objectForKey:@"showDataHardLine"] ? [[barStyle objectForKey:@"showDataHardLine"] boolValue] : YES;
}

- (CGSize)gestureScrollContentSize {
    return CGSizeMake(self.scrollContentSizeWidth, ChartHeight);
}

- (void)chartDidZooming:(UIPinchGestureRecognizer *)pinGesture {
    switch (pinGesture.state) {
        case UIGestureRecognizerStateBegan: {
            CGPoint pinCenterContainer = [pinGesture locationInView:self.containerView];
            self.pinCenterToLeftDistance = pinCenterContainer.x - LeftEdge;
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
    } else if (self.chartType == BarChartTypeSingle) {
        group = floorf(tapP.x / (self.zoomedItemAxis + self.groupSpace));
        item = 0;
    } else { // BarChartTypeStack
        group = floorf(tapP.x / (self.zoomedItemAxis + self.groupSpace));
        CGFloat tempY = self.zeroLine;
        for (NSUInteger i = 0; i < self.Datas.count; i++) {
            CGFloat h = [self dataAtGroup:group item:i] * self.dataItemUnitScale;
            if (tapP.y > self.zeroLine) {
                if (h < 0) {
                    if (tapP.y <= (tempY - h) || i == self.Datas.count - 1) {
                        item = i;
                        break;
                    } else {
                        tempY -= h;
                    }
                }
            } else {
                if (h >= 0) {
                    if (tapP.y >= (tempY - h) || i == self.Datas.count - 1) {
                        item = i;
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

- (void)calculateMaxAndMinValue {
    switch (self.chartType) {
        case BarChartTypeSingle: {
            if (self.beginGroupIndex == self.endGroupIndex) {
                self.minDataValue = [self dataAtGroup:self.beginGroupIndex item:0];
                self.maxDataValue = self.minDataValue;
            } else {
                NSMutableArray *array =
                    [NSMutableArray arrayWithCapacity:(self.endGroupIndex - self.beginGroupIndex + 1)];
                for (NSUInteger i = self.beginGroupIndex; i <= self.endGroupIndex; i++) {
                    [array addObject:[(NSArray *)self.Datas[0] objectAtIndex:i]];
                }
                self.minDataValue = [self verifyDataValue:array[0]];
                self.maxDataValue = self.minDataValue;
                [self findMaxAndMinValue:0 rightIndex:array.count - 1 compareA:array];
            }
        } break;
        case BarChartTypeStack: {
            if (self.beginGroupIndex == self.endGroupIndex) {
                self.minDataValue = 0;
                self.maxDataValue = 0;
                for (NSUInteger i = 0; i < self.Datas.count; i++) {
                    CGFloat y = [self dataAtGroup:self.beginGroupIndex item:i];
                    if (y < 0) {
                        self.minDataValue += y;
                    } else {
                        self.maxDataValue += y;
                    }
                }
            } else {
                NSMutableArray *minDataValues =
                    [NSMutableArray arrayWithCapacity:(self.endGroupIndex - self.beginGroupIndex + 1)];
                NSMutableArray *maxDataValues =
                    [NSMutableArray arrayWithCapacity:(self.endGroupIndex - self.beginGroupIndex + 1)];

                for (NSUInteger i = self.beginGroupIndex; i <= self.endGroupIndex; i++) {
                    CGFloat tempMinYValue = 0, tempMaxYValue = 0;
                    for (NSUInteger j = 0; j < self.Datas.count; j++) {
                        CGFloat y = [self dataAtGroup:i item:j];
                        if (y < 0) {
                            tempMinYValue += y;
                        } else {
                            tempMaxYValue += y;
                        }
                    }
                    [minDataValues addObject:[NSString stringWithFormat:@"%f", tempMinYValue]];
                    [maxDataValues addObject:[NSString stringWithFormat:@"%f", tempMaxYValue]];
                }
                self.minDataValue = [self verifyDataValue:minDataValues[0]];
                self.maxDataValue = [self verifyDataValue:maxDataValues[0]];
                for (NSString *value in minDataValues) {
                    self.minDataValue = MIN(self.minDataValue, [self verifyDataValue:value]);
                }
                for (NSString *value in maxDataValues) {
                    self.maxDataValue = MAX(self.maxDataValue, [self verifyDataValue:value]);
                }
            }
        } break;
        case BarChartTypeGroup: {
            if (self.beginGroupIndex == self.endGroupIndex) {
                if (self.beginItemIndex > self.endItemIndex) {
                    self.beginItemIndex = self.endItemIndex;
                }
                self.minDataValue = [self dataAtGroup:self.beginGroupIndex item:self.beginItemIndex];
                self.maxDataValue = self.minDataValue;
                for (NSUInteger i = self.beginItemIndex + 1; i <= self.endItemIndex; i++) {
                    CGFloat tempValue = [self dataAtGroup:self.beginGroupIndex item:i];
                    self.minDataValue = MIN(self.minDataValue, tempValue);
                    self.maxDataValue = MAX(self.maxDataValue, tempValue);
                }
            } else if (self.beginGroupIndex == self.endGroupIndex - 1) {
                self.minDataValue = [self dataAtGroup:self.beginGroupIndex item:self.beginItemIndex];
                self.maxDataValue = self.minDataValue;

                [self compareBeginAndEndItemValue:self.beginItemIndex + 1
                                          endItem:self.Datas.count - 1
                                     isBeginGroup:YES];
                [self compareBeginAndEndItemValue:0 endItem:self.endItemIndex isBeginGroup:NO];
            } else {
                self.minDataValue = [self dataAtGroup:self.beginGroupIndex item:self.beginItemIndex];
                self.maxDataValue = self.minDataValue;

                [self compareBeginAndEndItemValue:self.beginItemIndex + 1
                                          endItem:self.Datas.count - 1
                                     isBeginGroup:YES];
                [self compareBeginAndEndItemValue:0 endItem:self.endItemIndex isBeginGroup:NO];
                [self campareMaxAndMinValue:self.beginGroupIndex + 1 rightIndex:self.endGroupIndex - 1];
            }
        } break;

        default:
            break;
    }
}

- (CGFloat)dataItemUnitScale {
    return ChartHeight / (self.itemDataScale * (self.dataPostiveSegmentNum + self.dataNegativeSegmentNum));
}

- (void)drawDataPoint {
    UIView *subContainerV = [[UIView alloc] initWithFrame:CGRectMake(LeftEdge, TopEdge, ChartWidth, ChartHeight)];
    subContainerV.layer.masksToBounds = YES;
    [self.containerView addSubview:subContainerV];
    switch (self.chartType) {
        case BarChartTypeSingle: {
            NSArray *array = self.Datas[0];
            CGFloat offsetX = self.gestureScroll.contentOffset.x;
            for (NSUInteger i = self.beginGroupIndex; i <= self.endGroupIndex; i++) {
                CAShapeLayer *yValueLayer = [CAShapeLayer layer];
                CGFloat dataV = [self verifyDataValue:array[i]];
                CGFloat yPoint = self.zeroLine - dataV * self.dataItemUnitScale;
                if (dataV < 0) {
                    yPoint = self.zeroLine;
                }
                UIBezierPath *yValueBezier =
                    [UIBezierPath bezierPathWithRect:CGRectMake(i * (self.zoomedItemAxis + self.groupSpace) - offsetX,
                                                                yPoint, self.zoomedItemAxis,
                                                                fabs(dataV) * self.dataItemUnitScale)];
                yValueLayer.path = yValueBezier.CGPath;
                yValueLayer.lineWidth = 1;
                yValueLayer.strokeColor = [[UIColor hexChangeFloat:self.itemColors[0]] CGColor];
                yValueLayer.fillColor = [[UIColor hexChangeFloat:self.itemColors[0]] CGColor];
                [subContainerV.layer addSublayer:yValueLayer];
            }
        } break;
        case BarChartTypeStack: {
            CGFloat offsetX = self.gestureScroll.contentOffset.x;
            for (NSUInteger i = self.beginGroupIndex; i <= self.endGroupIndex; i++) {
                CGFloat positiveY = self.zeroLine, negativeY = self.zeroLine, yPoint = self.zeroLine;
                for (NSUInteger j = 0; j < self.Datas.count; j++) {
                    NSArray *array = self.Datas[j];
                    CGFloat dataV = [self verifyDataValue:array[i]];
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
                    yValueLayer.lineWidth = 1;
                    yValueLayer.strokeColor = [[UIColor hexChangeFloat:self.itemColors[j]] CGColor];
                    yValueLayer.fillColor = [[UIColor hexChangeFloat:self.itemColors[j]] CGColor];
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
            [self drawBeginAndEndItemLayer:0 rightIndex:rightLoopIndex isBegin:NO containerView:subContainerV];

            for (NSUInteger i = self.beginGroupIndex + 1; i < self.endGroupIndex; i++) {
                for (NSUInteger j = 0; j < self.Datas.count; j++) {
                    NSArray *array = self.Datas[j];
                    CGFloat dataV = [self verifyDataValue:array[i]];
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
                    yValueLayer.lineWidth = 1;
                    yValueLayer.strokeColor = [[UIColor hexChangeFloat:self.itemColors[j]] CGColor];
                    yValueLayer.fillColor = [[UIColor hexChangeFloat:self.itemColors[j]] CGColor];
                    [subContainerV.layer addSublayer:yValueLayer];
                }
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
        yValueLayer.lineWidth = 1;
        yValueLayer.strokeColor = [[UIColor hexChangeFloat:self.itemColors[i]] CGColor];
        yValueLayer.fillColor = [[UIColor hexChangeFloat:self.itemColors[i]] CGColor];
        [subContainerV.layer addSublayer:yValueLayer];
    }
}

- (void)addAxisLayer {
    CGFloat offsetX = self.gestureScroll.contentOffset.x;
    for (NSUInteger i = self.beginGroupIndex; i <= self.endGroupIndex; i++) {
        CGRect textFrame;
        if (self.chartType == BarChartTypeGroup) {
            if ((self.Datas.count * self.zoomedItemAxis + self.groupSpace) * (i + 0.5) - offsetX < 0) continue;
            textFrame =
                CGRectMake(LeftEdge + (self.Datas.count * self.zoomedItemAxis + self.groupSpace) * i - offsetX,
                           self.bounds.size.height - TextHeight, self.Datas.count * self.zoomedItemAxis, TextHeight);
        } else {
            if ((self.zoomedItemAxis + self.groupSpace) * (i + 0.5) - offsetX < 0) continue;
            textFrame = CGRectMake(LeftEdge + (self.zoomedItemAxis + self.groupSpace) * i - offsetX,
                                   self.bounds.size.height - TextHeight, self.zoomedItemAxis, TextHeight);
        }
        CATextLayer *text = [self getTextLayerWithString:self.AxisArray[i]
                                               textColor:AxisTextColor
                                                fontSize:AxistTextFont
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
    [xScaleBezier moveToPoint:CGPointMake(LeftEdge, self.bounds.size.height - BottomEdge)];
    [xScaleBezier addLineToPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height - BottomEdge)];
    xScaleLayer.path = xScaleBezier.CGPath;
    xScaleLayer.lineWidth = ReferenceLineWidth;
    xScaleLayer.strokeColor = AxisScaleColor.CGColor;
    xScaleLayer.fillColor = [UIColor clearColor].CGColor;
    [self.containerView.layer addSublayer:xScaleLayer];
}

- (void)addDataLayer {
    for (NSUInteger i = 0; i < self.dataNegativeSegmentNum; i++) {
        CGRect textFrame =
            CGRectMake(0, self.bounds.size.height - 1.5 * BottomEdge - i * [self axisUnitScale], TextWidth, BottomEdge);
        NSString *str =
            [NSString stringWithFormat:@"-%@", [self adjustScaleValue:(self.dataNegativeSegmentNum - i) * self.itemDataScale]];
        CATextLayer *text = [self getTextLayerWithString:str
                                               textColor:DataTextColor
                                                fontSize:DataTextFont
                                         backgroundColor:[UIColor clearColor]
                                                   frame:textFrame
                                           alignmentMode:kCAAlignmentRight];
        [self.containerView.layer addSublayer:text];
    }
    for (NSInteger i = 0; i <= self.dataPostiveSegmentNum; i++) {
        CGRect textFrame = CGRectMake(
            0, self.bounds.size.height - 1.5 * BottomEdge - (self.dataNegativeSegmentNum + i) * [self axisUnitScale],
            TextWidth, BottomEdge);
        NSString *str = [NSString stringWithFormat:@"%@", [self adjustScaleValue:i * self.itemDataScale]];
        CATextLayer *text = [self getTextLayerWithString:str
                                               textColor:DataTextColor
                                                fontSize:DataTextFont
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
        [yScaleBezier moveToPoint:CGPointMake(LeftEdge + 1, TopEdge)];
        [yScaleBezier addLineToPoint:CGPointMake(LeftEdge + 1, self.bounds.size.height - BottomEdge)];

        for (NSUInteger i = 0; i <= self.dataNegativeSegmentNum + self.dataPostiveSegmentNum + 1; i++) {
            [yScaleBezier moveToPoint:CGPointMake(LeftEdge - 5, TopEdge + i * [self axisUnitScale])];
            [yScaleBezier addLineToPoint:CGPointMake(LeftEdge, TopEdge + i * [self axisUnitScale])];
        }
        yScaleLayer.path = yScaleBezier.CGPath;
        yScaleLayer.lineWidth = ReferenceLineWidth;
        yScaleLayer.strokeColor = AxisScaleColor.CGColor;
        yScaleLayer.fillColor = [UIColor clearColor].CGColor;
        [self.containerView.layer addSublayer:yScaleLayer];
    }

    if (self.showDataDashLine || self.showDataHardLine) {
        CAShapeLayer *dashLineLayer = [CAShapeLayer layer];
        UIBezierPath *dashLineBezier = [UIBezierPath bezierPath];
        for (NSUInteger i = 0; i < self.dataNegativeSegmentNum + self.dataPostiveSegmentNum; i++) {
            [dashLineBezier moveToPoint:CGPointMake(LeftEdge, TopEdge + i * [self axisUnitScale])];
            [dashLineBezier addLineToPoint:CGPointMake(self.bounds.size.width, TopEdge + i * [self axisUnitScale])];
        }
        dashLineLayer.path = dashLineBezier.CGPath;
        if (self.showDataDashLine) {
            [dashLineLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:5],
                                                                        [NSNumber numberWithInt:5], nil]];
        }
        dashLineLayer.lineWidth = ReferenceLineWidth;
        dashLineLayer.strokeColor = AxisScaleColor.CGColor;
        dashLineLayer.fillColor = [UIColor clearColor].CGColor;
        [self.containerView.layer addSublayer:dashLineLayer];
    }
}

- (CGFloat)calculateItemAxisScale {
    if (self.itemAxisScale == 0) {
        if (self.chartType == BarChartTypeGroup) {
            CGFloat w =
                (ChartWidth - [self.Datas[0] count] * self.groupSpace) / [self.Datas[0] count] / self.Datas.count;
            self.itemAxisScale = w > self.minItemWidth ? w : self.minItemWidth;
        } else {
            self.itemAxisScale = (ChartWidth / [self.Datas[0] count] - self.groupSpace) > self.minItemWidth
                                 ? (ChartWidth / [self.Datas[0] count] - self.groupSpace)
                                 : self.minItemWidth;
        }
    }
    return self.itemAxisScale;
}

- (CGFloat)axisUnitScale {
    return ChartHeight / (self.dataNegativeSegmentNum + self.dataPostiveSegmentNum);
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
    (newFrame.size.width - LeftEdge - RightEdge) / (origionFrame.size.width - LeftEdge - RightEdge);
    
    if ([self gestureScrollContentSize].width < (newFrame.size.width - LeftEdge - RightEdge)) {
        if (self.chartType == BarChartTypeGroup) {
            self.oldPinScale *=
            ((newFrame.size.width - LeftEdge - RightEdge) / [self.Datas[0] count] - self.groupSpace) /
            self.Datas.count / self.itemAxisScale / self.oldPinScale;
        } else {
            self.oldPinScale *=
            ((newFrame.size.width - LeftEdge - RightEdge) / [self.Datas[0] count] - self.groupSpace) /
            self.itemAxisScale / self.oldPinScale;
        }
    }
}
@end
