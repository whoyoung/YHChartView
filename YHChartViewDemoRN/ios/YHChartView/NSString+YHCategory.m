//
//  NSString+YHCategory.m
//
//  Created by 杨虎 on 2018/2/5.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "NSString+YHCategory.h"

@implementation NSString (YHCategory)
- (CGFloat)measureTextWidth:(UIFont *)desFont {
    NSDictionary *attribute = @{NSFontAttributeName: desFont};
    CGSize size = (CGSize)[self boundingRectWithSize:CGSizeMake(MAXFLOAT, desFont.lineHeight) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    return size.width;
}
@end
