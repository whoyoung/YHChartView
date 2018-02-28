//
//  BaseChartViewController.h
//
//  Created by 杨虎 on 2018/2/27.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YHBaseChartView.h"

@interface BaseChartViewController : UIViewController<YHCommonChartViewDelegate>
@property (nonatomic, strong) YHBaseChartView *chartView;

@end
