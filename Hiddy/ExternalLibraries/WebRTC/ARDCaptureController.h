/*
 *  Copyright 2017 The WebRTC Project Authors. All rights reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import <WebRTC/RTCCameraVideoCapturer.h>

@class ARDSettingsModel;

// Controls the camera. Handles starting the capture, switching cameras etc.
NS_EXTENSION_UNAVAILABLE_IOS("Camera not available in app extensions.")
@interface ARDCaptureController : NSObject

- (instancetype)initWithCapturer:(RTCCameraVideoCapturer *)capturer
                        settings:(ARDSettingsModel *)settings;
- (void)startCapture;
- (void)stopCapture;
- (void)switchCamera;

@end
