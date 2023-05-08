/*
 *  Copyright 2015 The WebRTC Project Authors. All rights reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "ARDVideoCallViewController.h"

#import <WebRTC/RTCAudioSession.h>
#import <WebRTC/RTCCameraVideoCapturer.h>
#import <WebRTC/RTCDispatcher.h>
#import <WebRTC/RTCLogging.h>
#import <WebRTC/RTCMediaConstraints.h>

#import "ARDAppClient.h"
#import "ARDCaptureController.h"
#import "ARDFileCaptureController.h"
#import "ARDSettingsModel.h"
#import "ARDVideoCallView.h"

@interface ARDVideoCallViewController () <ARDAppClientDelegate,
                                          ARDVideoCallViewDelegate,
                                          RTCAudioSessionDelegate,RTCVideoViewDelegate>
@property(nonatomic, strong) RTCVideoTrack *remoteVideoTrack;
@property(nonatomic, assign) AVAudioSessionPortOverride portOverride;
@end

@implementation ARDVideoCallViewController {
  ARDAppClient *_client;
ARDCaptureController *_captureController;
ARDFileCaptureController *_fileCaptureController NS_AVAILABLE_IOS(10);
  RTCVideoTrack *_remoteVideoTrack;

}

@synthesize videoCallView = _videoCallView;
@synthesize remoteVideoTrack = _remoteVideoTrack;
@synthesize delegate = _delegate;
@synthesize portOverride = _portOverride;

- (instancetype)initForRoom:(NSString *)room
                 isLoopback:(BOOL)isLoopback
                   delegate:(id<ARDVideoCallViewControllerDelegate>)delegate {
  if (self = [super init]) {
//    ARDSettingsModel *settingsModel = [[ARDSettingsModel alloc] init];
//    _delegate = delegate;
//
//    _client = [[ARDAppClient alloc] initWithDelegate:self];
//    [_client connectToRoomWithId:room settings:settingsModel isLoopback:isLoopback];
  }
  return self;
}

    
- (void)configWebRTC {

  _videoCallView = [[ARDVideoCallView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height)];
  _videoCallView.delegate = self;
  _videoCallView.enlargeEnable = true;
  _videoCallView.statusLabel.text =
    [self statusTextForState:RTCIceConnectionStateNew];
    
    self.scrlView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height)];
    self.streamRemoteView = [[UIView alloc] init];
    self.streamRemoteView.frame = self.scrlView.bounds;
    self.streamRemoteView = _videoCallView;
    [self.scrlView addSubview:self.streamRemoteView];
    [self.view addSubview:self.scrlView];

  RTCAudioSession *session = [RTCAudioSession sharedInstance];
  [session addDelegate:self];
}

-(void)joinToNextRoom:(NSString *)name platform:(NSString *)platform calltype:(NSString *)type{
    ARDSettingsModel *settingsModel = [[ARDSettingsModel alloc] init];
    [settingsModel storeVideoResolutionSetting:@"640x480"];
    NSLog(@"******PLATFORM %@",platform);
    _videoCallView.platform = platform;
    _videoCallView.enlargeEnable = true;
    _client = [[ARDAppClient alloc] initWithDelegate:self];
    if ([type isEqualToString:@"audio"]) {
           [settingsModel storeAudioOnlySetting:true];
       }else{
           [settingsModel storeAudioOnlySetting:false];
       }
    [_client connectToRoomWithId:name settings:settingsModel isLoopback:false];
}
-(void)makeCall:(NSString *)name platform:(NSString *)platform{
    NSLog(@"******PLATFORM NEW %@",platform);
    ARDSettingsModel *settingsModel = [[ARDSettingsModel alloc] init];
    [settingsModel storeVideoResolutionSetting:@"640x480"];
    [settingsModel storeAudioOnlySetting:false];
    _videoCallView.platform = platform;
    _client = [[ARDAppClient alloc] initWithDelegate:self];
    [_client connectToRoomWithId:name settings:settingsModel isLoopback:false];
}
-(void)addPlatform:(NSString *)platform{
    _videoCallView.platform = platform;
//    [_videoCallView setRemoteViewToBig];
}
-(void)showPreview{
    _videoCallView.localVideoView.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
    [self enlargeView];
    _videoCallView.remoteVideoView.hidden = true;
}
-(void)hidePreview{
    [self enlargeView];
    _videoCallView.remoteVideoView.hidden = false;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskAll;
}

#pragma mark - ARDAppClientDelegate

- (void)appClient:(ARDAppClient *)client
    didChangeState:(ARDAppClientState)state {
  switch (state) {
    case kARDAppClientStateConnected:
      RTCLog(@"Client connected.");
      break;
    case kARDAppClientStateConnecting:
      RTCLog(@"Client connecting.");
      break;
    case kARDAppClientStateDisconnected:
      RTCLog(@"Client disconnected.");
      [self hangup];
      break;
  }
}

- (void)appClient:(ARDAppClient *)client
    didChangeConnectionState:(RTCIceConnectionState)state {
    NSLog(@"ICE state changed: %ld", (long)state);
    if (state == RTCIceConnectionStateConnected){
        [self.scrlView setContentOffset:CGPointMake(0, 0)];
    }
    [self.delegate streamDetails:state];

  __weak ARDVideoCallViewController *weakSelf = self;
  dispatch_async(dispatch_get_main_queue(), ^{
    ARDVideoCallViewController *strongSelf = weakSelf;
    strongSelf.videoCallView.statusLabel.text =
        [strongSelf statusTextForState:state];
  });
}

- (void)appClient:(ARDAppClient *)client
    didCreateLocalCapturer:(RTCCameraVideoCapturer *)localCapturer {
  _videoCallView.localVideoView.captureSession = localCapturer.captureSession;
  ARDSettingsModel *settingsModel = [[ARDSettingsModel alloc] init];
  _captureController =
      [[ARDCaptureController alloc] initWithCapturer:localCapturer settings:settingsModel];
  [_captureController startCapture];
}

- (void)appClient:(ARDAppClient *)client
    didCreateLocalFileCapturer:(RTCFileVideoCapturer *)fileCapturer {
#if defined(__IPHONE_11_0) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_11_0)
  if (@available(iOS 10, *)) {
    _fileCaptureController = [[ARDFileCaptureController alloc] initWithCapturer:fileCapturer];
    [_fileCaptureController startCapture];
  }
#endif
}

- (void)appClient:(ARDAppClient *)client
    didReceiveLocalVideoTrack:(RTCVideoTrack *)localVideoTrack {
}

- (void)appClient:(ARDAppClient *)client
    didReceiveRemoteVideoTrack:(RTCVideoTrack *)remoteVideoTrack {
  self.remoteVideoTrack = remoteVideoTrack;
  __weak ARDVideoCallViewController *weakSelf = self;
  dispatch_async(dispatch_get_main_queue(), ^{
    ARDVideoCallViewController *strongSelf = weakSelf;
    strongSelf.videoCallView.statusLabel.hidden = YES;
  });
}

- (void)appClient:(ARDAppClient *)client
      didGetStats:(NSArray *)stats {
  _videoCallView.statsView.stats = stats;
  [_videoCallView setNeedsLayout];
}

- (void)appClient:(ARDAppClient *)client
         didError:(NSError *)error {
  NSString *message =
      [NSString stringWithFormat:@"%@", error.localizedDescription];
  [self hangup];
  [self showAlertWithMessage:message];
}

#pragma mark - ARDVideoCallViewDelegate

- (void)videoCallViewDidHangup:(ARDVideoCallView *)view {
  [self hangup];
}

- (void)videoCallViewDidSwitchCamera:(ARDVideoCallView *)view {
  // TODO(tkchin): Rate limit this so you can't tap continously on it.
  // Probably through an animation.
  [_captureController switchCamera];
}

- (void)videoCallViewDidChangeRoute:(ARDVideoCallView *)view {
 /* AVAudioSessionPortOverride override = AVAudioSessionPortOverrideNone;
  if (_portOverride == AVAudioSessionPortOverrideNone) {
    override = AVAudioSessionPortOverrideSpeaker;
  }
    NSLog(@"speaker set");

  [RTCDispatcher dispatchAsyncOnType:RTCDispatcherTypeAudioSession
                               block:^{
    RTCAudioSession *session = [RTCAudioSession sharedInstance];
    [session lockForConfiguration];
    NSError *error = nil;
    if ([session overrideOutputAudioPort:override error:&error]) {
      self.portOverride = override;
    } else {
      RTCLogError(@"Error overriding output port: %@",
                  error.localizedDescription);
    }
    [session unlockForConfiguration];
  }];*/
}

- (void)videoCallViewDidEnableStats:(ARDVideoCallView *)view {
  _client.shouldGetStats = YES;
  _videoCallView.statsView.hidden = NO;
}

#pragma mark - RTCAudioSessionDelegate

- (void)audioSession:(RTCAudioSession *)audioSession
    didDetectPlayoutGlitch:(int64_t)totalNumberOfGlitches {
  RTCLog(@"Audio session detected glitch, total: %lld", totalNumberOfGlitches);
}

#pragma mark - Private

- (void)setRemoteVideoTrack:(RTCVideoTrack *)remoteVideoTrack {
  if (_remoteVideoTrack == remoteVideoTrack) {
    return;
  }
  [_remoteVideoTrack removeRenderer:_videoCallView.remoteVideoView];
  _remoteVideoTrack = nil;
  [_videoCallView.remoteVideoView renderFrame:nil];
  _remoteVideoTrack = remoteVideoTrack;
  [_remoteVideoTrack addRenderer:_videoCallView.remoteVideoView];
}

- (void)muteOn{
    [_client enableLocalAudio:TRUE];
}
- (void)muteOff{
    [_client enableLocalAudio:FALSE];
}
- (void)enlargeView{
    [_videoCallView switchView];
     [self.view bringSubviewToFront:self.scrlView];
}
- (void)speakerOn{
    [self speaker:true];
}
- (void)speakerOff{
    [self speaker:FALSE];
}
//enable disable loud speaker
-(void)speaker:(BOOL)enable{
    AVAudioSessionPortOverride override = AVAudioSessionPortOverrideNone;
    if (enable){
        override = AVAudioSessionPortOverrideSpeaker;
    }else{
        override = AVAudioSessionPortOverrideNone;
    }
    [RTCDispatcher dispatchAsyncOnType:RTCDispatcherTypeAudioSession
                                 block:^{
                                     RTCAudioSession *session = [RTCAudioSession sharedInstance];
                                     [session lockForConfiguration];
                                     NSError *error = nil;
                                     if ([session overrideOutputAudioPort:override error:&error]) {
                                         self.portOverride = override;
                                     } else {
                                         RTCLogError(@"Error overriding output port: %@",
                                                     error.localizedDescription);
                                     }
                                     [session unlockForConfiguration];
                                 }];
}
- (void)hangup {
  self.remoteVideoTrack = nil;
  _videoCallView.localVideoView.captureSession = nil;
  [_captureController stopCapture];
  _captureController = nil;
  [_fileCaptureController stopCapture];
  _fileCaptureController = nil;
  [_client disconnect];
//  [_delegate viewControllerDidFinish:self];
//    [self.navigationController popViewControllerAnimated:TRUE];
}

-(void)switchCamera{
    [_videoCallView onCameraSwitch];
}


- (NSString *)statusTextForState:(RTCIceConnectionState)state {
  switch (state) {
    case RTCIceConnectionStateNew:
    case RTCIceConnectionStateChecking:
      return @"Connecting...";
    case RTCIceConnectionStateConnected:
    case RTCIceConnectionStateCompleted:
    case RTCIceConnectionStateFailed:
    case RTCIceConnectionStateDisconnected:
    case RTCIceConnectionStateClosed:
    case RTCIceConnectionStateCount:
      return nil;
  }
}

- (void)showAlertWithMessage:(NSString*)message {
    dispatch_async(dispatch_get_main_queue(), ^{

        UIAlertController *alert =
            [UIAlertController alertControllerWithTitle:nil
                                                message:message
                                         preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action){
                                                              }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    });

}




@end
