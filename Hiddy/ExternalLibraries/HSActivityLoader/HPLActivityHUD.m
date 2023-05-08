//
//  HPLActivityHUD.m
//  FreshBrix
//
//  Created by QBUser on 10/10/14.
//  Copyright (c) 2014 HomeProLog. All rights reserved.
//

#import "HPLActivityHUD.h"
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
//#import <Lottie.h> //"Lottie.h"
#import <AssetsLibrary/AssetsLibrary.h>


//#define PROGRESS_ANIMATED_IMAGE_SIZE CGSizeMake(45, 45)
#define PROGRESS_ANIMATED_IMAGE_SIZE CGSizeMake(45, 45)
#define PROGRESS_VIEW_SIZE CGSizeMake(70, 70)
#define PROGRESS_VIEW_CORNER_RADIUS 35.0

static UIView *loadingActivityView;
static UIView *maskView;
//LOTAnimationView * lotteView;
@implementation HPLActivityHUD

+ (void)showActivityWithMaskType:(HPLActivityMaskType)maskType {
    UIView *loadingView = [HPLActivityHUD sharedLoadingActivityView];
    NSEnumerator *frontToBackWindows = [[[UIApplication sharedApplication]windows]reverseObjectEnumerator];
    
    for (UIWindow *window in frontToBackWindows)
        if (window.windowLevel == UIWindowLevelNormal) {
            if (maskType == HPLActivityWithMask) {
                maskView = [HPLActivityHUD maskView];
                maskView.frame = [window frame];
                [maskView addSubview:loadingView];
                loadingView.center = [maskView center];
                [window addSubview:maskView];
            } else {
                [window addSubview:loadingView];
                loadingView.center = [window center];
            }

            break;
        }
}

/**
 *   @author Sirajudheen
 *   @brief  This will return loading activity view object which have a image subview of animated fresh brix logo.
 *   @return UIView
 */

+ (UIView *)sharedLoadingActivityView {
    if (!loadingActivityView) {
        CGRect loadingActivityViewFrame = CGRectMake(0, 0, PROGRESS_VIEW_SIZE.width, PROGRESS_VIEW_SIZE.height);
//        CGRect loadingActivityImageViewFrame = CGRectMake(0, 0, PROGRESS_ANIMATED_IMAGE_SIZE.width, PROGRESS_ANIMATED_IMAGE_SIZE.height);
        loadingActivityView = [[UIView alloc] initWithFrame:loadingActivityViewFrame];
        loadingActivityView.layer.cornerRadius = PROGRESS_VIEW_CORNER_RADIUS;
        loadingActivityView.backgroundColor = [UIColor whiteColor];
        
//        lotteView = [LOTAnimationView animationNamed:@"circle_loader"];
//        lotteView.frame = loadingActivityImageViewFrame;
//        lotteView.center = loadingActivityView.center ;
//        lotteView.loopAnimation = TRUE;
//        lotteView.animationSpeed = 1;
//        [lotteView play];
//        [loadingActivityView addSubview: lotteView];
    }
    return loadingActivityView;
}



/**
 *   @author Sirajudheen
 *   @brief  This function return mask view for the activity view
 *   @return UIView - required mask view
 */

+ (UIView *)maskView {
    if (!maskView) {
        maskView = [[UIView alloc] initWithFrame:CGRectZero];
        maskView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];
    }
    return maskView;
}

+ (void)dismiss {
    NSEnumerator *frontToBackWindows = [[[UIApplication sharedApplication]windows]reverseObjectEnumerator];
    for (UIWindow *window in frontToBackWindows)
        if (window.windowLevel == UIWindowLevelNormal) {
            break;
        }
    
//    [lotteView stop];
    [loadingActivityView setHidden:YES];
    [loadingActivityView removeFromSuperview];
    loadingActivityView = Nil;
    
    [maskView setHidden:YES];
    [maskView removeFromSuperview];
    maskView = Nil;
}

    //show activity with particular frame
+ (void)showActivityWithPosition:(CGPoint)point {
    UIView *loadingView = [HPLActivityHUD sharedLoadingActivityView];
    loadingView.backgroundColor = UIColor.clearColor;
    NSEnumerator * frontToBackWindows = [[[UIApplication sharedApplication]windows]reverseObjectEnumerator];
    for (UIWindow *window in frontToBackWindows)
    if (window.windowLevel == UIWindowLevelNormal){
            [window addSubview:loadingView];
            loadingView.center = point;
        break;
    }
}
    +(CGSize)getExactLabelSize:(NSString *)textString withFont:(NSString *)fontName andSize:(CGFloat)fontSize{
        CGSize expectedcomLabelSize = [textString sizeWithFont:[UIFont fontWithName:fontName size:fontSize] constrainedToSize:CGSizeMake(250, MAXFLOAT)
                                                 lineBreakMode:NSLineBreakByWordWrapping];
        
        return expectedcomLabelSize;
    }

    +(CGSize)getExactSize:(NSString *)textString withFont:(NSString *)fontName andSize:(CGFloat)fontSize{
    
        CGSize expectedcomLabelSize = [textString sizeWithFont:[UIFont fontWithName:fontName size:fontSize] constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width -40, MAXFLOAT)
                                                 lineBreakMode:NSLineBreakByWordWrapping];
        return expectedcomLabelSize;
    }
+(CGSize)getMsgSize:(NSString *)text withFont:(NSString *)fontName andSize:(CGFloat)fontSize{
    CGSize expectedcomLabelSize = [text sizeWithFont:[UIFont fontWithName:fontName size:fontSize] constrainedToSize:CGSizeMake(280, MAXFLOAT)
                                             lineBreakMode:NSLineBreakByWordWrapping];
    return expectedcomLabelSize;
}
@end
