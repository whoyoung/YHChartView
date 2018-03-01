//
//  XSYBarChartView.h
//  ingage
//
//  Created by 杨虎 on 2018/2/2.
//  Copyright © 2018年 com. All rights reserved.
//

#import <React/RCTComponent.h>
#import <UIKit/UIKit.h>

@interface XSYBarChartView : UIView
@property (nonatomic, copy) NSString *data;
@property (nonatomic, copy) RCTBubblingEventBlock onSelect;
@property (nonatomic, assign) BOOL hideTipView;
@end
