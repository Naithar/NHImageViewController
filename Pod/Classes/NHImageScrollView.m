//
//  NHImageScrollView.m
//  Pods
//
//  Created by Sergey Minakov on 08.05.15.
//
//

#import "NHImageScrollView.h"
#import <MACircleProgressIndicator.h>
#import <AFNetworking.h>

@interface NHImageScrollView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView *contentView;
@property (nonatomic, strong) MACircleProgressIndicator *progressIndicator;
@property (nonatomic, assign) BOOL loadingImage;
@end

@implementation NHImageScrollView

+ (NSCache*)imageControllerCache {
    static dispatch_once_t token;
    __strong static NSCache* instance = nil;
    dispatch_once(&token, ^{
        instance = [[NSCache alloc] init];
    });

    return instance;
}

- (instancetype)init {
    self = [super init];

    if (self) {
        [self commonInit];
    }

    return self;
}

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
    self.backgroundColor = [UIColor clearColor];

    self.contentView = [[UIImageView alloc] initWithFrame:CGRectZero];
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

    CGRect bounds = self.contentView.frame;

    if (bounds.size.height) {



        CGFloat ratio = bounds.size.width / bounds.size.height;

        if (ratio) {

            if (ratio > 1.25) {
                if (self.frame.size.height > self.frame.size.width) {
                    bounds.size.width = MIN(self.bounds.size.width, self.bounds.size.height) - 2;
                    bounds.size.height = bounds.size.width / ratio;
                }
                else {
                    bounds.size.width = MAX(self.bounds.size.width, self.bounds.size.height) - 2;
                    bounds.size.height = bounds.size.width / ratio;
                }
            }
            else if (ratio < 0.75) {
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
                    bounds.size.height = MAX(self.bounds.size.width, self.bounds.size.height) - 2;
                    bounds.size.width = bounds.size.height * ratio;
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

- (void)saveImage {
    if (self.image) {
        UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil);
    }
}

- (void)loadImage {
    self.contentView.image = nil;
    self.loadingImage = NO;
    
    if (self.image) {
        [self showImage:self.image];
    }
    else if (self.imagePath
             && [self.imagePath length]) {

        UIImage *resultImage = [[[self class] imageControllerCache] objectForKey:self.imagePath];

        if (resultImage) {
            [self showImage:resultImage];
        }
        else {
            self.progressIndicator.value = 0;
            self.progressIndicator.hidden = NO;
            self.loadingImage = YES;

            __weak __typeof(self) weakSelf = self;
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer = [AFImageResponseSerializer serializer];
            [[manager GET:self.imagePath
               parameters:nil
                  success:^(AFHTTPRequestOperation *operation,
                            id responseObject) {
                      __strong __typeof(weakSelf) strongSelf = weakSelf;

                      dispatch_async(dispatch_get_main_queue(), ^{
                          if ([responseObject isKindOfClass:[UIImage class]]) {

                              [[[strongSelf class] imageControllerCache] setObject:responseObject forKey:strongSelf.imagePath];

                              [strongSelf showImage:responseObject];
                          }
                          else if ([responseObject isKindOfClass:[NSData class]]) {
                              UIImage *responseImage = [UIImage imageWithData:responseObject];
                              [[[strongSelf class] imageControllerCache] setObject:responseImage forKey:strongSelf.imagePath];

                              [strongSelf showImage:responseImage];
                          }
                          else {
                              [strongSelf showFailedImage];
                          }
                      });
                  } failure:^(AFHTTPRequestOperation *operation,
                              NSError *error) {
                      dispatch_async(dispatch_get_main_queue(), ^{
                          __strong __typeof(weakSelf) strongSelf = weakSelf;
                          [strongSelf showFailedImage];
                      });
                  }] setDownloadProgressBlock:^(NSUInteger bytesRead,
                                                long long totalBytesRead,
                                                long long totalBytesExpectedToRead) {
                      CGFloat value = 0;

                      if (totalBytesExpectedToRead) {
                          value = (double)totalBytesRead / (double)totalBytesExpectedToRead;
                      }
                      
                      self.progressIndicator.value = value;
                  }];
        }
    }
    else {
        [self showFailedImage];
    }
}

- (void)showImage:(UIImage*)image {

    if (!image) {
        [self showFailedImage];
        return;
    }

    self.loadingImage = NO;
    self.progressIndicator.hidden = YES;
    self.contentView.contentMode = UIViewContentModeScaleAspectFit;
    self.image = image;
    self.contentView.image = self.image;
    [self sizeContent];
}

- (void)showFailedImage {
    self.loadingImage = NO;
    self.image = nil;
    self.progressIndicator.hidden = YES;
    self.contentView.contentMode = UIViewContentModeCenter;
    self.contentView.image = [UIImage imageNamed:@"NHImageView.none.png"];
    [self sizeContent];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
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


@end
