//
//  UIColor+YHCategory.m
//
//  Created by 杨虎 on 2018/2/1.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "UIColor+YHCategory.h"

@implementation UIColor (YHCategory)
+ (UIColor *)hexChangeFloat:(NSString *)hexColor {
    if ([hexColor length] < 6) {
        return nil;
    }
    unsigned int redInt_, greenInt_, blueInt_;
    NSRange rangeNSRange_;
    rangeNSRange_.length = 2;  // 范围长度为2
    
    // 取红色的值
    rangeNSRange_.location = 0;
    [[NSScanner scannerWithString:[hexColor substringWithRange:rangeNSRange_]]
     scanHexInt:&redInt_];
    
    // 取绿色的值
    rangeNSRange_.location = 2;
    [[NSScanner scannerWithString:[hexColor substringWithRange:rangeNSRange_]]
     scanHexInt:&greenInt_];
    
    // 取蓝色的值
    rangeNSRange_.location = 4;
    [[NSScanner scannerWithString:[hexColor substringWithRange:rangeNSRange_]]
     scanHexInt:&blueInt_];
    
    return [UIColor colorWithRed:(float)(redInt_/255.0f)
                           green:(float)(greenInt_/255.0f)
                            blue:(float)(blueInt_/255.0f)
                           alpha:1.0f];
}
@end
