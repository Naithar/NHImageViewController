//
//  NViewController.m
//  NHImageViewController
//
//  Created by Naithar on 05/08/2015.
//  Copyright (c) 2014 Naithar. All rights reserved.
//

#import "NViewController.h"
#import <NHImageViewController.h>

@interface NViewController ()

@property (weak, nonatomic) UIWindow *topWindow;


@end

@implementation NViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NHImageViewController presentIn:self
                                withData:@[
                                           @"https://psv4.vk.me/c423527/u90579525/docs/83c70ccbc9e7/Heres-my-favorite-nope-gif.gif?extra=XMxjKubZSWK1h1FdthBd4b7Y1mDZUzx70z8581--w1PO3SMNwO2tUaqy3MVI5Yvbc_v2FZdRdS0VgjHnh4puQDk0-5zz",
                                           @"http://raphaelschaad.com/static/nyan.gif",
                                           @"http://wallpaperscraft.ru/image/kot_morda_ochki_tolstyy_65455_300x300.jpg",
                                           @"http://www.gabriela-biechl.at/images/pias%20aura-100x100-2004-sold.jpg",
                                           @"http://photos1.blogger.com/hello/113/2202/1024/Halloween2004%20086b.0.jpg",
                                           [NSURL URLWithString:@"http://fc01.deviantart.net/fs70/i/2012/244/e/a/20_icons_juniel_100x100__2_by_elfy08-d5d76bt.png"],
                                           [NSURL URLWithString:@"http://www.thisiscolossal.com/wp-content/uploads/2015/03/florian-8.gif"]
                                           ]
                                 andNote:nil] setStartingPage:3];
    });
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeLeft;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (BOOL)shouldAutorotate {
    return NO;
}

@end
