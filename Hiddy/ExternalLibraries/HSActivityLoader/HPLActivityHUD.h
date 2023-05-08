//
//  HPLActivityHUD.h
//  FreshBrix
//
//  Created by QBUser on 10/10/14.
//  Copyright (c) 2014 HomeProLog. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

typedef NS_ENUM(NSUInteger, HPLActivityMaskType) {
    HPLActivityWithMask,
    HPLActivityWithOutMask,
};

@interface HPLActivityHUD : NSObject

+ (void)showActivityWithMaskType:(HPLActivityMaskType)maskType;
+ (void)dismiss;
+ (void)showActivityWithPosition:(CGPoint)point;
+(CGSize)getExactLabelSize:(NSString *)textString withFont:(NSString *)fontName andSize:(CGFloat)fontSize;
+(CGSize)getExactSize:(NSString *)textString withFont:(NSString *)fontName andSize:(CGFloat)fontSize;
+(CGSize)getMsgSize:(NSString *)text withFont:(NSString *)fontName andSize:(CGFloat)fontSize;

@end
