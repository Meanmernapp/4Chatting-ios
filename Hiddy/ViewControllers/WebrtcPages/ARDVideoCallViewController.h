/*
 *  Copyright 2015 The WebRTC Project Authors. All rights reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import <UIKit/UIKit.h>
#import "ARDVideoCallView.h"

@class ARDVideoCallViewController;
@protocol ARDVideoCallViewControllerDelegate <NSObject>
- (void)streamDetails:(NSInteger)state;
@end

@interface ARDVideoCallViewController : UIViewController

@property(nonatomic, weak) id<ARDVideoCallViewControllerDelegate> delegate;
@property(nonatomic) UIView *streamRemoteView;
@property(nonatomic) UIScrollView *scrlView;
@property(nonatomic, readonly) ARDVideoCallView *videoCallView;

- (instancetype)initForRoom:(NSString *)room
                 isLoopback:(BOOL)isLoopback
                   delegate:(id<ARDVideoCallViewControllerDelegate>)delegate;
- (void)configWebRTC;
- (void)joinToNextRoom:(NSString *)name platform:(NSString *)platform calltype:(NSString *)type;
- (void)makeCall:(NSString *)name platform:(NSString *)platform;
- (void)hangup;
- (void)switchCamera;
- (void)muteOn;
- (void)muteOff;
- (void)enlargeView;
- (void)speakerOn;
- (void)speakerOff;
-(void)showPreview;
-(void)hidePreview;
-(void)addPlatform:(NSString *)platform;
@end
