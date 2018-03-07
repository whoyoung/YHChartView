//
//  YHLineChartView.m
//  YHDailyDemo
//
//  Created by 杨虎 on 2018/1/26.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "YHLineChartView.h"

@interface YHLineChartView()
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) CGFloat circleRadius;
@property (nonatomic, assign) CGFloat circleBorderWidth;
@property (nonatomic, assign) BOOL showSelectedSubLine;
@property (nonatomic, copy) NSString *subLineColor;
@end

@implementation YHLineChartView

- (void)dealStyleDict:(NSDictionary *)styleDict {
    NSDictionary *lineStyle = [styleDict objectForKey:@"lineStyle"];
    self.minItemWidth = [lineStyle objectForKey:@"minItemWidth"] ? [[lineStyle objectForKey:@"minItemWidth"] floatValue] : 20;
    self.showAxisDashLine = [lineStyle objectForKey:@"showAxisDashLine"] ? [[lineStyle objectForKey:@"showAxisDashLine"] boolValue] : NO;
    self.showAxisHardLine = [lineStyle objectForKey:@"showAxisHardLine"] ? [[lineStyle objectForKey:@"showAxisHardLine"] boolValue] : NO;
    self.showDataDashLine = [lineStyle objectForKey:@"showDataDashLine"] ? [[lineStyle objectForKey:@"showDataDashLine"] boolValue] : NO;
    self.showDataHardLine = [lineStyle objectForKey:@"showDataHardLine"] ? [[lineStyle objectForKey:@"showDataHardLine"] boolValue] : YES;
    self.lineWidth =
    [lineStyle objectForKey:@"lineWidth"] ? [[lineStyle objectForKey:@"lineWidth"] floatValue] : 1.5;
    self.circleBorderWidth =
    [lineStyle objectForKey:@"circleBorderWidth"] ? [[lineStyle objectForKey:@"circleBorderWidth"] floatValue] : 0.5;
    self.circleRadius =
    [lineStyle objectForKey:@"circleRadius"] ? [[lineStyle objectForKey:@"circleRadius"] floatValue] : 3;
    if (self.circleBorderWidth > self.circleRadius) {
        self.circleBorderWidth = self.circleRadius;
    }
    self.showSelectedSubLine = [lineStyle objectForKey:@"showSelectedSubLine"] ? [[lineStyle objectForKey:@"showSelectedSubLine"] boolValue] : YES;
    self.subLineColor = [lineStyle objectForKey:@"subLineColor"] ? [lineStyle objectForKey:@"subLineColor"] : @"cccccc";
}

- (CGSize)gestureScrollContentSize {
    return CGSizeMake([self.Datas[0] count]*self.zoomedItemAxis, ChartHeight);
}

- (void)chartDidZooming:(UIPinchGestureRecognizer *)pinGesture {
    switch (pinGesture.state) {
        case UIGestureRecognizerStateBegan: {
            CGPoint pinCenterContainer = [pinGesture locationInView:self.containerView];
            self.pinCenterToLeftDistance = pinCenterContainer.x - LeftEdge;
            CGPoint pinCenterScrollView = [pinGesture locationInView:self.gestureScroll];
            self.pinCenterRatio = pinCenterScrollView.x/self.gestureScroll.contentSize.width;
        }
            break;
        case UIGestureRecognizerStateChanged: {
            if (pinGesture.scale < 1 && [self.Datas[0] count]*[self calculateItemAxisScale]*self.oldPinScale*pinGesture.scale <= ChartWidth) {
                self.newPinScale = ChartWidth/([self.Datas[0] count]*[self calculateItemAxisScale]*self.oldPinScale);
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
    self.gestureScroll.contentSize = CGSizeMake([self.Datas[0] count]*self.zoomedItemAxis, ChartHeight);
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
    group = floorf(tapP.x / self.zoomedItemAxis);
    if ((tapP.x - group * self.zoomedItemAxis) > self.zoomedItemAxis/2.0 && group <  self.Datas[0].count - 1) {
        group += 1;
    }
    for(NSUInteger i=0;i<self.Datas.count;) {
        if ([self dataAtGroup:group item:i] != MAXFLOAT) {
            item = i;
            break;
        }
        if (i == self.Datas.count - 1) return nil;
        i += 1;
    }
    if (self.Datas.count > 1) {
        CGFloat actualY = self.zeroLine;
        actualY -= [self dataAtGroup:group item:item] * self.dataItemUnitScale;
        CGFloat minDistance = fabs(tapP.y - actualY);
        for (NSUInteger i=item+1; i<self.Datas.count; i++) {
            if ([self dataAtGroup:group item:i] == MAXFLOAT) continue;
            CGFloat tempActualY = self.zeroLine - [self dataAtGroup:group item:i] * self.dataItemUnitScale;
            if (minDistance > fabs(tapP.y - tempActualY)) {
                minDistance = fabs(tapP.y - tempActualY);
                item = i;
            }
        }
    }
    if (item > self.Datas.count - 1) {
        item = self.Datas.count - 1;
    }
    
    return @{
             @"group":@(group),
             @"item":@(item)
             };
    
}
- (void)saveTapPointRatio:(CGPoint)tapP group:(NSUInteger)group item:(NSUInteger)item {
    self.pointRatio = YHTapPointRatioInItemMake(1, 1);
}
- (CGPoint)adjustTipViewLocation:(NSUInteger)group item:(NSUInteger)item {
    CGPoint tempP;
    tempP.x = group * self.zoomedItemAxis;
    tempP.y = self.zeroLine - [super dataAtGroup:group item:item] * self.dataItemUnitScale;
    tempP = [self.gestureScroll convertPoint:tempP toView:self.containerView];
    return tempP;
}

- (void)findGroupAndItemIndex {
    CGPoint offset = self.gestureScroll.contentOffset;
    self.beginGroupIndex = floor(offset.x/self.zoomedItemAxis);
    self.endGroupIndex = ceil((offset.x+ChartWidth)/self.zoomedItemAxis);
}

- (void)calculateMaxAndMinValue {
    self.minDataValue = 0;
    self.maxDataValue = self.minDataValue;
    for (NSArray *values in self.Datas) {
        [self findMaxAndMinValue:self.beginGroupIndex rightIndex:self.endGroupIndex compareA:values];
    }
}

- (void)drawDataPoint {
    UIView *subContainerV = [[UIView alloc] initWithFrame:CGRectMake(LeftEdge, TopEdge, ChartWidth, ChartHeight)];
    subContainerV.layer.masksToBounds = YES;
    subContainerV.tag = 102;
    [self.containerView addSubview:subContainerV];
    NSUInteger drawNum = lroundf(self.endGroupIndex * self.dataNumFactor);
    for (NSUInteger i=0;i<self.Datas.count;i++) {
        NSArray *values = self.Datas[i];
        CAShapeLayer *yValueLayer = [CAShapeLayer layer];
        UIBezierPath *yValueBezier = [UIBezierPath bezierPath];
        CGFloat offsetX = self.gestureScroll.contentOffset.x;
        CGFloat zeroY = self.dataPostiveSegmentNum * [self axisUnitScale];
        yValueLayer.name = [self layerTag:0 item:i];
        NSMutableArray *circlePoints = [NSMutableArray array];
        
        for (NSUInteger j=self.beginGroupIndex; j<drawNum+1; j++) {
            if (![values[j] respondsToSelector:@selector(floatValue)]) continue;
            CGFloat yPoint = zeroY - [self verifyDataValue:values[j]] * self.dataItemUnitScale * self.dataValueFactor;
            CGPoint p = CGPointMake(j*self.zoomedItemAxis-offsetX, yPoint);
            if (j == self.beginGroupIndex || ![values[j-1] respondsToSelector:@selector(floatValue)]) {
                [yValueBezier moveToPoint:p];
            } else {
                [yValueBezier addLineToPoint:p];
            }
            
            if (j > self.beginGroupIndex && j < drawNum) {
                if (![values[j-1] respondsToSelector:@selector(floatValue)] && ![values[j+1] respondsToSelector:@selector(floatValue)]) {
                    [circlePoints addObject:NSStringFromCGPoint(p)];
                }
            } else if (j == self.beginGroupIndex) {
                if (j < drawNum && ![values[j+1] respondsToSelector:@selector(floatValue)]) {
                    [circlePoints addObject:NSStringFromCGPoint(p)];
                }
            } else {
                if (j > self.beginGroupIndex && ![values[j-1] respondsToSelector:@selector(floatValue)]) {
                    [circlePoints addObject:NSStringFromCGPoint(p)];
                }
            }
        }
        yValueLayer.path = yValueBezier.CGPath;
        yValueLayer.lineWidth = self.lineWidth;
        yValueLayer.strokeColor = [[UIColor hexChangeFloat:self.itemColors[i]] CGColor];
        yValueLayer.fillColor = [[UIColor clearColor] CGColor];
        [subContainerV.layer addSublayer:yValueLayer];

        [self addCircleLayers:circlePoints
                  circleColor:[[UIColor hexChangeFloat:self.itemColors[i]] CGColor]
                   parentView:subContainerV];
    }
}
- (void)addCircleLayers:(NSMutableArray *)circlePoints circleColor:(CGColorRef)color parentView:(UIView *)parentV {
    for (NSUInteger index = 0; index < circlePoints.count; index++) {
        CAShapeLayer *shaperLayer = [CAShapeLayer layer];
        UIBezierPath *bezierP = [UIBezierPath bezierPathWithArcCenter:CGPointFromString(circlePoints[index])
                                                               radius:self.circleRadius
                                                           startAngle:0
                                                             endAngle:2 * M_PI
                                                            clockwise:YES];
        
        shaperLayer.path = bezierP.CGPath;
        shaperLayer.fillColor = color;
        [parentV.layer addSublayer:shaperLayer];
        
        CAShapeLayer *centerLayer = [CAShapeLayer layer];
        UIBezierPath *centerBezierP = [UIBezierPath bezierPathWithArcCenter:CGPointFromString(circlePoints[index])
                                                               radius:self.circleRadius-self.circleBorderWidth
                                                           startAngle:0
                                                             endAngle:2 * M_PI
                                                            clockwise:YES];
        
        centerLayer.path = centerBezierP.CGPath;
        centerLayer.fillColor = [UIColor whiteColor].CGColor;
        [parentV.layer addSublayer:centerLayer];
    }
}

- (void)addAxisLayer {
    CGFloat offsetX = self.gestureScroll.contentOffset.x;
    for (NSUInteger i=self.beginGroupIndex; i<=self.endGroupIndex; i++) {
        if (self.zoomedItemAxis*i-offsetX < 0) continue;
        CGRect textFrame = CGRectMake(LeftEdge + self.zoomedItemAxis*i-offsetX-self.zoomedItemAxis/2.0, self.bounds.size.height-self.axisTextFontSize-2, self.zoomedItemAxis, self.axisTextFontSize+1);
        CATextLayer *text = [self getTextLayerWithString:self.AxisArray[i] textColor:self.axisTextColor fontSize:self.axisTextFontSize backgroundColor:[UIColor clearColor] frame:textFrame alignmentMode:kCAAlignmentCenter];
        [self.containerView.layer addSublayer:text];
    }
}
- (void)addAxisScaleLayer {
    CAShapeLayer *xScaleLayer = [CAShapeLayer layer];
    UIBezierPath *xScaleBezier = [UIBezierPath bezierPath];
    [xScaleBezier moveToPoint:CGPointMake(LeftEdge, self.bounds.size.height-BottomEdge)];
    [xScaleBezier addLineToPoint:CGPointMake(self.bounds.size.width-RightEdge, self.bounds.size.height-BottomEdge)];
    
    CGFloat offsetX = self.gestureScroll.contentOffset.x;
    for (NSUInteger i=self.beginGroupIndex; i<=self.endGroupIndex; i++) {
        if (self.zoomedItemAxis*i - offsetX < 0) continue;
        [xScaleBezier moveToPoint:CGPointMake(LeftEdge + self.zoomedItemAxis*i - offsetX, self.bounds.size.height-BottomEdge)];
        [xScaleBezier addLineToPoint:CGPointMake(LeftEdge + self.zoomedItemAxis*i - offsetX, self.bounds.size.height-BottomEdge+5)];
    }
    xScaleLayer.path = xScaleBezier.CGPath;
    xScaleLayer.lineWidth = self.referenceLineWidth;
    xScaleLayer.strokeColor = self.referenceLineColor.CGColor;
    xScaleLayer.fillColor = [UIColor clearColor].CGColor;
    [self.containerView.layer addSublayer:xScaleLayer];
    
    if (self.showAxisDashLine || self.showAxisHardLine) {
        CAShapeLayer *dashLineLayer = [CAShapeLayer layer];
        UIBezierPath *dashLineBezier = [UIBezierPath bezierPath];
        for (NSUInteger i=self.beginGroupIndex; i<=self.endGroupIndex; i++) {
            if (self.zoomedItemAxis*i - offsetX < 0) continue;
            [dashLineBezier moveToPoint:CGPointMake(LeftEdge + self.zoomedItemAxis*i - offsetX, self.bounds.size.height-BottomEdge-1)];
            [dashLineBezier addLineToPoint:CGPointMake(LeftEdge + self.zoomedItemAxis*i - offsetX, TopEdge)];
        }
        dashLineLayer.path = dashLineBezier.CGPath;
        if (self.showAxisDashLine) {
            [dashLineLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:5], [NSNumber numberWithInt:5], nil]];
        }
        dashLineLayer.lineWidth = self.referenceLineWidth;
        dashLineLayer.strokeColor = self.referenceLineColor.CGColor;
        dashLineLayer.fillColor = [UIColor clearColor].CGColor;
        [self.containerView.layer addSublayer:dashLineLayer];
    }
}
- (void)addDataLayer {
    for (NSUInteger i=0; i<self.dataNegativeSegmentNum; i++) {
        CGRect textFrame = CGRectMake(0, self.bounds.size.height-1.5*BottomEdge-i*[self axisUnitScale], TextWidth, BottomEdge);
        CATextLayer *text = [self getTextLayerWithString:[NSString stringWithFormat:@"-%@",[self adjustScaleValue:(self.dataNegativeSegmentNum-i)*self.itemDataScale]] textColor:self.dataTextColor fontSize:self.dataTextFontSize backgroundColor:[UIColor clearColor] frame:textFrame alignmentMode:kCAAlignmentRight];
        [self.containerView.layer addSublayer:text];
    }
    for (NSInteger i=0; i<=self.dataPostiveSegmentNum+1; i++) {
        CGRect textFrame = CGRectMake(0, self.bounds.size.height-1.5*BottomEdge-(self.dataNegativeSegmentNum+i)*[self axisUnitScale], TextWidth, BottomEdge);
        CATextLayer *text = [self getTextLayerWithString:[NSString stringWithFormat:@"%@",[self adjustScaleValue:i*self.itemDataScale]] textColor:self.dataTextColor fontSize:self.dataTextFontSize backgroundColor:[UIColor clearColor] frame:textFrame alignmentMode:kCAAlignmentRight];
        [self.containerView.layer addSublayer:text];
    }
}

- (void)addDataScaleLayer {
    if (self.showDataEdgeLine) {
        CAShapeLayer *yScaleLayer = [CAShapeLayer layer];
        UIBezierPath *yScaleBezier = [UIBezierPath bezierPath];
        [yScaleBezier moveToPoint:CGPointMake(LeftEdge, TopEdge)];
        [yScaleBezier addLineToPoint:CGPointMake(LeftEdge, self.bounds.size.height-BottomEdge)];
        
        for (NSUInteger i=0; i<=self.dataNegativeSegmentNum+self.dataPostiveSegmentNum+1; i++) {
            [yScaleBezier moveToPoint:CGPointMake(LeftEdge-5, TopEdge+i*[self axisUnitScale])];
            [yScaleBezier addLineToPoint:CGPointMake(LeftEdge, TopEdge+i*[self axisUnitScale])];
        }
        yScaleLayer.path = yScaleBezier.CGPath;
        yScaleLayer.backgroundColor = AxisScaleColor.CGColor;
        yScaleLayer.lineWidth = self.referenceLineWidth;
        yScaleLayer.strokeColor = self.referenceLineColor.CGColor;
        yScaleLayer.fillColor = [UIColor clearColor].CGColor;
        [self.containerView.layer addSublayer:yScaleLayer];
    }
    
    if (self.showDataDashLine || self.showDataHardLine) {
        CAShapeLayer *dashLineLayer = [CAShapeLayer layer];
        UIBezierPath *dashLineBezier = [UIBezierPath bezierPath];
        for (NSUInteger i=0; i<=self.dataNegativeSegmentNum+self.dataPostiveSegmentNum; i++) {
            [dashLineBezier moveToPoint:CGPointMake(LeftEdge, TopEdge+i*[self axisUnitScale])];
            [dashLineBezier addLineToPoint:CGPointMake(self.bounds.size.width-RightEdge, TopEdge+i*[self axisUnitScale])];
            if (i==self.dataPostiveSegmentNum) continue;
        }
        dashLineLayer.path = dashLineBezier.CGPath;
        if (self.showDataDashLine) {
            [dashLineLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:5], [NSNumber numberWithInt:5], nil]];
        }
        dashLineLayer.lineWidth = self.referenceLineWidth;
        dashLineLayer.strokeColor = self.referenceLineColor.CGColor;
        dashLineLayer.fillColor = [UIColor clearColor].CGColor;
        [self.containerView.layer addSublayer:dashLineLayer];
        
        CAShapeLayer *zeroLineLayer = [CAShapeLayer layer];
        UIBezierPath *zeroLineBezier = [UIBezierPath bezierPath];
        [zeroLineBezier moveToPoint:CGPointMake(LeftEdge, TopEdge+self.dataPostiveSegmentNum*[self axisUnitScale])];
        [zeroLineBezier addLineToPoint:CGPointMake(self.bounds.size.width-RightEdge, TopEdge+self.dataPostiveSegmentNum*[self axisUnitScale])];
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
        self.itemAxisScale = ChartWidth/[self.Datas[0] count] > self.minItemWidth ? (ChartWidth/[self.Datas[0] count]) : self.minItemWidth;
    }
    return self.itemAxisScale;
}

- (CGFloat)axisUnitScale {
    return ChartHeight/(self.dataNegativeSegmentNum + self.dataPostiveSegmentNum);
}

- (CGFloat)zeroLine {
    return self.dataPostiveSegmentNum * [self axisUnitScale];
}
- (CGFloat)dataItemUnitScale {
    if (self.itemDataScale == 0) return 0;
    return ChartHeight / (self.itemDataScale * (self.dataPostiveSegmentNum + self.dataNegativeSegmentNum));
}
- (CGFloat)dataAtGroup:(NSUInteger)group item:(NSUInteger)item {
    if ([[self.Datas[item] objectAtIndex:group] respondsToSelector:@selector(floatValue)]) {
        return [[self.Datas[item] objectAtIndex:group] floatValue];
    }
    return MAXFLOAT;
}
- (void)adjustScale:(CGRect)origionFrame newFrame:(CGRect)newFrame {
    self.itemAxisScale *=
    (newFrame.size.width - LeftEdge - RightEdge) / (origionFrame.size.width - LeftEdge - RightEdge);
    
    if ([self gestureScrollContentSize].width < (newFrame.size.width - LeftEdge - RightEdge)) {
        self.oldPinScale *= (newFrame.size.width - LeftEdge - RightEdge) / [self.Datas[0] count] / self.Datas.count / self.itemAxisScale / self.oldPinScale;
    }
}

- (NSArray *)defaultColors {
    return @[
                @"4698EB", @"34C7C7", @"3BCC90", @"80C25D", @"FFA51F", @"F06260", @"886FE7"
            ];
}
- (void)updateSelectedGroup:(NSUInteger)group item:(NSUInteger)item {
    UIView *subContainer = [self.containerView viewWithTag:102];
    NSArray *subLayers = subContainer.layer.sublayers;
    for (NSUInteger i=subLayers.count-1;i>0;i--) {
        CALayer *layer = subLayers[i];
        if ([layer isKindOfClass:[CAShapeLayer class]] && ([layer.name isEqualToString:@"borderCircle"] || [layer.name isEqualToString:@"centerCircle"] || [layer.name isEqualToString:@"subline"])) {
            [layer removeFromSuperlayer];
        }
    }
    
    CGFloat offsetX = self.gestureScroll.contentOffset.x;
    CGFloat zeroY = self.dataPostiveSegmentNum * [self axisUnitScale];
    CGFloat yPoint = zeroY - [self dataAtGroup:group item:item] * self.dataItemUnitScale * self.dataValueFactor;
    CGPoint p = CGPointMake(group*self.zoomedItemAxis-offsetX, yPoint);
    [self selectedSublineLayers:NSStringFromCGPoint(p) circleColor:self.itemColors[item] parentView:subContainer];
}

- (void)selectedSublineLayers:(NSString *)pointString circleColor:(NSString *)hexColor parentView:(UIView *)parentV {
    CGPoint selectedP = CGPointFromString(pointString);
    CAShapeLayer *shaperLayer = [CAShapeLayer layer];
    UIBezierPath *bezierP = [UIBezierPath bezierPathWithArcCenter:selectedP
                                                           radius:self.circleRadius
                                                       startAngle:0
                                                         endAngle:2 * M_PI
                                                        clockwise:YES];
    
    shaperLayer.path = bezierP.CGPath;
    shaperLayer.strokeColor = [UIColor hexChangeFloat:hexColor alpha:0.3].CGColor;
    shaperLayer.fillColor = [UIColor hexChangeFloat:hexColor alpha:0.3].CGColor;
    shaperLayer.name = @"borderCircle";
    [parentV.layer addSublayer:shaperLayer];
    
    CAShapeLayer *centerLayer = [CAShapeLayer layer];
    UIBezierPath *centerBezierP = [UIBezierPath bezierPathWithArcCenter:selectedP
                                                                 radius:self.circleRadius-self.circleBorderWidth
                                                             startAngle:0
                                                               endAngle:2 * M_PI
                                                              clockwise:YES];
    
    centerLayer.path = centerBezierP.CGPath;
    centerLayer.strokeColor = [UIColor hexChangeFloat:hexColor].CGColor;
    centerLayer.fillColor = [UIColor hexChangeFloat:hexColor].CGColor;
    centerLayer.name = @"centerCircle";
    [parentV.layer addSublayer:centerLayer];
    
    if(self.showSelectedSubLine) {
        CAShapeLayer *sublineLayer = [CAShapeLayer layer];
        UIBezierPath *sublineBezierP = [UIBezierPath bezierPath];
        [sublineBezierP moveToPoint:CGPointMake(selectedP.x, 0)];
        [sublineBezierP addLineToPoint:CGPointMake(selectedP.x, ChartHeight)];
        sublineLayer.path = sublineBezierP.CGPath;
        sublineLayer.lineWidth = 0.5;
        sublineLayer.strokeColor = [UIColor hexChangeFloat:self.subLineColor].CGColor;
        sublineLayer.fillColor = [UIColor hexChangeFloat:self.subLineColor].CGColor;
        sublineLayer.name = @"subline";
        [parentV.layer addSublayer:sublineLayer];
    }
}

@end
