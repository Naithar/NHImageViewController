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


@interface NHImageViewController ()<UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, copy) UIImage *image;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *contentView;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic, assign) CGPoint panGestureStartPoint;

@end

@implementation NHImageViewController

- (void)viewDidLoad {

    self.view.backgroundColor = [UIColor redColor];

    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.backgroundColor = [UIColor greenColor];
    self.scrollView.bounces = YES;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.minimumZoomScale = 1;
    self.scrollView.maximumZoomScale = 5;
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];

    self.contentView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.contentView.image = self.image;
    self.contentView.contentMode = UIViewContentModeScaleAspectFit;
    self.contentView.backgroundColor = [UIColor blackColor];

    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    self.panGesture.delegate = self;
    [self.scrollView addGestureRecognizer:self.panGesture];

    [self.scrollView addSubview:self.contentView];

    [self sizeContent];

    [super viewDidLoad];
}

- (void)panGestureAction:(UIPanGestureRecognizer*)panGesture {
    NSLog(@"action");

    if (self.scrollView.zoomScale > self.scrollView.minimumZoomScale) {
        return;
    }

//    CGPoint currentPoint = [panGesture locationInView:self.scrollView];
    CGPoint translation = [panGesture translationInView:self.scrollView];
    CGPoint velocity = [panGesture velocityInView:self.scrollView];

    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
            self.panGestureStartPoint = self.scrollView.center;
        case UIGestureRecognizerStateChanged:

            self.scrollView.panGestureRecognizer.enabled = NO;
            self.scrollView.pinchGestureRecognizer.enabled = NO;

            self.scrollView.center = CGPointMake(self.panGestureStartPoint.x, self.panGestureStartPoint.y + translation.y);
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:

            self.scrollView.panGestureRecognizer.enabled = YES;
            self.scrollView.pinchGestureRecognizer.enabled = YES;


            if (ABS(velocity.y) > 500) {
                [UIView animateWithDuration:0.3
                                      delay:0
                                    options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionTransitionNone
                                 animations:^{
                                     self.scrollView.center = CGPointMake(self.panGestureStartPoint.x,
                                                                          2 * self.scrollView.frame.size.height * (velocity.y < 0 ? -1 : 1));
                                 } completion:^(BOOL finished) {
                                     [self dismissViewControllerAnimated:YES completion:nil];
                                 }];


            }
            else {
                if (self.scrollView.center.y < 0) {
                    [UIView animateWithDuration:0.3
                                          delay:0
                                        options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionTransitionNone
                                     animations:^{
                                         self.scrollView.center = CGPointMake(self.panGestureStartPoint.x,
                                                                              -2 * self.scrollView.frame.size.height);
                                     } completion:^(BOOL finished) {
                                         [self dismissViewControllerAnimated:YES completion:nil];
                                     }];
                }
                else if (self.scrollView.center.y > self.view.bounds.size.height) {
                    [UIView animateWithDuration:0.3
                                          delay:0
                                        options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionTransitionNone
                                     animations:^{
                                         self.scrollView.center = CGPointMake(self.panGestureStartPoint.x,
                                                                              2 * self.scrollView.frame.size.height);
                                     } completion:^(BOOL finished) {
                                         [self dismissViewControllerAnimated:YES completion:nil];
                                     }];
                }
                else {
                    [UIView animateWithDuration:0.3
                                          delay:0
                                        options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionTransitionNone
                                     animations:^{
                                         self.scrollView.center = self.panGestureStartPoint;
                                     } completion:nil];
                }
            }
            break;
        default:
            break;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return gestureRecognizer.view == otherGestureRecognizer.view;
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

    [self scrollViewDidZoom:self.scrollView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    [self.scrollView setZoomScale:1 animated:YES];
    [self sizeContent];

    [self.view layoutIfNeeded];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if (scrollView.zoomScale == 1) {
        self.scrollView.contentInset = UIEdgeInsetsZero;
        return;
    }

    CGSize zoomedSize = self.contentView.bounds.size;
    zoomedSize.width *= self.scrollView.zoomScale;
    zoomedSize.height *= self.scrollView.zoomScale;

    CGFloat verticalOffset = 0;
    CGFloat horizontalOffset = 0;

    if (zoomedSize.width < self.scrollView.bounds.size.width) {
        horizontalOffset = (self.scrollView.bounds.size.width - zoomedSize.width) / 2.0;
    }

    if (zoomedSize.height < self.scrollView.bounds.size.height) {
        verticalOffset = (self.scrollView.bounds.size.height - zoomedSize.height) / 2.0;
    }

    self.scrollView.contentInset = UIEdgeInsetsMake(verticalOffset - self.contentView.frame.origin.y,
                                                    horizontalOffset - self.contentView.frame.origin.x,
                                                    verticalOffset + self.contentView.frame.origin.y,
                                                    horizontalOffset + self.contentView.frame.origin.x);
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
