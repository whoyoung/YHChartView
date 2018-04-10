//
//  NSString+YHCategory.h
//
//  Created by 杨虎 on 2018/2/5.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface NSString (YHCategory)
- (CGFloat)measureTextWidth:(UIFont *)desFont;
+ (BOOL)isEmpty:(NSString *)string;
+ (NSString *)md5:(NSString *)str;
@end
