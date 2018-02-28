//
//  YHCommonChartViewDelegate.h
//  ingage
//
//  Created by 杨虎 on 2018/2/2.
//  Copyright © 2018年 com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YHCommonChartViewDelegate <NSObject>
@optional
- (void)didTapChart:(id)chart group:(NSUInteger)group item:(NSUInteger)item;
@end
