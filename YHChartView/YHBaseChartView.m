//
//  YHBaseChartView.m
//
//  Created by 杨虎 on 2018/2/2.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "YHBaseChartView.h"

@interface YHBaseChartView () <UIScrollViewDelegate>
@property (nonatomic, assign, readonly) BOOL isDataError;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) CGFloat tipViewBackgroundColorAlpha;
@property (nonatomic, copy) NSString *tipViewBackgroundHexColor;
@end

@implementation YHBaseChartView

- (id)initWithFrame:(CGRect)frame configure:(NSDictionary *)configureDict {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self dealChartConfigure:configureDict];
        self.layer.masksToBounds = YES;
        self.pointRatio = YHTapPointRatioInItemMake(0, 0);
    }
    return self;
}
- (void)updateChartConfigure:(NSDictionary *)configureDict frame:(CGRect)frame {
    [self dealChartConfigure:configureDict];
    self.pointRatio = YHTapPointRatioInItemMake(0, 0);
    self.hadTapped = NO;
    self.frame = frame;
    self.gestureScroll.contentOffset = CGPointZero;
    self.gestureScroll.frame = CGRectMake(self.leftEdge, TopEdge, ChartWidth, ChartHeight);
    self.gestureScroll.contentSize = [self gestureScrollContentSize];
    self.oldPinScale = 1.0;
    self.itemAxisScale = 0;
    [self redraw];
}
- (void)updateChartFrame:(CGRect)frame {
    [self adjustScale:self.frame newFrame:frame];
    CGFloat offSetXRatio = self.gestureScroll.contentOffset.x / self.gestureScroll.contentSize.width;
    CGFloat offSetYRatio = self.gestureScroll.contentOffset.y / self.gestureScroll.contentSize.height;
    self.frame = frame;
    self.gestureScroll.frame = CGRectMake(self.leftEdge, TopEdge, ChartWidth, ChartHeight);
    self.gestureScroll.contentSize = [self gestureScrollContentSize];
    if (offSetXRatio * self.gestureScroll.contentSize.width + ChartWidth > self.gestureScroll.contentSize.width ||
        offSetYRatio * self.gestureScroll.contentSize.height + ChartHeight > self.gestureScroll.contentSize.height) {
        self.gestureScroll.contentOffset = CGPointMake(self.gestureScroll.contentSize.width - ChartWidth,
                                                       self.gestureScroll.contentSize.height - ChartHeight);
    } else {
        self.gestureScroll.contentOffset = CGPointMake(offSetXRatio * self.gestureScroll.contentSize.width,
                                                       offSetYRatio * self.gestureScroll.contentSize.height);
    }
    
    [self redraw];
}
- (void)adjustScale:(CGRect)origionFrame newFrame:(CGRect)newFrame {
    _itemAxisScale *= (newFrame.size.width - self.leftEdge - RightEdge) / (origionFrame.size.width - self.leftEdge - RightEdge);
    _oldPinScale *= (origionFrame.size.width - self.leftEdge - RightEdge) / (newFrame.size.width - self.leftEdge - RightEdge);
}
- (void)dealChartConfigure:(NSDictionary *)dict {
    _AxisArray = [dict objectForKey:@"axis"];
    _Datas = [dict objectForKey:@"datas"];
    _isDataError = !self.AxisArray || ![self.AxisArray isKindOfClass:[NSArray class]] || !self.AxisArray.count ||
                   !self.Datas || ![self.Datas isKindOfClass:[NSArray class]] || !self.Datas.count;

    _groupMembers = [dict objectForKey:@"groupMembers"];
    _groupDimension = [dict objectForKey:@"groupDimension"];
    _axisTitle = [dict objectForKey:@"axisTitle"];
    _dataTitle = [dict objectForKey:@"dataTitle"];
    NSArray *colors = [dict objectForKey:@"colors"];
    [self dealItemColors:colors];
    _valueInterval = [[dict objectForKey:@"valueInterval"] integerValue];
    if (self.valueInterval == 0) {
        _valueInterval = 3;
    }
    _referenceLineWidth = [dict objectForKey:@"referenceLineWidth"] ? [[dict objectForKey:@"referenceLineWidth"] floatValue] : ReferenceLineWidth;
    _referenceLineColor = [dict objectForKey:@"referenceLineColor"] ? [UIColor hexChangeFloat:[dict objectForKey:@"referenceLineColor"]] : AxisScaleColor;
    _axisTextColor = [dict objectForKey:@"axisTextColor"] ? [UIColor hexChangeFloat:[dict objectForKey:@"axisTextColor"]] : AxisTextColor;
    _dataTextColor = [dict objectForKey:@"dataTextColor"] ? [UIColor hexChangeFloat:[dict objectForKey:@"dataTextColor"]] : DataTextColor;
    _axisTextFontSize = [dict objectForKey:@"axisTextFontSize"] ? [[dict objectForKey:@"axisTextFontSize"] floatValue] : AxistTextFont;
    _dataTextFontSize = [dict objectForKey:@"dataTextFontSize"] ? [[dict objectForKey:@"dataTextFontSize"] floatValue] : DataTextFont;
    _showLoadAnimation = [[dict objectForKey:@"showLoadAnimation"] boolValue];
    _loadAnimationTime = [dict objectForKey:@"loadAnimationTime"] ? [[dict objectForKey:@"loadAnimationTime"] floatValue] : LoadAnimationTime;
    if (_loadAnimationTime < 0.1) _loadAnimationTime = 0.1;
    _animationType = [[dict objectForKey:@"animationType"] integerValue];
    _showTipViewArrow = [[dict objectForKey:@"showTipViewArrow"] boolValue];
    _minWidthHideAxisText = [dict objectForKey:@"minWidthHideAxisText"] ? [[dict objectForKey:@"minWidthHideAxisText"] floatValue] : 40;
    _minItemWidth = [dict objectForKey:@"minItemWidth"] ? [[dict objectForKey:@"minItemWidth"] floatValue] : 20;
    _showAxisDashLine = [dict objectForKey:@"showAxisDashLine"] ? [[dict objectForKey:@"showAxisDashLine"] boolValue] : NO;
    _showAxisHardLine = [dict objectForKey:@"showAxisHardLine"] ? [[dict objectForKey:@"showAxisHardLine"] boolValue] : NO;
    _showDataDashLine = [dict objectForKey:@"showDataDashLine"] ? [[dict objectForKey:@"showDataDashLine"] boolValue] : NO;
    _showDataHardLine = [dict objectForKey:@"showDataHardLine"] ? [[dict objectForKey:@"showDataHardLine"] boolValue] : YES;
    _tipViewBackgroundHexColor = [dict objectForKey:@"tipViewBackgroundHexColor"] ? [dict objectForKey:@"tipViewBackgroundHexColor"] : @"000000";
    _tipViewBackgroundColorAlpha = [dict objectForKey:@"tipViewBackgroundColorAlpha"] ? [[dict objectForKey:@"tipViewBackgroundColorAlpha"] floatValue] : 0.65;
    _leftEdge = [dict objectForKey:@"leftEdge"] ? [[dict objectForKey:@"leftEdge"] floatValue] : [self defaultLeftEdge];
    
    NSDictionary *styleDict = [dict objectForKey:@"styles"];
    [self dealStyleDict:styleDict];
}
- (void)dealStyleDict:(NSDictionary *)styleDict {
    
}
- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.isDataError) {
        CGRect textFrame = CGRectMake(0, (ChartHeight - TextHeight) / 2.0, ChartWidth, TextHeight);
        CATextLayer *text = [self getTextLayerWithString:@"数据格式有误"
                                               textColor:[UIColor lightGrayColor]
                                                fontSize:TipTextFont
                                         backgroundColor:[UIColor clearColor]
                                                   frame:textFrame
                                           alignmentMode:kCAAlignmentCenter];
        [self.layer addSublayer:text];
        return;
    }
    [self addGestureScroll];
    self.gestureScroll.contentSize = [self gestureScrollContentSize];
    if (!_containerView) {
        _dataNumFactor = 1;
        _dataValueFactor = 1;
        if (_showLoadAnimation) {
            if (_animationType == YHAnimationTypeChangeNum) {
                _dataNumFactor = 0;
            } else if (_animationType == YHAnimationTypeChangeValueAndNum) {
                _dataNumFactor = 0;
                _dataValueFactor = 0;
            } else {
                _dataValueFactor = 0;
            }
            _timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(updateDraw) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
        } else {
            [self redraw];
        }
    }
}
- (void)updateDraw {
    if (_animationType == YHAnimationTypeChangeNum) {
        _dataNumFactor += 0.1/self.loadAnimationTime;
    } else if (_animationType == YHAnimationTypeChangeValueAndNum) {
        _dataValueFactor += 0.1/self.loadAnimationTime;
        _dataNumFactor += 0.1/self.loadAnimationTime;
    } else {
        _dataValueFactor += 0.1/self.loadAnimationTime;
    }
    if (_dataNumFactor > 1 || _dataValueFactor > 1) {
        _dataNumFactor = 1;
        _dataValueFactor = 1;
        [_timer invalidate];
        _timer = nil;
    } else {
        [self redraw];
    }
}
- (CGSize)gestureScrollContentSize {
    return CGSizeMake(ChartWidth, ChartHeight);
}
- (void)addGestureScroll {
    if (!_gestureScroll) {
        UIScrollView *scroll =
            [[UIScrollView alloc] initWithFrame:CGRectMake(self.leftEdge, TopEdge, ChartWidth, ChartHeight)];
        scroll.showsVerticalScrollIndicator = NO;
        scroll.showsHorizontalScrollIndicator = NO;
        scroll.minimumZoomScale = 1.0;
        scroll.maximumZoomScale = 1.0;
        scroll.bounces = NO;
        scroll.delegate = self;
        scroll.backgroundColor = [UIColor clearColor];
        _gestureScroll = scroll;
        [self addSubview:scroll];

        UIPinchGestureRecognizer *pinGesture =
            [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(chartDidZooming:)];
        [_gestureScroll addGestureRecognizer:pinGesture];

        UITapGestureRecognizer *tapGesture =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chartDidTapping:)];
        tapGesture.numberOfTapsRequired = 1;
        [_gestureScroll addGestureRecognizer:tapGesture];
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _newPinScale = 1.0;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self redraw];
}

- (void)chartDidZooming:(UIPinchGestureRecognizer *)pinGesture {
    [self removeTipView];
}

- (void)redraw {
    [_containerView removeFromSuperview];
    _containerView = nil;
    _containerView = [[UIView alloc] initWithFrame:self.bounds];
    _containerView.backgroundColor = [UIColor clearColor];

    [self insertSubview:_containerView belowSubview:_gestureScroll];
    [self findBeginAndEndIndex];
    [self calculateMaxAndMinValue];
    [self calculateDataSegment]; //根据最大和最小值，决定正轴和负轴分别应该画几条分段线，并计算每条分段线的递进值
    [self addAxisLayer];
    [self addAxisScaleLayer];
    [self addDataLayer];
    [self addDataScaleLayer];
    [self drawDataPoint];
    if (self.hadTapped) { //重绘目前选中的点
        [self updateSelectedGroup:_tappedGroup item:_tappedItem]; //更新选中的点
        [self updateTipLayer:self.tappedGroup item:self.tappedItem]; //更新提示框
    }
}
- (void)chartDidTapping:(UITapGestureRecognizer *)tapGesture {
    CGPoint tapP = [tapGesture locationInView:self.gestureScroll];
    NSDictionary *groupItemDict = [self tappedGroupAndItem:tapP];
    if (!groupItemDict) return;
    if (_hadTapped && [[groupItemDict objectForKey:@"group"] integerValue] == _tappedGroup && [[groupItemDict objectForKey:@"item"] integerValue] == _tappedItem) {
        _hadTapped = NO; //重复点击同一个时，取消选中
        [self removeTipView];
        [self removeSelectedLayer];
    } else {
        _hadTapped = YES;
    }
    _tappedGroup = [[groupItemDict objectForKey:@"group"] integerValue];
    _tappedItem = [[groupItemDict objectForKey:@"item"] integerValue];
    if (_hadTapped) {
        [self saveTapPointRatio:tapP group:_tappedGroup item:_tappedItem];
        [self updateSelectedGroup:_tappedGroup item:_tappedItem];
        [self updateTipLayer:_tappedGroup item:_tappedItem];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapChart:group:item:)]) {
        [self.delegate didTapChart:self group:_tappedGroup item:_tappedItem];
    }
}
- (void)saveTapPointRatio:(CGPoint)tapP group:(NSUInteger)group item:(NSUInteger)item {
    self.pointRatio = YHTapPointRatioInItemMake(0, 0);
}
- (void)removeTipView {
    UIView *existedV = [self.gestureScroll viewWithTag:101];
    [existedV removeFromSuperview];
}
- (void)removeSelectedLayer {
    UIView *subContainer = [self.containerView viewWithTag:102];
    NSArray *subLayers = subContainer.layer.sublayers;
    if (!subLayers || !subLayers.count) return;
    for (NSUInteger i=subLayers.count-1;i>0;i--) {
        CALayer *layer = subLayers[i];
        if (layer.name && ([layer.name isEqualToString:@"mask"])) {
            [layer removeFromSuperlayer];
            break;
        }
    }
}
- (NSDictionary *)tappedGroupAndItem:(CGPoint)tapP {
    NSUInteger group = 0, item = 0;
    return @{ @"group": @(group), @"item": @(item) };
}
- (void)updateSelectedGroup:(NSUInteger)group item:(NSUInteger)item {
    
}
- (void)updateTipLayer:(NSUInteger)group item:(NSUInteger)item {
    [self removeTipView];
    NSDictionary *dataDict = [self prepareTipViewTexts:group item:item];
    NSString *groupStr = [dataDict objectForKey:@"groupStr"];
    NSString *axisStr = [dataDict objectForKey:@"axisStr"];
    NSString *dataStr = [dataDict objectForKey:@"dataStr"];
    
    CGFloat tipTextH = 11;
    CGFloat arrowH = 5;
    CGFloat tipH = TipViewPadding*2 + 2 * tipTextH + arrowH;
    CGFloat tipMaxW = [axisStr measureTextWidth:[UIFont systemFontOfSize:9]];
    tipMaxW = MAX(tipMaxW, [dataStr measureTextWidth:[UIFont systemFontOfSize:9]]);
    if (groupStr.length) {
        tipMaxW = MAX(tipMaxW, [groupStr measureTextWidth:[UIFont systemFontOfSize:9]]);
        tipH += tipTextH;
    }
    tipMaxW = tipMaxW > ChartWidth ? ChartWidth : tipMaxW;
    tipMaxW += TipViewPadding*2;

    NSUInteger arrowP = 2; //箭头在中间位置
    CGPoint tempP = [self adjustTipViewLocation:group item:item];
    CGFloat originX = tempP.x - tipMaxW / 2.0;
    if (originX < self.leftEdge) {
        originX = tempP.x;
        arrowP = 1; //箭头在左边位置
        if ((originX+self.leftEdge) < self.leftEdge) {
            return;
        }
    } else if (tempP.x + tipMaxW / 2.0 > ChartWidth + self.leftEdge) {
        originX = tempP.x - tipMaxW;
        arrowP = 3; //箭头在右边位置
        if (originX>(self.leftEdge+ChartWidth)) {
            return;
        }
    }

    CGFloat originY = tempP.y - tipH;
    if (originY < TopEdge) {
        originY = tempP.y;
        arrowP += 10; //箭头在弹窗上方
    }
    CGPoint contentOffset = self.gestureScroll.contentOffset;
    UIView *tipView = [[UIView alloc] initWithFrame:CGRectMake(contentOffset.x + originX- self.leftEdge, contentOffset.y + originY - TopEdge, tipMaxW, tipH)];
    tipView.backgroundColor = [UIColor clearColor];
    tipView.tag = 101;
    [self.gestureScroll addSubview:tipView];

    CAShapeLayer *rectLayer = [CAShapeLayer layer];
    CGSize cornerRadii = CGSizeMake(3, 3);
    UIBezierPath *rectPath;
    CGRect rectFrame;
    if (arrowP > 10) {
        rectFrame = CGRectMake(0, 5, tipMaxW, tipH - 5);
    } else {
        rectFrame = CGRectMake(0, 0, tipMaxW, tipH - 5);
    }
    if (self.showTipViewArrow) {
        rectPath = [UIBezierPath bezierPathWithRect:rectFrame];
        CGRect topRect = CGRectMake(0, 0, tipMaxW, tipH - 5);
        CGRect bottomRect = CGRectMake(0, 5, tipMaxW, tipH - 5);
        switch (arrowP) {
            case 1: { //左下箭头
                rectPath = [UIBezierPath
                            bezierPathWithRoundedRect:topRect
                            byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomRight
                            cornerRadii:cornerRadii];
                [self drawArrow:rectPath
                         startP:CGPointMake(0, tipH - 5)
                        middleP:CGPointMake(0, tipH)
                           endP:CGPointMake(2.5, tipH - 5)];
            } break;
            case 2: { //中下箭头
                rectPath = [UIBezierPath bezierPathWithRoundedRect:topRect
                                                 byRoundingCorners:UIRectCornerAllCorners
                                                       cornerRadii:cornerRadii];
                [self drawArrow:rectPath
                         startP:CGPointMake(tipMaxW / 2 - 2.5, tipH - 5)
                        middleP:CGPointMake(tipMaxW / 2, tipH)
                           endP:CGPointMake(tipMaxW / 2 + 2.5, tipH - 5)];
            } break;
            case 3: { //右下箭头
                rectPath = [UIBezierPath
                            bezierPathWithRoundedRect:topRect
                            byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft
                            cornerRadii:cornerRadii];
                [self drawArrow:rectPath
                         startP:CGPointMake(tipMaxW - 2.5, tipH - 5)
                        middleP:CGPointMake(tipMaxW, tipH)
                           endP:CGPointMake(tipMaxW, tipH - 5)];
            } break;
            case 11: { //左上箭头
                rectPath = [UIBezierPath
                            bezierPathWithRoundedRect:bottomRect
                            byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerTopRight | UIRectCornerBottomRight
                            cornerRadii:cornerRadii];
                [self drawArrow:rectPath startP:CGPointMake(0, 5) middleP:CGPointMake(0, 0) endP:CGPointMake(2.5, 5)];
            } break;
            case 12: { //中上箭头
                rectPath = [UIBezierPath bezierPathWithRoundedRect:bottomRect
                                                 byRoundingCorners:UIRectCornerAllCorners
                                                       cornerRadii:cornerRadii];
                [self drawArrow:rectPath
                         startP:CGPointMake(tipMaxW / 2 - 2.5, 5)
                        middleP:CGPointMake(tipMaxW / 2, 0)
                           endP:CGPointMake(tipMaxW / 2 + 2.5, 5)];
            } break;
            case 13: { //右上箭头
                rectPath = [UIBezierPath
                            bezierPathWithRoundedRect:bottomRect
                            byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft | UIRectCornerBottomRight
                            cornerRadii:cornerRadii];
                [self drawArrow:rectPath
                         startP:CGPointMake(tipMaxW - 2.5, 5)
                        middleP:CGPointMake(tipMaxW, 0)
                           endP:CGPointMake(tipMaxW, 5)];
            } break;
                
            default:
                break;
        }
    } else {
        rectPath = [UIBezierPath bezierPathWithRoundedRect:rectFrame cornerRadius:cornerRadii.width];
    }
    
    rectLayer.path = rectPath.CGPath;
    rectLayer.fillColor = [UIColor hexChangeFloat:self.tipViewBackgroundHexColor alpha:self.tipViewBackgroundColorAlpha].CGColor;
    [tipView.layer addSublayer:rectLayer];

    CGFloat startY = TipViewPadding;
    if (arrowP > 10) {
        startY += 5;
    }
    if (groupStr.length) {
        CGRect textFrame = CGRectMake(TipViewPadding, startY, tipMaxW - 10, tipTextH);
        CATextLayer *text = [self getTextLayerWithString:groupStr
                                               textColor:TipTextColor
                                                fontSize:TipTextFont
                                         backgroundColor:[UIColor clearColor]
                                                   frame:textFrame
                                           alignmentMode:kCAAlignmentLeft];
        [tipView.layer addSublayer:text];
        startY += tipTextH;
    }
    CATextLayer *axisText = [self getTextLayerWithString:axisStr
                                               textColor:TipTextColor
                                                fontSize:TipTextFont
                                         backgroundColor:[UIColor clearColor]
                                                   frame:CGRectMake(TipViewPadding, startY, tipMaxW - 10, tipTextH)
                                           alignmentMode:kCAAlignmentLeft];
    [tipView.layer addSublayer:axisText];
    CATextLayer *dataText = [self getTextLayerWithString:dataStr
                                               textColor:TipTextColor
                                                fontSize:TipTextFont
                                         backgroundColor:[UIColor clearColor]
                                                   frame:CGRectMake(TipViewPadding, startY + tipTextH, tipMaxW - 10, tipTextH)
                                           alignmentMode:kCAAlignmentLeft];
    [tipView.layer addSublayer:dataText];
}
- (void)drawArrow:(UIBezierPath *)path startP:(CGPoint)startP middleP:(CGPoint)middleP endP:(CGPoint)endP {
    [path moveToPoint:startP];
    [path addLineToPoint:middleP];
    [path addLineToPoint:endP];
}

- (NSDictionary *)prepareTipViewTexts:(NSUInteger)group item:(NSUInteger)item {
    NSString *groupStr = @"";
    if (self.groupMembers.count > 1) {
        groupStr = [NSString stringWithFormat:@"%@: %@", self.groupDimension, self.groupMembers[item]];
    }
    NSString *axisStr = [NSString stringWithFormat:@"%@: %@", self.axisTitle, self.AxisArray[group]];
    NSString *data = [[self.Datas[item] objectAtIndex:group] respondsToSelector:@selector(floatValue)]
    ? [self.Datas[item] objectAtIndex:group]
    : @"N/A";
    NSString *dataStr = [NSString stringWithFormat:@"%@: %@", self.dataTitle, data];
    
    return @{ @"groupStr": groupStr, @"axisStr": axisStr, @"dataStr": dataStr };
}
- (CGPoint)adjustTipViewLocation:(NSUInteger)group item:(NSUInteger)item {
    return CGPointZero;
}

- (void)findBeginAndEndIndex {
    [self findGroupAndItemIndex];

    if (self.beginGroupIndex < 0) {
        self.beginGroupIndex = 0;
    }
    if (self.beginItemIndex < 0) {
        self.beginItemIndex = 0;
    }
    if (self.beginItemIndex > self.Datas.count) {
        self.beginItemIndex = self.Datas.count - 1;
    }
    if (self.endItemIndex < 0) {
        self.endItemIndex = 0;
    }
    if (self.endItemIndex > self.Datas.count) {
        self.endItemIndex = self.Datas.count - 1;
    }

    if (self.endGroupIndex > [self.Datas[0] count] - 1) {
        self.endGroupIndex = [self.Datas[0] count] - 1;
    }
    if (self.beginGroupIndex > self.endGroupIndex) {
        self.beginGroupIndex = self.endGroupIndex;
    }
}
- (void)findGroupAndItemIndex {
    self.beginGroupIndex = 0;
    self.endGroupIndex = 0;
    self.beginItemIndex = 0;
    self.endItemIndex = 0;
}
- (void)calculateMaxAndMinValue {
    self.minDataValue = 0;
    self.maxDataValue = 0;
}
- (void)compareBeginAndEndItemValue:(NSUInteger)beginItem endItem:(NSUInteger)endItem isBeginGroup:(BOOL)isBeginGroup {
    for (NSUInteger i = beginItem; i <= endItem; i++) {
        NSUInteger index = isBeginGroup ? self.beginGroupIndex : self.endGroupIndex;
        CGFloat tempValue = [self dataAtGroup:index item:i];
        self.minDataValue = MIN(self.minDataValue, tempValue);
        self.maxDataValue = MAX(self.maxDataValue, tempValue);
    }
}
- (void)campareMaxAndMinValue:(NSUInteger)leftIndex rightIndex:(NSUInteger)rightIndex {
    for (NSArray *values in self.Datas) {
        [self findMaxAndMinValue:leftIndex rightIndex:rightIndex compareA:values];
    }
}
- (void)findMaxAndMinValue:(NSUInteger)leftIndex rightIndex:(NSUInteger)rightIndex compareA:(NSArray *)compareA {
    if (leftIndex > rightIndex) {
        leftIndex = rightIndex;
    }
    CGFloat leftValue = [self verifyDataValue:compareA[leftIndex]];
    CGFloat rightValue = [self verifyDataValue:compareA[rightIndex]];
    if (leftIndex == rightIndex) {
        self.minDataValue = MIN(leftValue, self.minDataValue);
        self.maxDataValue = MAX(leftValue, self.maxDataValue);
        return;
    } else if (leftIndex == rightIndex - 1) {
        if (leftValue < rightValue) {
            self.minDataValue = MIN(leftValue, self.minDataValue);
            self.maxDataValue = MAX(rightValue, self.maxDataValue);
            return;
        } else {
            self.minDataValue = MIN(rightValue, self.minDataValue);
            self.maxDataValue = MAX(leftValue, self.maxDataValue);
            return;
        }
    }
    NSUInteger mid = (leftIndex + rightIndex) / 2;
    [self findMaxAndMinValue:leftIndex rightIndex:mid compareA:compareA];
    [self findMaxAndMinValue:mid + 1 rightIndex:rightIndex compareA:compareA];
}

- (void)calculateDataSegment {
    if (self.minDataValue >= 0) {
        _dataPostiveSegmentNum = self.valueInterval;
        if (self.maxDataValue <= 1) {
            _dataPostiveSegmentNum = 1;
        }
        _dataNegativeSegmentNum = 0;
        self.itemDataScale = ceil([self absoluteMaxValue:self.maxDataValue] / _dataPostiveSegmentNum);
    } else if (self.maxDataValue <= 0) {
        _dataPostiveSegmentNum = 0;
        _dataNegativeSegmentNum = self.valueInterval;
        if (fabs(self.minDataValue) <= 1) {
            _dataNegativeSegmentNum = 1;
        }
        self.itemDataScale = ceil([self absoluteMaxValue:self.minDataValue] / _dataNegativeSegmentNum);
    } else if (self.maxDataValue >= fabs(self.minDataValue)) {
        _dataPostiveSegmentNum = self.valueInterval;
        if (self.maxDataValue <= 1) {
            _dataPostiveSegmentNum = 1;
        }
        self.itemDataScale = ceil([self absoluteMaxValue:self.maxDataValue] / _dataPostiveSegmentNum);
        _dataNegativeSegmentNum = ceil(fabs(self.minDataValue) / self.itemDataScale);
    } else {
        _dataNegativeSegmentNum = self.valueInterval;
        if (fabs(self.minDataValue) <= 1) {
            _dataNegativeSegmentNum = 1;
        }
        self.itemDataScale = ceil([self absoluteMaxValue:self.minDataValue] / _dataNegativeSegmentNum);
        _dataPostiveSegmentNum = ceil(self.maxDataValue / self.itemDataScale);
    }
}
- (NSUInteger)absoluteMaxValue:(CGFloat)value {
    CGFloat maxNum = fabs(value);
    NSString *str = [NSString stringWithFormat:@"%.0f", ceilf(maxNum)];
    NSUInteger tenCube = 1;
    if (str.length > 2) {
        tenCube = pow(10, str.length - 2);
    }
    return ceil(ceil(maxNum / tenCube) / self.valueInterval) * self.valueInterval * tenCube;
}
- (void)drawDataPoint {
}
- (void)addAxisLayer {
}
- (void)addAxisScaleLayer {
}
- (void)addDataLayer {
}
- (NSString *)adjustScaleValue:(NSUInteger)scaleValue {
    NSString *tempStr = [NSString stringWithFormat:@"%ld", scaleValue];
    NSUInteger length = tempStr.length;
    if (3 < length && length < 7) {
        if ([[tempStr substringWithRange:NSMakeRange(length - 3, 3)] isEqualToString:@"000"]) {
            return [NSString stringWithFormat:@"%@K", [tempStr substringToIndex:length - 3]];
        }
    } else if (length > 6 && length < 10) {
        if ([[tempStr substringWithRange:NSMakeRange(length - 6, 6)] isEqualToString:@"000000"]) {
            return [NSString stringWithFormat:@"%@M", [tempStr substringToIndex:length - 6]];
        } else if ([[tempStr substringWithRange:NSMakeRange(length - 3, 3)] isEqualToString:@"000"]) {
            return [NSString stringWithFormat:@"%@K", [tempStr substringToIndex:length - 3]];
        }
    } else if (length > 9) {
        if ([[tempStr substringWithRange:NSMakeRange(length - 9, 9)] isEqualToString:@"000000000"]) {
            return [NSString stringWithFormat:@"%@B", [tempStr substringToIndex:length - 9]];
        } else if ([[tempStr substringWithRange:NSMakeRange(length - 6, 6)] isEqualToString:@"000000"]) {
            return [NSString stringWithFormat:@"%@M", [tempStr substringToIndex:length - 6]];
        } else if ([[tempStr substringWithRange:NSMakeRange(length - 3, 3)] isEqualToString:@"000"]) {
            return [NSString stringWithFormat:@"%@K", [tempStr substringToIndex:length - 3]];
        }
    }
    return tempStr;
}
- (void)addDataScaleLayer {
}
- (CATextLayer *)getTextLayerWithString:(NSString *)text
                              textColor:(UIColor *)textColor
                               fontSize:(NSInteger)fontSize
                        backgroundColor:(UIColor *)bgColor
                                  frame:(CGRect)frame
                          alignmentMode:(NSString *)alignmentMode {
    CATextLayer *textLayer = [CATextLayer layer];
    textLayer.frame = frame;
    textLayer.string = text;
    textLayer.fontSize = fontSize;
    textLayer.foregroundColor = textColor.CGColor;
    textLayer.backgroundColor = bgColor.CGColor;
    textLayer.alignmentMode = alignmentMode;
    textLayer.wrapped = YES;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9) {
        textLayer.font = (__bridge CFTypeRef _Nullable)(@"PingFangSC-Regular");
    }
    //设置分辨率
    textLayer.contentsScale = [UIScreen mainScreen].scale;
    return textLayer;
}

- (CGFloat)calculateItemAxisScale {
    return 0;
}
- (CGFloat)zoomedItemAxis {
    return [self calculateItemAxisScale] * self.newPinScale * self.oldPinScale;
}

- (CGFloat)oldPinScale {
    if (_oldPinScale == 0) {
        _oldPinScale = 1.0;
    }
    return _oldPinScale;
}
- (CGFloat)newPinScale {
    if (_newPinScale == 0) {
        _newPinScale = 1.0;
    }
    return _newPinScale;
}
- (void)dealItemColors:(NSArray *)colors {
    if (!colors || !colors.count) {
        colors = [self defaultColors];
    }
    NSMutableArray *tempColors = [NSMutableArray arrayWithCapacity:self.Datas.count];
    for (NSUInteger i = 0; i < self.Datas.count; i++) {
        [tempColors addObject:colors[i % colors.count]];
    }
    _itemColors = [tempColors copy];
}
- (NSArray *)defaultColors {
    return @[
                        @"4698EB", @"A3DFFF", @"34C7C7", @"96EBEB", @"3BCC90", @"A4EBCD", @"80C25D", @"BBE390", @"FFA51F", @"FCCC79", @"F06260", @"FD9E9C", @"886FE7", @"B9A7FE"
    ];
    
}

- (CGFloat)dataItemUnitScale {
    return 0;
}

- (CGFloat)dataAtGroup:(NSUInteger)group item:(NSUInteger)item {
    if ([[self.Datas[item] objectAtIndex:group] respondsToSelector:@selector(floatValue)]) {
        return [[self.Datas[item] objectAtIndex:group] floatValue];
    }
    return 0;
}
- (CGFloat)verifyDataValue:(id)value {
    if ([value respondsToSelector:@selector(floatValue)]) {
        return [value floatValue];
    }
    return 0;
}

- (NSString *)layerTag:(NSUInteger)group item:(NSUInteger)item {
    return [NSString stringWithFormat:@"group%ld_item%ld",(unsigned long)group,(unsigned long)item];
}
- (BOOL)shouldHideAxisText {
    if (self.zoomedItemAxis < self.minWidthHideAxisText) return YES;
    return NO;
}
- (CGFloat)axisUnitScale {
    return ChartHeight / (self.dataNegativeSegmentNum + self.dataPostiveSegmentNum);
}
+ (BOOL)respondsFloatValueSelector:(id)idValue {
    if ([idValue respondsToSelector:@selector(floatValue)]) {
        return YES;
    }
    return NO;
}
- (CGFloat)defaultLeftEdge {
    return LeftEdge;
}
@end
