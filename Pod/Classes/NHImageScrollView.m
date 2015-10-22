//
//  NHImageScrollView.m
//  Pods
//
//  Created by Sergey Minakov on 08.05.15.
//
//

#import "NHImageScrollView.h"
#import <MACircleProgressIndicator/MACircleProgressIndicator.h>
#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/UIImage+GIF.h>

#define image(name) \
[UIImage imageWithContentsOfFile: \
[[NSBundle bundleForClass:[NHImageScrollView class]]\
pathForResource:name ofType:@"png"]]

@interface NHImageScrollView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView *contentView;
@property (nonatomic, strong) MACircleProgressIndicator *progressIndicator;
@property (nonatomic, assign) BOOL loadingImage;
@end

@implementation NHImageScrollView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];

    if (self) {
        [self commonInit];
    }

    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame image:nil andPath:nil];
}

- (instancetype)initWithFrame:(CGRect)frame andImage:(UIImage*)image {
    return [self initWithFrame:frame image:image andPath:nil];
}

- (instancetype)initWithFrame:(CGRect)frame andPath:(NSString*)path {
    return [self initWithFrame:frame image:nil andPath:path];
}

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage*)image andPath:(NSString*)path {
    self = [super initWithFrame:frame];

    if (self) {
        _image = image;
        _imagePath = path;
        [self commonInit];
    }

    return self;
}

- (void)commonInit {

    self.delegate = self;
    self.bounces = YES;
    self.alwaysBounceVertical = NO;
    self.alwaysBounceHorizontal = NO;
    self.minimumZoomScale = 1;
    self.maximumZoomScale = 5;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.backgroundColor = [UIColor clearColor];

    self.contentView = [[UIImageView alloc] init];
    self.contentView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.contentView];

    self.progressIndicator = [[MACircleProgressIndicator alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    self.progressIndicator.backgroundColor = [UIColor clearColor];
    self.progressIndicator.strokeWidth = 2;
    self.progressIndicator.color = [UIColor whiteColor];
    self.progressIndicator.center = CGPointMake(self.contentView.bounds.size.width / 2, self.contentView.bounds.size.height / 2);

    [self.contentView addSubview:self.progressIndicator];

    [self sizeContent];
    [self loadImage];
}

- (void)zoomToPoint:(CGPoint)point andScale:(CGFloat)scale {
    CGRect zoomRect = CGRectZero;

    zoomRect.size.width = self.bounds.size.width / scale;
    zoomRect.size.height = self.bounds.size.height / scale;

    zoomRect.origin.x = point.x - (zoomRect.size.width / 2);
    zoomRect.origin.y = point.y - (zoomRect.size.height / 2);

    [self zoomToRect:zoomRect animated:YES];

    [self setZoomScale:scale animated:YES];
}

- (void)sizeContent {
    [self.contentView sizeToFit];

    CGRect bounds = CGSizeEqualToSize(self.contentView.bounds.size, CGSizeZero)
    ? (CGRect) { .size = self.contentView.image.size }
    : self.contentView.bounds;

    if (bounds.size.height) {
        CGFloat ratio = bounds.size.width / bounds.size.height;

        if (ratio) {

            if (ratio > 1.5) {
                if (self.frame.size.height > self.frame.size.width) {
                    bounds.size.width = MIN(self.bounds.size.width, self.bounds.size.height) - 2;
                    bounds.size.height = bounds.size.width / ratio;
                }
                else {
                    bounds.size.width = MAX(self.bounds.size.width, self.bounds.size.height) - 2;
                    bounds.size.height = bounds.size.width / ratio;
                }
            }
            else if (ratio < 0.5) {
                if (self.frame.size.height > self.frame.size.width) {
                    bounds.size.height = MAX(self.bounds.size.width, self.bounds.size.height) - 2;
                    bounds.size.width = bounds.size.height * ratio;
                }
                else {
                    bounds.size.height = MIN(self.bounds.size.width, self.bounds.size.height) - 2;
                    bounds.size.width = bounds.size.height * ratio;
                }
            }
            else {
                if (self.frame.size.height > self.frame.size.width) {
                    bounds.size.width = MIN(self.bounds.size.width, self.bounds.size.height) - 2;
                    bounds.size.height = bounds.size.width / ratio;
                }
                else {
                    bounds.size.height = MIN(self.bounds.size.width, self.bounds.size.height) - 2;
                    bounds.size.width = bounds.size.height * ratio;
                }
            }
        }
    }

    self.contentView.frame = bounds;
    self.contentView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    self.contentSize = CGSizeZero;

    self.progressIndicator.center = CGPointMake(self.contentView.bounds.size.width / 2, self.contentView.bounds.size.height / 2);

    [self scrollViewDidZoom:self];
}

- (BOOL)saveImage {
    if (self.image) {
        UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil);
        return YES;
    }

    return NO;
}

- (void)loadImage {
    self.contentView.image = nil;
    self.loadingImage = NO;

    if (self.image) {
        [self showImage:self.image];
    }
    else if (self.imagePath
             && [self.imagePath length]) {
        
        self.progressIndicator.value = 0;
        self.progressIndicator.hidden = NO;
        self.loadingImage = YES;

        __weak __typeof(self) weakSelf = self;
        [SDWebImageManager.sharedManager
         downloadImageWithURL:[NSURL URLWithString:self.imagePath]
         options:0
         progress:^(NSInteger receivedSize, NSInteger expectedSize) {
             __strong __typeof(weakSelf) strongSelf = weakSelf;
             CGFloat value = 0;
             
             if (expectedSize) {
                 value = (double)receivedSize / (double)expectedSize;
             }

             strongSelf.progressIndicator.value = value;
         } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
             __strong __typeof(weakSelf) strongSelf = weakSelf;
             
             if (error) {
                 [strongSelf showFailedImage];
             }
             else {
                 [strongSelf showImage:image];
             }
         }];
    }
    else {
        [self showFailedImage];
    }
}

- (void)showImage:(UIImage*)image {

    if (!image
        || ![image isKindOfClass:[UIImage class]]) {
        [self showFailedImage];
        return;
    }

    self.loadingImage = NO;
    self.progressIndicator.hidden = YES;
    self.contentView.contentMode = UIViewContentModeScaleAspectFit;
    self.image = image;
    CGFloat maxDimention = MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    self.contentView.image = self.image.images
    ? [self.image sd_animatedImageByScalingAndCroppingToSize:CGSizeMake(maxDimention, maxDimention)]
    : self.image;
    
    [self sizeContent];
}

- (void)showFailedImage {
    self.loadingImage = NO;
    self.image = nil;
    self.progressIndicator.hidden = YES;
    self.contentView.contentMode = UIViewContentModeCenter;
    self.contentView.image = image(@"NHImageView.none");
    [self sizeContent];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {

    scrollView.alwaysBounceVertical = scrollView.zoomScale > 1;
    scrollView.alwaysBounceHorizontal = scrollView.zoomScale > 1;

    if (scrollView.zoomScale == self.minimumZoomScale) {
        self.contentSize = CGSizeZero;
        self.contentInset = UIEdgeInsetsZero;
        return;
    }

    CGSize zoomedSize = self.contentView.bounds.size;
    zoomedSize.width *= self.zoomScale;
    zoomedSize.height *= self.zoomScale;

    CGFloat verticalOffset = 0;
    CGFloat horizontalOffset = 0;

    if (zoomedSize.width < self.bounds.size.width) {
        horizontalOffset = (self.bounds.size.width - zoomedSize.width) / 2.0;
    }

    if (zoomedSize.height < self.bounds.size.height) {
        verticalOffset = (self.bounds.size.height - zoomedSize.height) / 2.0;
    }

    self.contentInset = UIEdgeInsetsMake(verticalOffset - self.contentView.frame.origin.y,
                                         horizontalOffset - self.contentView.frame.origin.x,
                                         verticalOffset + self.contentView.frame.origin.y,
                                         horizontalOffset + self.contentView.frame.origin.x);
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.contentView;
}

- (void)dealloc {
}

@end
