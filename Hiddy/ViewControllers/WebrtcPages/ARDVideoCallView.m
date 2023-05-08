/*
 *  Copyright 2015 The WebRTC Project Authors. All rights reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "ARDVideoCallView.h"
#import <QuartzCore/QuartzCore.h>

#import <AVFoundation/AVFoundation.h>

#import <WebRTC/RTCEAGLVideoView.h>
#import <WebRTC/RTCMTLVideoView.h>

#import "UIImage+ARDUtilities.h"

static CGFloat const kButtonPadding = 16;
static CGFloat const kButtonSize = 48;
static CGFloat const kLocalVideoViewSize = 150;
static CGFloat const kLocalVideoViewPadding = 18;
static CGFloat const kStatusBarHeight = 20;

@interface ARDVideoCallView () <RTCVideoViewDelegate>
@end

@implementation ARDVideoCallView {
  UIButton *_routeChangeButton;
  UIButton *_cameraSwitchButton;
  UIButton *_hangupButton;
  CGSize _remoteVideoSize;
   NSString * screenType;

}

@synthesize statusLabel = _statusLabel;
@synthesize localVideoView = _localVideoView;
@synthesize remoteVideoView = _remoteVideoView;
@synthesize statsView = _statsView;
@synthesize delegate = _delegate;

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
      screenType = @"1";
#if defined(RTC_SUPPORTS_METAL)
    _remoteVideoView = [[RTCMTLVideoView alloc] initWithFrame:CGRectZero];
#else
    RTCEAGLVideoView *remoteView = [[RTCEAGLVideoView alloc] initWithFrame:CGRectZero];
    remoteView.delegate = self;
    _remoteVideoView = remoteView;
#endif

    [self addSubview:_remoteVideoView];

      _localVideoView = [[RTCCameraPreviewView alloc] initWithFrame:CGRectZero];
      [self addSubview:_localVideoView];
      UITapGestureRecognizer *singleFingerTap =
      [[UITapGestureRecognizer alloc] initWithTarget:self
                                              action:@selector(enlargePreview:)];
      [_localVideoView addGestureRecognizer:singleFingerTap];
      
//onRouteChange
    _statsView = [[ARDStatsView alloc] initWithFrame:CGRectZero];
    _statsView.hidden = YES;
    [self addSubview:_statsView];

    _routeChangeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _routeChangeButton.backgroundColor = [UIColor whiteColor];
    _routeChangeButton.layer.cornerRadius = kButtonSize / 2;
    _routeChangeButton.layer.masksToBounds = YES;
    UIImage *image = [UIImage imageNamed:@"ic_surround_sound_black_24dp.png"];
    [_routeChangeButton setImage:image forState:UIControlStateNormal];
    [_routeChangeButton addTarget:self
                           action:@selector(onRouteChange:)
                 forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_routeChangeButton];

    // TODO(tkchin): don't display this if we can't actually do camera switch.
    _cameraSwitchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _cameraSwitchButton.backgroundColor = [UIColor whiteColor];
    _cameraSwitchButton.layer.cornerRadius = kButtonSize / 2;
    _cameraSwitchButton.layer.masksToBounds = YES;
    image = [UIImage imageNamed:@"ic_switch_video_black_24dp.png"];
    [_cameraSwitchButton setImage:image forState:UIControlStateNormal];
    [_cameraSwitchButton addTarget:self
                      action:@selector(onCameraSwitch)
            forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_cameraSwitchButton];

    _hangupButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _hangupButton.backgroundColor = [UIColor redColor];
    _hangupButton.layer.cornerRadius = kButtonSize / 2;
    _hangupButton.layer.masksToBounds = YES;
    image = [UIImage imageForName:@"ic_call_end_black_24dp.png"
                            color:[UIColor whiteColor]];
    [_hangupButton setImage:image forState:UIControlStateNormal];
    [_hangupButton addTarget:self
                      action:@selector(onHangup:)
            forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_hangupButton];

    _statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _statusLabel.font = [UIFont fontWithName:@"Roboto" size:16];
    _statusLabel.textColor = [UIColor whiteColor];
    [self addSubview:_statusLabel];


      [_hangupButton setHidden:true];
      [_cameraSwitchButton setHidden:true];
      [_routeChangeButton setHidden:true];

  }
  return self;
}


-(void)switchView{
    
    if (self.enlargeEnable) {
        self.enlargeEnable = false;
        [self setRemoteViewToSmall];
        [self bringSubviewToFront:_remoteVideoView];
    }else{
        self.enlargeEnable = true;
        [self setRemoteViewToBig];
        [self bringSubviewToFront:_localVideoView];
    }
}
    


-(void)setRemoteViewToSmall{

    
    if ([[UIScreen mainScreen] bounds].size.height >= 812.0f) { //iphone x series
        _localVideoView.frame = CGRectMake(0, -130, UIScreen.mainScreen.bounds.size.width+250,UIScreen.mainScreen.bounds.size.height+250);
    }else if([[UIScreen mainScreen] bounds].size.height >= 2208.0f || [[UIScreen mainScreen] bounds].size.height >= 1920.0f) { //iphone plus
        _localVideoView.frame = CGRectMake(0, -65, UIScreen.mainScreen.bounds.size.width+220,UIScreen.mainScreen.bounds.size.height+220);
    }else{
        _localVideoView.frame = CGRectMake(0, -50, UIScreen.mainScreen.bounds.size.width+200,UIScreen.mainScreen.bounds.size.height+200);

    }
    // Aspect fit local video view into a square box.
    CGFloat leftPadding = UIScreen.mainScreen.bounds.size.width-kLocalVideoViewSize;
    CGRect localVideoFrame =
    CGRectMake(leftPadding+20, 40, kLocalVideoViewSize-40, kLocalVideoViewSize);
    
    _remoteVideoView.frame = localVideoFrame;
    _remoteVideoView.contentMode = UIViewContentModeScaleAspectFit;
    
}

-(void)setRemoteViewToBig{
    _remoteVideoSize = CGSizeMake(UIScreen.mainScreen.bounds.size.width,UIScreen.mainScreen.bounds.size.height);

    CGRect bounds = self.bounds;
    CGRect remoteVideoFrame = CGRectZero;
    if (_remoteVideoSize.width > 0 && _remoteVideoSize.height > 0) {
        // Aspect fill remote video into bounds.
        remoteVideoFrame =
        AVMakeRectWithAspectRatioInsideRect(_remoteVideoSize, bounds);
        CGFloat scale = 1;
        if (remoteVideoFrame.size.width > remoteVideoFrame.size.height) {
            // Scale by height.
            scale = bounds.size.height / remoteVideoFrame.size.height;
        } else {
            // Scale by width.
            scale = bounds.size.width / remoteVideoFrame.size.width;
        }
        remoteVideoFrame.size.height *= scale;

        if ([self.platform isEqualToString:@"ios"]) {
            if ([[[UIApplication sharedApplication] keyWindow] safeAreaInsets].bottom != 0){
                remoteVideoFrame.size.width *= scale + .5;
                NSLog(@"PLATFORM IOS 1 %f",[self scaledBasdedOnDevice]);

            }else{
                remoteVideoFrame.size.width *= scale + .3;
                NSLog(@"PLATFORM IOS 2 %f",[self scaledBasdedOnDevice]);

            }
        }else{
            NSLog(@"PLATFORM ANDROID");
            if ([[[UIApplication sharedApplication] keyWindow] safeAreaInsets].bottom != 0){
                remoteVideoFrame.size.width *= scale + .2;
            }else{
                remoteVideoFrame.size.width *= scale;
            }
        }
        _remoteVideoView.frame = remoteVideoFrame;
        _remoteVideoView.center =
        CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    } else {
        _remoteVideoView.frame = bounds;
    }

    CGRect localVideoFrame = CGRectMake(UIScreen.mainScreen.bounds.size.width-kLocalVideoViewSize, 40, kLocalVideoViewSize, kLocalVideoViewSize);
        _localVideoView.frame = localVideoFrame;

    
}
#pragma mark - RTCVideoViewDelegate

- (void)videoView:(id<RTCVideoRenderer>)videoView didChangeVideoSize:(CGSize)size {
    NSLog(@"didChangeVideoSize");

    [self setRemoteViewToBig];
    [self bringSubviewToFront:_localVideoView];
}

#pragma mark - Private

- (void)onCameraSwitch {
  [_delegate videoCallViewDidSwitchCamera:self];
}

- (void)onRouteChange:(id)sender {
  [_delegate videoCallViewDidChangeRoute:self];
}

- (void)onHangup:(id)sender {
  [_delegate videoCallViewDidHangup:self];
}

- (void)didTripleTap:(UITapGestureRecognizer *)recognizer {
  [_delegate videoCallViewDidEnableStats:self];
}

- (void)enlargePreview:(UITapGestureRecognizer *)recognizer
{
}

-(CGFloat)scaledBasdedOnDevice{
    CGFloat scaleValue = .2;
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
            case 1136:
                scaleValue = .2;
                break;
            case 1334:

                scaleValue = .2;
                break;
                
            case 1920:

                scaleValue = .4;
                break;
            case 2208:

                scaleValue = .4;
                break;
            case 2436:

                scaleValue = .5;
                break;
                
            case 2688:

                scaleValue = .5;
                break;
                
            case 1792:

                scaleValue = .5;
                break;
          
            default:

                scaleValue = .2;
                break;
        }
    }
    return scaleValue;
}


@end
