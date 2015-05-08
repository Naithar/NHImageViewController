//
//  NHImageViewController.m
//  Pods
//
//  Created by Sergey Minakov on 08.05.15.
//
//

#import "NHImageViewController.h"
//
//#define currentOrientation \
//([UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height) \
//? UIDeviceOrientationLandscapeLeft \
//: UIDeviceOrientationPortrait


@interface NHImageViewController ()<UIScrollViewDelegate>

@property (nonatomic, copy) UIImage *image;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *contentView;

@end

@implementation NHImageViewController

- (void)viewDidLoad {

    self.view.backgroundColor = [UIColor redColor];

    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.backgroundColor = [UIColor greenColor];
    self.scrollView.bounces = YES;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.alwaysBounceHorizontal = YES;
    self.scrollView.minimumZoomScale = 1;
    self.scrollView.maximumZoomScale = 5;
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];

    self.contentView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.contentView.image = self.image;
    self.contentView.contentMode = UIViewContentModeScaleAspectFit;
    self.contentView.backgroundColor = [UIColor blackColor];

    [self.scrollView addSubview:self.contentView];

    [self sizeContent];

    [super viewDidLoad];
}

- (void)sizeContent {
    self.scrollView.frame = self.view.bounds;

    [self.contentView sizeToFit];

    CGRect bounds = self.contentView.frame;

    CGFloat ratio = bounds.size.width / bounds.size.height;

    if (ratio != 1) {
        if (self.scrollView.frame.size.height > self.scrollView.frame.size.width) {
            bounds.size.width = MIN(self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = MIN(self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    else {
        bounds.size.width = MIN(self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
        bounds.size.width -= 10;
        bounds.size.height = bounds.size.width;
    }

    self.contentView.frame = bounds;
    self.contentView.center = CGPointMake(self.scrollView.bounds.size.width / 2, self.scrollView.bounds.size.height / 2);
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    [self.scrollView setZoomScale:1 animated:YES];
    [self sizeContent];

    [self.view layoutIfNeeded];
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.contentView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

+ (void)showImage:(UIImage*)image inViewController:(UIViewController*)controller {
    NHImageViewController *imageViewController = [[NHImageViewController alloc] init];
    imageViewController.image = image;

    [controller presentViewController:imageViewController animated:YES completion:nil];

}

@end
