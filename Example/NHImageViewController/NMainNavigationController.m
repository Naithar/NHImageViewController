//
//  NMainNavigationController.m
//  NHImageViewController
//
//  Created by Sergey Minakov on 07.10.15.
//  Copyright © 2015 Naithar. All rights reserved.
//

#import "NMainNavigationController.h"

@interface NMainNavigationController ()

@end

@implementation NMainNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeLeft;
}

@end
