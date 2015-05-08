//
//  NHImageScrollView.m
//  Pods
//
//  Created by Sergey Minakov on 08.05.15.
//
//

#import "NHImageScrollView.h"

@interface NHImageScrollView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView *contentView;

@end

@implementation NHImageScrollView

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
    self = [super initWithFrame:frame];

    if (self) {
        [self commonInit];
    }

    return self;
}

- (instancetype)initWithFrame:(CGRect)frame andImage:(UIImage*)image {
    self = [super initWithFrame:frame];

    if (self) {
        self.image = image;
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
    self.contentView.image = self.image;
    self.contentView.contentMode = UIViewContentModeScaleAspectFit;
    self.contentView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.contentView];

    [self sizeContent];
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

    CGFloat ratio = bounds.size.width / MAX(bounds.size.height, 1);

    if (ratio != 1) {
        if (self.frame.size.height > self.frame.size.width) {
            bounds.size.width = MIN(self.bounds.size.width, self.bounds.size.height) - 2;
            bounds.size.height = bounds.size.width / MAX(ratio, 1);
        }
        else {
            bounds.size.height = MIN(self.bounds.size.width, self.bounds.size.height) - 2;
            bounds.size.width = bounds.size.height * MAX(ratio, 1);
        }
    }
    else {
        bounds.size.width = MIN(self.bounds.size.width, self.bounds.size.height) - 2;
        bounds.size.height = bounds.size.width;
    }

    self.contentView.frame = bounds;
    self.contentView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    self.contentSize = CGSizeZero;

    [self scrollViewDidZoom:self];
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
