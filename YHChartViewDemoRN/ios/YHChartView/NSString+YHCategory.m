//
//  NSString+YHCategory.m
//
//  Created by 杨虎 on 2018/2/5.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "NSString+YHCategory.h"
#import "sys/utsname.h"
#import <CommonCrypto/CommonCrypto.h>
@implementation NSString (YHCategory)
- (CGFloat)measureTextWidth:(UIFont *)desFont {
    NSDictionary *attribute = @{NSFontAttributeName: desFont};
    CGSize size = (CGSize)[self boundingRectWithSize:CGSizeMake(MAXFLOAT, desFont.lineHeight) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    return size.width;
}

+ (NSString *)md5:(NSString *)str {
  if ([NSString isEmpty:str]) {
    return nil;
  }
  const char *cStr = [str UTF8String];
  
  unsigned char result[16];
  
  CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
  
  return [NSString stringWithFormat:
          
          @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
          
          result[0], result[1], result[2], result[3],
          
          result[4], result[5], result[6], result[7],
          
          result[8], result[9], result[10], result[11],
          
          result[12], result[13], result[14], result[15]
          
          ];
}

+ (BOOL)isEmpty:(NSString *)string {
  if (![string isKindOfClass:[NSString class]]) {
    string = [string description];
  }
  if (string == nil || string == NULL) {
    return YES;
  }
  if ([string isKindOfClass:[NSNull class]]) {
    return YES;
  }
  if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
    return YES;
  }
  if ([string isEqualToString:@"(null)(null)"] || [string isEqualToString:@"<null>"]) {
    return YES;
  }
  return NO;
}
@end
