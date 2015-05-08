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

- (instancetype)initWithFrame:(CGRect)frame andImage:(UIImage*)image;
- (void)sizeContent;

@end
