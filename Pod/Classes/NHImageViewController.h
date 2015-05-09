//
//  NHImageViewController.h
//  Pods
//
//  Created by Sergey Minakov on 08.05.15.
//
//

#import <UIKit/UIKit.h>

@interface NHImageViewController : UIViewController

@property (strong, readonly, nonatomic) UIButton *closeButton;
@property (strong, readonly, nonatomic) UIButton *optionsButton;

@property (strong, readonly, nonatomic) UILabel *noteLabel;

- (void)setStartingPage:(NSInteger)startPage;

- (BOOL)hideInterface;
- (BOOL)displayInterface;

- (void)saveCurerntImage;
- (void)reloadCurrentPage;

+ (instancetype)showImage:(UIImage*)image inViewController:(UIViewController*)controller;
+ (instancetype)showImage:(UIImage*)image withNote:(NSString*)note inViewController:(UIViewController*)controller;
+ (instancetype)showImageAtPath:(NSString*)imagePath inViewController:(UIViewController*)controller;
+ (instancetype)showImageAtPath:(NSString*)imagePath withNote:(NSString*)note inViewController:(UIViewController*)controller;
+ (instancetype)showImageAtURL:(NSURL*)imageURL inViewController:(UIViewController*)controller;
+ (instancetype)showImageAtURL:(NSURL*)imageURL withNote:(NSString*)note inViewController:(UIViewController*)controller;
+ (instancetype)presentIn:(UIViewController*)controller withData:(NSArray*)dataArray;
+ (instancetype)presentIn:(UIViewController*)controller withData:(NSArray*)dataArray andNote:(NSString*)note;


@end
