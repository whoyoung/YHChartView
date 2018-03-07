//
//  YHBaseBarChartView.m
//  YHChartViewDemo
//
//  Created by 杨虎 on 2018/3/7.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "YHBaseBarChartView.h"

@implementation YHBaseBarChartView

- (void)dealStyleDict:(NSDictionary *)styleDict {
    NSDictionary *barStyle = [styleDict objectForKey:@"barStyle"];
    BOOL isStack = [[barStyle objectForKey:@"stack"] boolValue];
    if (isStack) {
        _chartType = BarChartTypeStack;
    } else if (self.Datas.count > 1) {
        _chartType = BarChartTypeGroup;
    } else {
        _chartType = BarChartTypeSingle;
    }
    
    _groupSpaceDivideBarWidth = [barStyle objectForKey:@"groupSpaceDivideBarWidth"] ? [[barStyle objectForKey:@"groupSpaceDivideBarWidth"] floatValue] : 0.25;
    _barColorAlpha = [barStyle objectForKey:@"barColorAlpha"] ? [[barStyle objectForKey:@"barColorAlpha"] floatValue] : BarAlpha;
    _showBarGroupSeparateLine = [barStyle objectForKey:@"showBarGroupSeparateLine"] ? [[barStyle objectForKey:@"showBarGroupSeparateLine"] boolValue] : YES;
    _separateLineDivideGroupSpace = [barStyle objectForKey:@"separateLineDivideGroupSpace"] ? [[barStyle objectForKey:@"separateLineDivideGroupSpace"] floatValue] : 0.2;
    _seperateLineWidth = [barStyle objectForKey:@"seperateLineWidth"] ? [[barStyle objectForKey:@"seperateLineWidth"] floatValue] : 1;
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
                    CGFloat value = [self dataAtGroup:self.beginGroupIndex item:i];
                    if (value < 0) {
                        self.minDataValue += value;
                    } else {
                        self.maxDataValue += value;
                    }
                }
            } else {
                NSMutableArray *minDataValues =
                [NSMutableArray arrayWithCapacity:(self.endGroupIndex - self.beginGroupIndex + 1)];
                NSMutableArray *maxDataValues =
                [NSMutableArray arrayWithCapacity:(self.endGroupIndex - self.beginGroupIndex + 1)];
                
                for (NSUInteger i = self.beginGroupIndex; i <= self.endGroupIndex; i++) {
                    CGFloat tempMinValue = 0, tempMaxValue = 0;
                    for (NSUInteger j = 0; j < self.Datas.count; j++) {
                        CGFloat value = [self dataAtGroup:i item:j];
                        if (value < 0) {
                            tempMinValue += value;
                        } else {
                            tempMaxValue += value;
                        }
                    }
                    [minDataValues addObject:[NSString stringWithFormat:@"%f", tempMinValue]];
                    [maxDataValues addObject:[NSString stringWithFormat:@"%f", tempMaxValue]];
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

- (void)updateSelectedGroup:(NSUInteger)group item:(NSUInteger)item {
    UIView *subContainer = [self.containerView viewWithTag:102];
    NSArray *subLayers = subContainer.layer.sublayers;
    for (NSUInteger i=subLayers.count;i>0;i--) {
        CALayer *layer = subLayers[i-1];
        if ([layer.name isEqualToString:[self layerTag:group item:item]]) {
            CAShapeLayer *shapeLayer = (CAShapeLayer *)layer;
            
            CAShapeLayer *maskLayer = [CAShapeLayer layer];
            maskLayer.path = shapeLayer.path;
            maskLayer.lineWidth = shapeLayer.lineWidth;
            maskLayer.fillColor = [UIColor hexChangeFloat:@"808080" alpha:0.6].CGColor;
            maskLayer.name = @"mask";
            [subContainer.layer addSublayer:maskLayer];
        } else if ([layer isKindOfClass:[CAShapeLayer class]] && [layer.name isEqualToString:@"mask"]) {
            [layer removeFromSuperlayer];
        }
    }
}
- (BOOL)shouldHideAxisText {
    if (self.chartType == BarChartTypeGroup) {
        if (self.Datas.count * self.zoomedItemAxis < self.minWidthHideAxisText) return YES;
        return NO;
    } else {
        if (self.zoomedItemAxis < self.minWidthHideAxisText) return YES;
        return NO;
    }
}
- (CGFloat)groupSpace {
    return self.zoomedItemAxis * self.groupSpaceDivideBarWidth;
}
@end
