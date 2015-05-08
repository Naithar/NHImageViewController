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
@property (nonatomic, strong) NSArray *imagesArray;

@property (nonatomic, strong) UIScrollView *pageScrollView;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) NSInteger pages;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, assign) CGPoint panGestureStartPoint;

@property (strong, nonatomic) UIButton *closeButton;
@property (strong, nonatomic) UIButton *menuButton;

@property (nonatomic, assign) CGFloat pageSpacing;
@end

@implementation NHImageViewController

- (void)viewDidLoad {

     [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];

    self.pages = self.imagesArray.count;
    self.currentPage = 0;
    if (self.pageSpacing == 0) {
        self.pageSpacing = 5;
    }

    self.pageScrollView = [[UIScrollView alloc] initWithFrame:UIEdgeInsetsInsetRect(self.view.bounds, UIEdgeInsetsMake(0, -self.pageSpacing, 0, -self.pageSpacing))];
    self.pageScrollView.backgroundColor = [UIColor redColor];
    self.pageScrollView.pagingEnabled = YES;
    self.pageScrollView.alwaysBounceHorizontal = NO;
    self.pageScrollView.delegate = self;

    [self.view addSubview:self.pageScrollView];

    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.pages * self.pageScrollView.bounds.size.width, self.view.bounds.size.height)];

    self.contentView.backgroundColor = [UIColor grayColor];

    [self.pageScrollView addSubview:self.contentView];

    for (int i = 0; i < self.imagesArray.count; i++) {
        NHImageScrollView *scrollView = [[NHImageScrollView alloc] initWithFrame:CGRectMake(self.pageSpacing * (i + 1) + (self.view.bounds.size.width + self.pageSpacing) * i, 0, self.view.bounds.size.width, self.view.bounds.size.height) andImage:self.imagesArray[i]];

        [self.contentView addSubview:scrollView];
    }
    

    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    self.panGesture.delegate = self;
    [self.pageScrollView addGestureRecognizer:self.panGesture];

    self.closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 64)];
    self.closeButton.backgroundColor = [UIColor lightGrayColor];
    [self.closeButton setTitle:@"x" forState:UIControlStateNormal];
    [self.closeButton addTarget:self action:@selector(closeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.closeButton];

    self.menuButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 50, 0, 50, 64)];
    self.menuButton.backgroundColor = [UIColor lightGrayColor];
    [self.menuButton setTitle:@"o" forState:UIControlStateNormal];
    [self.menuButton addTarget:self action:@selector(menuButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.menuButton];
}

- (void)closeButtonAction:(UIButton*)button {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)menuButtonAction:(UIButton*)button {

}

- (void)hideButtons {
    CGRect closeButtonFrame = self.closeButton.frame;
    closeButtonFrame.origin.y = -64;

    CGRect menuButtonFrame = self.menuButton.frame;
    menuButtonFrame.origin.y = -64;

    [UIView animateWithDuration:0.2 animations:^{
        self.closeButton.frame = closeButtonFrame;
        self.menuButton.frame = menuButtonFrame;
    }];
}

- (void)displayButtons {
    CGRect closeButtonFrame = CGRectMake(0, 0, 50, 64);

    CGRect menuButtonFrame = CGRectMake(self.view.bounds.size.width - 50, 0, 50, 64);

    [UIView animateWithDuration:0.2 animations:^{
        self.closeButton.frame = closeButtonFrame;
        self.menuButton.frame = menuButtonFrame;
    }];
}

- (void)panGestureAction:(UIPanGestureRecognizer*)panGesture {
    CGPoint translation = [panGesture translationInView:self.pageScrollView];
//
    if (ABS(translation.x) >= ABS(translation.y)
        && CGPointEqualToPoint(self.panGestureStartPoint, CGPointZero)) {
        panGesture.enabled = NO;
        panGesture.enabled = YES;
        self.pageScrollView.panGestureRecognizer.enabled = YES;
        self.pageScrollView.pinchGestureRecognizer.enabled = YES;
        self.view.backgroundColor = [UIColor blackColor];
        self.pageScrollView.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
        self.panGestureStartPoint = CGPointZero;
        return;
    }

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

                    self.panGestureStartPoint = CGPointZero;
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

    NSInteger page = self.currentPage;
    
    self.pageScrollView.frame = UIEdgeInsetsInsetRect(self.view.bounds, UIEdgeInsetsMake(0, -self.pageSpacing, 0, -self.pageSpacing));
    self.contentView.frame = CGRectMake(0, 0, self.pages * self.pageScrollView.frame.size.width, self.pageScrollView.frame.size.height);
    self.pageScrollView.contentSize = self.contentView.bounds.size;

    [self.pageScrollView setNeedsDisplay];

    self.closeButton.frame = CGRectMake(0, 0, 50, 64);
    self.menuButton.frame = CGRectMake(self.view.bounds.size.width - 50, 0, 50, 64);

    NSLog(@"current page = %@", @(self.currentPage));
    self.pageScrollView.contentOffset = CGPointMake(page * self.pageScrollView.frame.size.width, 0);


    [self.contentView.subviews enumerateObjectsUsingBlock:^(NHImageScrollView *obj, NSUInteger idx, BOOL *stop) {
        [obj setZoomScale:1];
        obj.frame = CGRectMake(self.pageSpacing * (idx + 1) + (self.view.bounds.size.width + self.pageSpacing) * idx, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        [obj sizeContent];
    }];

    [self.view layoutSubviews];
    [self.view layoutIfNeeded];
    [self.view setNeedsDisplay];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger page = floor((scrollView.contentOffset.x) / scrollView.bounds.size.width);

    if (self.currentPage != page
        && page >= 0
        && page < self.pages) {
        [((NHImageScrollView*)self.contentView.subviews[self.currentPage]) setZoomScale:1 animated:YES];
        self.currentPage = page;
    }
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
    imageViewController.imagesArray = @[image, image];
    imageViewController.parentPresentationStyle = controller.modalPresentationStyle;
    controller.modalPresentationStyle = UIModalPresentationCurrentContext;
    imageViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    imageViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;

    [controller presentViewController:imageViewController animated:YES completion:nil];

}

@end
