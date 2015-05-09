//
//  NHImageScrollView.h
//  Pods
//
//  Created by Sergey Minakov on 08.05.15.
//
//

#import <UIKit/UIKit.h>

@interface NHImageScrollView : UIScrollView

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, readonly, strong) UIImageView *contentView;

- (instancetype)initWithFrame:(CGRect)frame andImage:(UIImage*)image;
- (void)sizeContent;
- (void)zoomToPoint:(CGPoint)point andScale:(CGFloat)scale;
@end
