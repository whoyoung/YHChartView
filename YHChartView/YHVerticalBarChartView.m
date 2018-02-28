//
//  YHVerticalBarChartView.m
//  YHDailyDemo
//
//  Created by 杨虎 on 2018/1/31.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "YHVerticalBarChartView.h"

@interface YHVerticalBarChartView()
@property (nonatomic, assign) CGFloat scrollContentSizeHeight;
@property (nonatomic, assign) CGFloat pinCenterToTopDistance;

@end

@implementation YHVerticalBarChartView

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
    return CGSizeMake(ChartWidth, self.scrollContentSizeHeight);
}

- (void)chartDidZooming:(UIPinchGestureRecognizer *)pinGesture {
    switch (pinGesture.state) {
        case UIGestureRecognizerStateBegan: {
            CGPoint pinCenterContainer = [pinGesture locationInView:self.containerView];
            self.pinCenterToTopDistance = pinCenterContainer.x - TopEdge;
            CGPoint pinCenterScrollView = [pinGesture locationInView:self.gestureScroll];
            self.pinCenterRatio = pinCenterScrollView.y/self.gestureScroll.contentSize.height;
        }
            break;
        case UIGestureRecognizerStateChanged: {
            if (pinGesture.scale < 1){
                CGFloat testZoomedHeight = 0;
                if (self.chartType == BarChartTypeGroup) {
                    testZoomedHeight = ([self.Datas count]*[self calculateItemAxisScale]*self.oldPinScale*pinGesture.scale + self.groupSpace) * [self.Datas[0] count];
                } else {
                    testZoomedHeight = ([self calculateItemAxisScale]*self.oldPinScale*pinGesture.scale + self.groupSpace) * [self.Datas[0] count];
                }
                if (testZoomedHeight < ChartHeight) {
                    if (self.chartType == BarChartTypeGroup) {
                        self.newPinScale = (ChartHeight/[self.Datas[0] count] - self.groupSpace)/self.Datas.count/[self calculateItemAxisScale]/self.oldPinScale;
                    } else {
                        self.newPinScale = (ChartHeight/[self.Datas[0] count] - self.groupSpace)/[self calculateItemAxisScale]/self.oldPinScale;
                    }
                } else {
                    self.newPinScale = pinGesture.scale;
                }
            } else {
                self.newPinScale = pinGesture.scale;
            }
            [self adjustScroll];
            [self redraw];
        }
            break;
        case UIGestureRecognizerStateEnded: {
            self.oldPinScale *= self.newPinScale;
            self.newPinScale = 1.0;
        }
            break;
            
        default:
            break;
    }
}
- (void)adjustScroll {
    self.gestureScroll.contentSize = CGSizeMake(ChartWidth, self.scrollContentSizeHeight);
    CGFloat offsetY = self.gestureScroll.contentSize.height * self.pinCenterRatio - self.pinCenterToTopDistance;
    if (offsetY < 0) {
        offsetY = 0;
    }
    if (self.gestureScroll.contentSize.height > ChartHeight) {
        if (offsetY > self.gestureScroll.contentSize.height - ChartHeight) {
            offsetY = self.gestureScroll.contentSize.height - ChartHeight;
        }
    } else {
        offsetY = 0;
    }
    self.gestureScroll.contentOffset = CGPointMake(0, offsetY);
}

- (NSDictionary *)tappedGroupAndItem:(CGPoint)tapP {
    NSUInteger group = 0, item = 0;
    if (self.chartType == BarChartTypeGroup) {
        group = floorf(tapP.y / (self.Datas.count * self.zoomedItemAxis + self.groupSpace));
        item =
        floorf((tapP.y - group * (self.Datas.count * self.zoomedItemAxis + self.groupSpace)) / self.zoomedItemAxis);
        if (item > self.Datas.count - 1) {
            item = self.Datas.count - 1;
        }
    } else if (self.chartType == BarChartTypeSingle) {
        group = floorf(tapP.y / (self.zoomedItemAxis + self.groupSpace));
        item = 0;
    } else { // BarChartTypeStack
        group = floorf(tapP.y / (self.zoomedItemAxis + self.groupSpace));
        CGFloat tempX = self.zeroLine;
        for (NSUInteger i = 0; i < self.Datas.count; i++) {
            CGFloat w = [self dataAtGroup:group item:i] * self.dataItemUnitScale;
            if (tapP.x < self.zeroLine) {
                if (w < 0) {
                    if (tapP.x >= (tempX + w) || i == self.Datas.count - 1) {
                        item = i;
                        break;
                    } else {
                        tempX += w;
                    }
                }
            } else {
                if (w >= 0) {
                    if (tapP.x <= (tempX + w) || i == self.Datas.count - 1) {
                        item = i;
                        break;
                    } else {
                        tempX += w;
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
        yRatio = (tapP.y - group*(self.zoomedItemAxis + self.groupSpace))/self.zoomedItemAxis;
        yRatio = yRatio > 1 ? 1 : yRatio;
        CGFloat dataX = [self dataAtGroup:group item:item]*self.dataItemUnitScale;
        CGFloat difference = self.zeroLine;
        if (dataX >= 0) {
            for (NSUInteger i=0; i<item; i++) {
                if ([self dataAtGroup:group item:i] > 0) {
                    difference += [self dataAtGroup:group item:i]*self.dataItemUnitScale;
                }
            }
            xRatio = (tapP.x-difference)/dataX;
        } else {
            for (NSUInteger i=0; i<item; i++) {
                if ([self dataAtGroup:group item:i] < 0) {
                    difference += [self dataAtGroup:group item:i]*self.dataItemUnitScale;
                }
            }
            xRatio = (difference - tapP.x)/fabs(dataX);
        }
    } else {
        if (self.chartType == BarChartTypeGroup) {
            yRatio = (tapP.y - group*(self.Datas.count * self.zoomedItemAxis + self.groupSpace) - item*self.zoomedItemAxis)/self.zoomedItemAxis;
        } else {
            yRatio = (tapP.y - group*(self.zoomedItemAxis + self.groupSpace))/self.zoomedItemAxis;
        }
        yRatio = yRatio > 1 ? 1 : yRatio;
        CGFloat dataX = [self dataAtGroup:group item:item]*self.dataItemUnitScale;
        if (dataX > 0) {
            if (tapP.x < (dataX+self.zeroLine) && tapP.x > self.zeroLine) {
                xRatio = (tapP.x - self.zeroLine)/dataX;
            } else if (tapP.x <= self.zeroLine) {
                xRatio = 0;
            }
        } else {
            if (tapP.x >= (dataX+self.zeroLine) && tapP.x < self.zeroLine) {
                xRatio = (self.zeroLine-tapP.x)/fabs(dataX);
            } else if (tapP.x >= self.zeroLine) {
                xRatio = 0;
            }
        }
    }
    if (xRatio > 1) {
        xRatio = 1;
    } else if (xRatio < 0) {
        xRatio = 0;
    }
    self.pointRatio = YHTapPointRatioInItemMake(xRatio, yRatio);
}
- (CGPoint)adjustTipViewLocation:(NSUInteger)group item:(NSUInteger)item {
    CGFloat dataValue = [self dataAtGroup:group item:item] * self.dataItemUnitScale;
    CGPoint tempP;
    if (self.chartType == BarChartTypeStack) {
        tempP = CGPointMake(self.zeroLine, (self.zoomedItemAxis + self.groupSpace) * group +
                            self.zoomedItemAxis * self.pointRatio.yRatio);
        if (dataValue >= 0) {
            for (NSUInteger i = 0; i < item; i++) {
                if ([self dataAtGroup:group item:i] > 0) {
                    tempP.x += [self dataAtGroup:group item:i] * self.dataItemUnitScale;
                }
            }
        } else {
            for (NSUInteger i = 0; i < item; i++) {
                if ([self dataAtGroup:group item:i] < 0) {
                    tempP.x += [self dataAtGroup:group item:i] * self.dataItemUnitScale;
                }
            }
        }
    } else {
        tempP = CGPointMake(self.zeroLine, (self.Datas.count * self.zoomedItemAxis + self.groupSpace) * group +
                            self.zoomedItemAxis * (self.pointRatio.yRatio + item));
    }
    tempP.x += dataValue * self.pointRatio.xRatio;
    tempP = [self.gestureScroll convertPoint:tempP toView:self.containerView];
    return tempP;
}

- (void)findGroupAndItemIndex {
    CGPoint offset = self.gestureScroll.contentOffset;
    if (self.chartType == BarChartTypeGroup) {
        self.beginGroupIndex = floor(offset.y/(self.zoomedItemAxis*self.Datas.count + self.groupSpace));
        CGFloat itemBeginOffsetY = offset.y - self.beginGroupIndex * (self.zoomedItemAxis*self.Datas.count + self.groupSpace);
        if (floor(itemBeginOffsetY/self.zoomedItemAxis) < self.Datas.count) {
            self.beginItemIndex = floor(itemBeginOffsetY/self.zoomedItemAxis);
        } else {
            self.beginItemIndex = self.Datas.count - 1;
        }
        
        self.endGroupIndex = floor((offset.y+ChartHeight)/(self.zoomedItemAxis*self.Datas.count + self.groupSpace));
        if (self.endGroupIndex >= [self.Datas[0] count]) {
            self.endGroupIndex = [self.Datas[0] count] - 1;
        }
        CGFloat itemEndOffsetY = offset.y+ChartHeight - self.endGroupIndex * (self.zoomedItemAxis*self.Datas.count + self.groupSpace);
        if (floor(itemEndOffsetY/self.zoomedItemAxis) < self.Datas.count) {
            self.endItemIndex = floor(itemEndOffsetY/self.zoomedItemAxis);
        } else {
            self.endItemIndex = self.Datas.count - 1;
        }
    } else {
        self.beginGroupIndex = floor(offset.y/(self.zoomedItemAxis + self.groupSpace));
        self.endGroupIndex = floor((offset.y+ChartHeight)/(self.zoomedItemAxis + self.groupSpace));
    }
}

- (void)calculateMaxAndMinValue {
    switch (self.chartType) {
        case BarChartTypeSingle: {
            if (self.beginGroupIndex == self.endGroupIndex) {
                self.minDataValue = [self dataAtGroup:self.beginGroupIndex item:0];
                self.maxDataValue = self.minDataValue;
            } else {
                NSMutableArray *array = [NSMutableArray arrayWithCapacity:(self.endGroupIndex - self.beginGroupIndex + 1)];
                for (NSUInteger i=self.beginGroupIndex; i<=self.endGroupIndex; i++) {
                    [array addObject:[(NSArray *)self.Datas[0] objectAtIndex:i]];
                }
                self.minDataValue = 0;
                self.maxDataValue = self.minDataValue;
                [self findMaxAndMinValue:0 rightIndex:array.count-1 compareA:array];
            }
        }
            break;
        case BarChartTypeStack: {
            if (self.beginGroupIndex == self.endGroupIndex) {
                self.minDataValue = 0; self.maxDataValue = 0;
                for (NSUInteger i=0; i<self.Datas.count; i++) {
                    CGFloat x = [self dataAtGroup:self.beginGroupIndex item:i];
                    if (x < 0) {
                        self.minDataValue += x;
                    } else {
                        self.maxDataValue += x;
                    }
                    
                }
            } else {
                NSMutableArray *minDataValues = [NSMutableArray arrayWithCapacity:(self.endGroupIndex - self.beginGroupIndex + 1)];
                NSMutableArray *maxDataValues = [NSMutableArray arrayWithCapacity:(self.endGroupIndex - self.beginGroupIndex + 1)];
                
                for (NSUInteger i=self.beginGroupIndex; i<=self.endGroupIndex; i++) {
                    CGFloat tempMinXValue = 0, tempMaxXValue = 0;
                    for (NSUInteger j=0;j<self.Datas.count;j++) {
                        CGFloat x = [self dataAtGroup:i item:j];
                        if (x< 0) {
                            tempMinXValue += x;
                        } else {
                            tempMaxXValue += x;
                        }
                    }
                    [minDataValues addObject:[NSString stringWithFormat:@"%f",tempMinXValue]];
                    [maxDataValues addObject:[NSString stringWithFormat:@"%f",tempMaxXValue]];
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
        }
            break;
        case BarChartTypeGroup: {
            if (self.beginGroupIndex == self.endGroupIndex) {
                if (self.beginItemIndex > self.endItemIndex) {
                    self.beginItemIndex = self.endItemIndex;
                }
                self.minDataValue = [self dataAtGroup:self.beginGroupIndex item:self.beginItemIndex];
                self.maxDataValue = self.minDataValue;
                for (NSUInteger i=self.beginItemIndex+1; i<=self.endItemIndex; i++) {
                    CGFloat tempValue = [self dataAtGroup:self.beginGroupIndex item:i];
                    self.minDataValue = MIN(self.minDataValue, tempValue);
                    self.maxDataValue = MAX(self.maxDataValue, tempValue);
                }
            } else if (self.beginGroupIndex == self.endGroupIndex - 1) {
                self.minDataValue = [self dataAtGroup:self.beginGroupIndex item:self.beginItemIndex];
                self.maxDataValue = self.minDataValue;
                
                [self compareBeginAndEndItemValue:self.beginItemIndex+1 endItem:self.Datas.count-1 isBeginGroup:YES];
                [self compareBeginAndEndItemValue:0 endItem:self.endItemIndex isBeginGroup:NO];
            } else {
                self.minDataValue = [self dataAtGroup:self.beginGroupIndex item:self.beginItemIndex];
                self.maxDataValue = self.minDataValue;
                
                [self compareBeginAndEndItemValue:self.beginItemIndex+1 endItem:self.Datas.count-1 isBeginGroup:YES];
                [self compareBeginAndEndItemValue:0 endItem:self.endItemIndex isBeginGroup:NO];
                [self campareMaxAndMinValue:self.beginGroupIndex+1 rightIndex:self.endGroupIndex-1];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)drawDataPoint {
    UIView *subContainerV = [[UIView alloc] initWithFrame:CGRectMake(LeftEdge, TopEdge, ChartWidth, ChartHeight)];
    subContainerV.layer.masksToBounds = YES;
    [self.containerView addSubview:subContainerV];
    switch (self.chartType) {
        case BarChartTypeSingle: {
            NSArray *array = self.Datas[0];
            CGFloat offsetY = self.gestureScroll.contentOffset.y;
            for (NSUInteger i=self.beginGroupIndex; i<=self.endGroupIndex; i++) {
                CAShapeLayer *xValueLayer = [CAShapeLayer layer];
                CGFloat xPoint = self.zeroLine;
                CGFloat dataV = [self verifyDataValue:array[i]];
                if (dataV < 0) {
                    xPoint = self.zeroLine + dataV * self.dataItemUnitScale;
                }
                UIBezierPath *xValueBezier = [UIBezierPath bezierPathWithRect:CGRectMake(xPoint, i*(self.zoomedItemAxis+self.groupSpace)-offsetY, fabs(dataV) * self.dataItemUnitScale, self.zoomedItemAxis)];
                xValueLayer.path = xValueBezier.CGPath;
                xValueLayer.lineWidth = 1;
                xValueLayer.strokeColor = [[UIColor hexChangeFloat:self.itemColors[0]] CGColor];
                xValueLayer.fillColor = [[UIColor hexChangeFloat:self.itemColors[0]] CGColor];
                [subContainerV.layer addSublayer:xValueLayer];
            }
        }
            break;
        case BarChartTypeStack: {
            CGFloat offsetY = self.gestureScroll.contentOffset.y;
            for (NSUInteger i=self.beginGroupIndex; i<=self.endGroupIndex; i++) {
                CGFloat positiveX = self.zeroLine, negativeX = self.zeroLine, xPoint = self.zeroLine;
                for (NSUInteger j=0; j<self.Datas.count; j++) {
                    NSArray *array = self.Datas[j];
                    CGFloat dataV = [self verifyDataValue:array[i]];
                    CAShapeLayer *xValueLayer = [CAShapeLayer layer];
                    if (dataV < 0) {
                        negativeX += dataV * self.dataItemUnitScale;
                        xPoint = negativeX;
                    }
                    if (dataV >= 0 && xPoint < self.zeroLine) {
                        xPoint = self.zeroLine;
                    }
                    UIBezierPath *xValueBezier = [UIBezierPath bezierPathWithRect:CGRectMake(xPoint, i*(self.zoomedItemAxis+self.groupSpace)-offsetY, fabs(dataV) * self.dataItemUnitScale, self.zoomedItemAxis)];
                    xValueLayer.path = xValueBezier.CGPath;
                    xValueLayer.lineWidth = 1;
                    xValueLayer.strokeColor = [[UIColor hexChangeFloat:self.itemColors[j]] CGColor];
                    xValueLayer.fillColor = [[UIColor hexChangeFloat:self.itemColors[j]] CGColor];
                    [subContainerV.layer addSublayer:xValueLayer];
                    
                    if (dataV >= 0) {
                        positiveX += dataV * self.dataItemUnitScale;
                        xPoint = positiveX;
                    }
                }
            }
        }
            break;
        case BarChartTypeGroup: {
            CGFloat offsetY = self.gestureScroll.contentOffset.y;
            if (self.beginItemIndex >= self.Datas.count) break;
            NSUInteger rightLoopIndex = self.endItemIndex;
            if (self.endItemIndex >= self.Datas.count) {
                rightLoopIndex = self.Datas.count - 1;
            }
            if (self.beginGroupIndex == self.endGroupIndex) {
                if (self.beginItemIndex>self.endItemIndex) break;
                [self drawBeginAndEndItemLayer:self.beginItemIndex rightIndex:rightLoopIndex isBegin:YES containerView:subContainerV];
                break;
            }
            
            [self drawBeginAndEndItemLayer:self.beginItemIndex rightIndex:self.Datas.count-1 isBegin:YES containerView:subContainerV];
            [self drawBeginAndEndItemLayer:0 rightIndex:rightLoopIndex isBegin:NO containerView:subContainerV];
            
            for (NSUInteger i=self.beginGroupIndex+1; i<self.endGroupIndex; i++) {
                for (NSUInteger j=0; j<self.Datas.count; j++) {
                    NSArray *array = self.Datas[j];
                    CGFloat dataV = [self verifyDataValue:array[i]];
                    CAShapeLayer *xValueLayer = [CAShapeLayer layer];
                    
                    CGFloat xPoint = self.zeroLine;
                    if (dataV < 0) {
                        xPoint = self.zeroLine + dataV * self.dataItemUnitScale;
                    }
                    UIBezierPath *xValueBezier = [UIBezierPath bezierPathWithRect:CGRectMake(xPoint, i*(self.zoomedItemAxis*self.Datas.count+self.groupSpace)+j*self.zoomedItemAxis-offsetY, fabs(dataV) * self.dataItemUnitScale, self.zoomedItemAxis)];
                    xValueLayer.path = xValueBezier.CGPath;
                    xValueLayer.lineWidth = 1;
                    xValueLayer.strokeColor = [[UIColor hexChangeFloat:self.itemColors[j]] CGColor];
                    xValueLayer.fillColor = [[UIColor hexChangeFloat:self.itemColors[j]] CGColor];
                    [subContainerV.layer addSublayer:xValueLayer];
                }
            }
        }
            break;
            
        default:
            break;
    }
}
- (void)drawBeginAndEndItemLayer:(NSInteger)leftIndex rightIndex:(NSInteger)rightIndex isBegin:(BOOL)isBegin containerView:(UIView *)subContainerV {
    CGFloat offsetY = self.gestureScroll.contentOffset.y;
    
    for (NSUInteger i=leftIndex; i<=rightIndex; i++) {
        NSArray *array = self.Datas[i];
        CAShapeLayer *xValueLayer = [CAShapeLayer layer];
        CGFloat itemValue = isBegin ? [self verifyDataValue:array[self.beginGroupIndex]] :  [self verifyDataValue:array[self.endGroupIndex]];
        CGFloat xPoint = self.zeroLine;
        if (itemValue < 0) {
            xPoint = self.zeroLine + itemValue * self.dataItemUnitScale;
        }
        NSUInteger leftIndex = isBegin ? self.beginGroupIndex : self.endGroupIndex;
        CGFloat y = leftIndex *(self.zoomedItemAxis*self.Datas.count+self.groupSpace)+i*self.zoomedItemAxis-offsetY;
        UIBezierPath *xValueBezier = [UIBezierPath bezierPathWithRect:CGRectMake(xPoint, y, fabs(itemValue) * self.dataItemUnitScale, self.zoomedItemAxis)];
        xValueLayer.path = xValueBezier.CGPath;
        xValueLayer.lineWidth = 1;
        xValueLayer.strokeColor = [[UIColor hexChangeFloat:self.itemColors[i]] CGColor];
        xValueLayer.fillColor = [[UIColor hexChangeFloat:self.itemColors[i]] CGColor];
        [subContainerV.layer addSublayer:xValueLayer];
    }
}

- (void)addAxisLayer {
    CGFloat offsetY = self.gestureScroll.contentOffset.y;
    for (NSUInteger i=self.beginGroupIndex; i<=self.endGroupIndex; i++) {
        CGRect textFrame;
        if (self.chartType == BarChartTypeGroup) {
            if ((self.Datas.count*self.zoomedItemAxis+self.groupSpace)*i - offsetY + (self.Datas.count*self.zoomedItemAxis-TextHeight)/2.0 < 0) continue;
            textFrame = CGRectMake(0, TopEdge+(self.Datas.count*self.zoomedItemAxis+self.groupSpace)*i - offsetY + (self.Datas.count*self.zoomedItemAxis-TextHeight)/2.0, LeftEdge, TextHeight);
        } else {
            if ((self.zoomedItemAxis+self.groupSpace)*i - offsetY + (self.zoomedItemAxis-TextHeight)/2.0 < 0) continue;
            textFrame = CGRectMake(0, TopEdge+(self.zoomedItemAxis+self.groupSpace)*i - offsetY + (self.zoomedItemAxis-TextHeight)/2.0, LeftEdge, TextHeight);
        }
        CATextLayer *text = [self getTextLayerWithString:self.AxisArray[i] textColor:AxisTextColor fontSize:AxistTextFont backgroundColor:[UIColor clearColor] frame:textFrame alignmentMode:kCAAlignmentRight];
        [self.containerView.layer addSublayer:text];
    }
}
- (void)addAxisScaleLayer {
    CAShapeLayer *yScaleLayer = [CAShapeLayer layer];
    UIBezierPath *yScaleBezier = [UIBezierPath bezierPath];
    [yScaleBezier moveToPoint:CGPointMake(LeftEdge, TopEdge)];
    [yScaleBezier addLineToPoint:CGPointMake(LeftEdge, self.bounds.size.height-BottomEdge)];
    yScaleLayer.path = yScaleBezier.CGPath;
    yScaleLayer.lineWidth = ReferenceLineWidth;
    yScaleLayer.strokeColor = AxisScaleColor.CGColor;
    yScaleLayer.fillColor = [UIColor clearColor].CGColor;
    [self.containerView.layer addSublayer:yScaleLayer];
}
- (void)addDataLayer {
    for (NSUInteger i=0; i<self.dataNegativeSegmentNum; i++) {
        CGRect textFrame = CGRectMake((i-0.5)*[self axisUnitScale]+LeftEdge, self.bounds.size.height-TextHeight, [self axisUnitScale], TextHeight);
        CATextLayer *text = [self getTextLayerWithString:[NSString stringWithFormat:@"-%@",[self adjustScaleValue:(self.dataNegativeSegmentNum-i)*self.itemDataScale]] textColor:DataTextColor fontSize:DataTextFont backgroundColor:[UIColor clearColor] frame:textFrame alignmentMode:kCAAlignmentCenter];
        [self.containerView.layer addSublayer:text];
    }
    for (NSInteger i=0; i<=self.dataPostiveSegmentNum+1; i++) {
        CGRect textFrame = CGRectMake((self.dataNegativeSegmentNum+i-0.5)*[self axisUnitScale]+LeftEdge, self.bounds.size.height-TextHeight, [self axisUnitScale], TextHeight);
        CATextLayer *text = [self getTextLayerWithString:[NSString stringWithFormat:@"%@",[self adjustScaleValue:i*self.itemDataScale]] textColor:DataTextColor fontSize:DataTextFont backgroundColor:[UIColor clearColor] frame:textFrame alignmentMode:kCAAlignmentCenter];
        [self.containerView.layer addSublayer:text];
    }
}

- (void)addDataScaleLayer {
    CAShapeLayer *xScaleLayer = [CAShapeLayer layer];
    UIBezierPath *xScaleBezier = [UIBezierPath bezierPath];
    [xScaleBezier moveToPoint:CGPointMake(LeftEdge, self.bounds.size.height-BottomEdge)];
    [xScaleBezier addLineToPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height-BottomEdge)];
    
    for (NSUInteger i=0; i<=self.dataNegativeSegmentNum+self.dataPostiveSegmentNum+1; i++) {
        [xScaleBezier moveToPoint:CGPointMake(LeftEdge+i*[self axisUnitScale], self.bounds.size.height-BottomEdge)];
        [xScaleBezier addLineToPoint:CGPointMake(LeftEdge+i*[self axisUnitScale], self.bounds.size.height-BottomEdge+5)];
    }
    xScaleLayer.path = xScaleBezier.CGPath;
    xScaleLayer.lineWidth = ReferenceLineWidth;
    xScaleLayer.strokeColor = AxisScaleColor.CGColor;
    xScaleLayer.fillColor = [UIColor clearColor].CGColor;
    [self.containerView.layer addSublayer:xScaleLayer];
    
    if (self.showDataDashLine || self.showDataHardLine) {
        CAShapeLayer *dashLineLayer = [CAShapeLayer layer];
        UIBezierPath *dashLineBezier = [UIBezierPath bezierPath];
        for (NSUInteger i=1; i<=self.dataNegativeSegmentNum+self.dataPostiveSegmentNum; i++) {
            [dashLineBezier moveToPoint:CGPointMake(LeftEdge+i*[self axisUnitScale], self.bounds.size.height-BottomEdge)];
            [dashLineBezier addLineToPoint:CGPointMake(LeftEdge+i*[self axisUnitScale], TopEdge)];
        }
        dashLineLayer.path = dashLineBezier.CGPath;
        if (self.showDataDashLine) {
            [dashLineLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:5], [NSNumber numberWithInt:5], nil]];
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
            CGFloat h = (ChartHeight-[self.Datas[0] count]*self.groupSpace)/[self.Datas[0] count]/self.Datas.count;
            self.itemAxisScale = h > self.minItemWidth ? h : self.minItemWidth;
        } else {
            self.itemAxisScale = (ChartHeight/[self.Datas[0] count] - self.groupSpace) > self.minItemWidth ? (ChartHeight/[self.Datas[0] count] - self.groupSpace) : self.minItemWidth;
        }
    }
    return self.itemAxisScale;
}

- (CGFloat)axisUnitScale {
    return ChartWidth/(self.dataNegativeSegmentNum + self.dataPostiveSegmentNum);
}

- (CGFloat)scrollContentSizeHeight {
    if (self.chartType == BarChartTypeGroup) {
        return (self.Datas.count*self.zoomedItemAxis + self.groupSpace) * [self.Datas[0] count];
    }
    return (self.zoomedItemAxis + self.groupSpace) * [self.Datas[0] count];
}
- (CGFloat)zeroLine {
    return self.dataNegativeSegmentNum * [self axisUnitScale];
}
- (CGFloat)dataItemUnitScale {
    return ChartWidth / (self.itemDataScale * (self.dataPostiveSegmentNum + self.dataNegativeSegmentNum));
}
- (void)adjustScale:(CGRect)origionFrame newFrame:(CGRect)newFrame {
    self.itemAxisScale *=
    (newFrame.size.height - TopEdge - BottomEdge) / (origionFrame.size.height - TopEdge - BottomEdge);
    
    if ([self gestureScrollContentSize].height < (newFrame.size.height - TopEdge - BottomEdge)) {
        if (self.chartType == BarChartTypeGroup) {
            self.oldPinScale *=
            ((newFrame.size.height - TopEdge - BottomEdge) / [self.Datas[0] count] - self.groupSpace) /
            self.Datas.count / self.itemAxisScale / self.oldPinScale;
        } else {
            self.oldPinScale *=
            ((newFrame.size.height - TopEdge - BottomEdge) / [self.Datas[0] count] - self.groupSpace) /
            self.itemAxisScale / self.oldPinScale;
        }
    }
}
@end
