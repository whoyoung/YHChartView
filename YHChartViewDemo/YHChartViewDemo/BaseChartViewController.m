//
//  BaseChartViewController.m
//
//  Created by 杨虎 on 2018/2/27.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "BaseChartViewController.h"

@interface BaseChartViewController ()

@end

@implementation BaseChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    self.view.backgroundColor = [UIColor whiteColor];

}

- (void)didTapChart:(id)chart group:(NSUInteger)group item:(NSUInteger)item {
    NSLog(@"group=%ld, item=%ld",group,item);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    [self.chartView updateChartFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64)];
}
@end
