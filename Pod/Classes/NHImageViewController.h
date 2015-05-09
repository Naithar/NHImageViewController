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

- (BOOL)hideInterface;
- (BOOL)displayInterface;

- (void)saveCurerntImage;
- (void)reloadCurrentPage;

+ (void)showImage:(UIImage*)image inViewController:(UIViewController*)controller;
+ (void)showImage:(UIImage*)image withNote:(NSString*)note inViewController:(UIViewController*)controller;
+ (void)showImageAtPath:(NSString*)imagePath inViewController:(UIViewController*)controller;
+ (void)showImageAtPath:(NSString*)imagePath withNote:(NSString*)note inViewController:(UIViewController*)controller;
+ (void)showImageAtURL:(NSURL*)imageURL inViewController:(UIViewController*)controller;
+ (void)showImageAtURL:(NSURL*)imageURL withNote:(NSString*)note inViewController:(UIViewController*)controller;
+ (void)presentIn:(UIViewController*)controller withData:(NSArray*)dataArray;
+ (void)presentIn:(UIViewController*)controller withData:(NSArray*)dataArray andNote:(NSString*)note;


@end
