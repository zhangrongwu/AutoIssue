//
//  NSObject+WKExtension.m
//  AutoIssue
//
//  Created by zhangrongwu on 2018/9/5.
//  Copyright © 2018年 ENN. All rights reserved.
//

#import "NSObject+WKExtension.h"

@implementation NSObject (WKExtension)
+(BOOL)isOrientationPortrait{
    UIInterfaceOrientation interface = [UIApplication sharedApplication].statusBarOrientation;
    if (interface == UIInterfaceOrientationLandscapeLeft || interface == UIInterfaceOrientationLandscapeRight) {// 横屏
        return NO;
    }
    
    return YES;
}
@end
