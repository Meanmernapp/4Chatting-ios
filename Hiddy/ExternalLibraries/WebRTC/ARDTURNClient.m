/*
 *  Copyright 2014 The WebRTC Project Authors. All rights reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "ARDTURNClient+Internal.h"

#import "ARDUtilities.h"
#import "RTCIceServer+JSON.h"

// TODO(tkchin): move this to a configuration object.
//static NSString *kTURNRefererURLString = @"https://appr.tc";
//static NSString *kTURNRefererURLString = @"http://192.168.1.23:8080";

static NSString *kARDTURNClientErrorDomain = @"ARDTURNClient";
static NSInteger kARDTURNClientErrorBadResponse = -1;

@implementation ARDTURNClient {
  NSURL *_url;
}

- (instancetype)initWithURL:(NSURL *)url {
  NSParameterAssert([url absoluteString].length);
  if (self = [super init]) {
    _url = url;
  }
  return self;
}

- (void)requestServersWithCompletionHandler:
    (void (^)(NSArray *turnServers, NSError *error))completionHandler {
    NSLog(@"req ur %@",_url);
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_url];
  [NSURLConnection sendAsyncRequest:request
                  completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
      if (error) {
        completionHandler(nil, error);
        return;
      }
      NSDictionary *responseDict = [NSDictionary dictionaryWithJSONData:data];
//      NSString *iceServerUrl = responseDict[@"ice_server_url"];
        NSLog(@"TURN FULL RESPONSE %@",responseDict);

        [self NewTurnServerRequestToURL:responseDict WithCompletionHandler:completionHandler];
//      [self makeTurnServerRequestToURL:[NSURL URLWithString:iceServerUrl] WithCompletionHandler:completionHandler];
    }];
}

- (void)NewTurnServerRequestToURL:(NSDictionary *)turnResponseDict
             WithCompletionHandler:(void (^)(NSArray *turnServers,
                                             NSError *error))completionHandler {
  
                        NSLog(@"PC CONFIG %@",[turnResponseDict valueForKey:@"pc_config"]);
                        NSMutableArray *turnServers = [NSMutableArray array];
//                        [[turnResponseDict valueForKeyPath:@"pc_config.iceServers"] enumerateObjectsUsingBlock:
//                         ^(NSDictionary *obj, NSUInteger idx, BOOL *stop){
//                             NSLog(@"TURN OBJ DICT %@",obj);
//
//                         }];
//    cityArray = [NSJSONSerialization JSONObjectWithData: cityData options:NSJSONReadingMutableContainers error:nil];
    
    NSData *dataNew = [[turnResponseDict valueForKey:@"pc_config"] dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary * jsonDict = [NSJSONSerialization JSONObjectWithData:dataNew options:0 error:nil];
    NSLog(@"chjeck %@",jsonDict);
    NSArray * resultArray = [jsonDict valueForKey:@"iceServers"];
        for (NSDictionary * obj in resultArray) {
                NSLog(@"TURN OBJ DICT %@",obj);
            [turnServers addObject:[RTCIceServer serverFromJSONDictionary:obj]];
        }

                        if (!turnServers) {
                            NSError *responseError =
                            [[NSError alloc] initWithDomain:kARDTURNClientErrorDomain
                                                       code:kARDTURNClientErrorBadResponse
                                                   userInfo:@{
                                                              NSLocalizedDescriptionKey: @"Bad TURN response.",
                                                              }];
                            completionHandler(nil, responseError);
                            return;
                        }
                        completionHandler(turnServers, nil);
}

#pragma mark - Private

- (void)makeTurnServerRequestToURL:(NSURL *)url
             WithCompletionHandler:(void (^)(NSArray *turnServers,
                                             NSError *error))completionHandler {
  NSMutableURLRequest *iceServerRequest = [NSMutableURLRequest requestWithURL:url];
  iceServerRequest.HTTPMethod = @"POST";
  [iceServerRequest addValue:[[NSUserDefaults standardUserDefaults]valueForKey:@"web_rtc_web"] forHTTPHeaderField:@"referer"];
  [NSURLConnection sendAsyncRequest:iceServerRequest
                  completionHandler:^(NSURLResponse *response,
                                      NSData *data,
                                      NSError *error) {
      if (error) {
        completionHandler(nil, error);
        return;
      }
      NSDictionary *turnResponseDict = [NSDictionary dictionaryWithJSONData:data];
                      NSLog(@"PRINT DATA TURN  RESPONSE DICT %@",turnResponseDict);

      NSMutableArray *turnServers = [NSMutableArray array];
      [turnResponseDict[@"iceServers"] enumerateObjectsUsingBlock:
                         ^(NSDictionary *obj, NSUInteger idx, BOOL *stop){
                             
          [turnServers addObject:[RTCIceServer serverFromJSONDictionary:obj]];
        }];
      if (!turnServers) {
        NSError *responseError =
          [[NSError alloc] initWithDomain:kARDTURNClientErrorDomain
                                     code:kARDTURNClientErrorBadResponse
                                 userInfo:@{
            NSLocalizedDescriptionKey: @"Bad TURN response.",
            }];
        completionHandler(nil, responseError);
        return;
      }
      completionHandler(turnServers, nil);
    }];
}

@end
