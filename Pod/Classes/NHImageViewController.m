//
//  NHImageViewController.m
//  Pods
//
//  Created by Sergey Minakov on 08.05.15.
//
//

#import "NHImageViewController.h"
#import "NHImageScrollView.h"

@interface NHImageViewController ()<UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, assign) UIModalPresentationStyle parentPresentationStyle;
@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) UIScrollView *pageScrollView;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) NSInteger pages;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, assign) CGPoint panGestureStartPoint;

@end

@implementation NHImageViewController

- (void)viewDidLoad {

     [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];

    self.pageScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.pageScrollView.backgroundColor = [UIColor redColor];
    self.pageScrollView.pagingEnabled = YES;
    self.pageScrollView.alwaysBounceHorizontal = NO;

    [self.view addSubview:self.pageScrollView];

    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 3 * self.view.bounds.size.width, self.view.bounds.size.height)];

    self.contentView.backgroundColor = [UIColor grayColor];

    [self.pageScrollView addSubview:self.contentView];

//    self.pageScrollView.contentSize = self.contentView.bounds.size;

//    self.pageScrollView.scrollEnabled = NO;
//    self.pageScrollView.delaysContentTouches = NO;
//    self.pageScrollView.pinchGestureRecognizer.enabled = NO;
    for (int i = 0; i < 3; i++) {
        NHImageScrollView *scrollView = [[NHImageScrollView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width * i, 0, self.view.bounds.size.width, self.view.bounds.size.height) andImage:self.image];

        [self.contentView addSubview:scrollView];
    }
//    self.scrollView =
//    self.scrollView.backgroundColor = [UIColor clearColor];
//    self.scrollView.bounces = YES;
//    self.scrollView.alwaysBounceVertical = YES;
//    self.scrollView.minimumZoomScale = 1;
//    self.scrollView.maximumZoomScale = 5;
//    self.scrollView.delegate = self;
//    [self.view addSubview:self.scrollView];
    

    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    self.panGesture.delegate = self;
    [self.pageScrollView addGestureRecognizer:self.panGesture];
}

- (void)hideButtons {

}

- (void)displayButtons {

}

- (void)panGestureAction:(UIPanGestureRecognizer*)panGesture {
//    if (self.scrollView.zoomScale > self.scrollView.minimumZoomScale) {
//        return;
//    }

    CGPoint translation = [panGesture translationInView:self.pageScrollView];
//
//    if (translation.x >= translation.y) {
//        [panGesture setTranslation:CGPointZero inView:self.pageScrollView];
//        return;
//    }

    CGPoint velocity = [panGesture velocityInView:self.pageScrollView];

    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
            self.panGestureStartPoint = self.pageScrollView.center;
        case UIGestureRecognizerStateChanged: {

            [self hideButtons];

            self.pageScrollView.panGestureRecognizer.enabled = NO;
            self.pageScrollView.pinchGestureRecognizer.enabled = NO;

            self.pageScrollView.center = CGPointMake(self.panGestureStartPoint.x, self.panGestureStartPoint.y + translation.y);

            CGFloat value = ABS(self.view.bounds.size.height / 2.0 - self.pageScrollView.center.y) / (self.view.bounds.size.height / 2.0) / 3.0;


            self.view.backgroundColor = [self.view.backgroundColor colorWithAlphaComponent:1 - value];
        } break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:

            self.pageScrollView.panGestureRecognizer.enabled = YES;
            self.pageScrollView.pinchGestureRecognizer.enabled = YES;

            if (ABS(velocity.y) > 1000) {
                [UIView animateWithDuration:0.3
                                      delay:0
                                    options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionTransitionNone
                                 animations:^{
                                     self.pageScrollView.center = CGPointMake(self.panGestureStartPoint.x,
                                                                          1.5 * self.pageScrollView.frame.size.height * (velocity.y < 0 ? -1 : 1));
                                 } completion:^(BOOL finished) {
                                     [self dismissViewControllerAnimated:YES completion:nil];
                                 }];


            }
            else {
                if (self.pageScrollView.center.y < 0) {
                    [UIView animateWithDuration:0.3
                                          delay:0
                                        options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionTransitionNone
                                     animations:^{
                                         self.pageScrollView.center = CGPointMake(self.panGestureStartPoint.x,
                                                                              -1.5 * self.pageScrollView.frame.size.height);
                                     } completion:^(BOOL finished) {
                                         [self dismissViewControllerAnimated:YES completion:nil];
                                     }];
                }
                else if (self.pageScrollView.center.y > self.view.bounds.size.height) {
                    [UIView animateWithDuration:0.3
                                          delay:0
                                        options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionTransitionNone
                                     animations:^{
                                         self.pageScrollView.center = CGPointMake(self.panGestureStartPoint.x,
                                                                              1.5 * self.pageScrollView.frame.size.height);
                                     } completion:^(BOOL finished) {
                                         [self dismissViewControllerAnimated:YES completion:nil];
                                     }];
                }
                else {
                    [UIView animateWithDuration:0.3
                                          delay:0
                                        options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionTransitionNone
                                     animations:^{
                                         self.view.backgroundColor = [UIColor blackColor];
                                         self.pageScrollView.center = self.panGestureStartPoint;
                                     } completion:^(BOOL finished) {
                                         [self displayButtons];
                                     }];
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

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

//    [self.pageScrollView setZoomScale:1 animated:YES];
    self.pageScrollView.frame = self.view.bounds;
    self.contentView.frame = CGRectMake(0, 0, 3 * self.pageScrollView.frame.size.width, self.pageScrollView.frame.size.height);
    self.pageScrollView.contentSize = self.contentView.bounds.size;

    [self.contentView.subviews enumerateObjectsUsingBlock:^(NHImageScrollView *obj, NSUInteger idx, BOOL *stop) {
        obj.frame = CGRectMake(self.view.bounds.size.width * idx, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        [obj sizeContent];
    }];
//        NHImageScrollView *scrollView = [[NHImageScrollView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width * i, 0, self.view.bounds.size.width, self.view.bounds.size.height) andImage:self.image];
//
//        [self.contentView addSubview:scrollView];
//    }

    [self.view layoutIfNeeded];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {

    UIViewController *presentingViewController = self.presentingViewController;

    [super dismissViewControllerAnimated:flag completion:^{
        if (completion) {
            completion();
        }

        presentingViewController.modalPresentationStyle = self.parentPresentationStyle;
    }];
}

+ (void)showImage:(UIImage*)image inViewController:(UIViewController*)controller {
    NHImageViewController *imageViewController = [[NHImageViewController alloc] init];
    imageViewController.image = image;
    imageViewController.parentPresentationStyle = controller.modalPresentationStyle;
    controller.modalPresentationStyle = UIModalPresentationCurrentContext;
    imageViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    imageViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;

    [controller presentViewController:imageViewController animated:YES completion:nil];

}

@end
