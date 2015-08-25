//
//  SurespotNavigationController.m
//  surespot
//
//  Created by Adam on 12/30/13.
//  Copyright (c) 2013 2fours. All rights reserved.
//

#import "SurespotNavigationController.h"
#import "SurespotConstants.h"

@implementation SurespotNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIColor *tintColor = [UIColor whiteColor];
    
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: tintColor};
    
    [self.navigationBar setBackgroundImage:[UIImage new] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage new];
    self.navigationBar.translucent = NO;
    self.navigationBar.barTintColor = [UIColor colorWithString:NAVBAR_COLOR];
    self.navigationBar.tintColor = tintColor;
}

-(NSUInteger)supportedInterfaceOrientations {
    UIViewController *top = self.topViewController;
    return top.supportedInterfaceOrientations;
}

-(BOOL)shouldAutorotate {
    UIViewController *top = self.topViewController;
    return [top shouldAutorotate];
}

@end
