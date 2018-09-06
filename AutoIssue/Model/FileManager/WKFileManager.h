//
//  WKFileManager.h
//  AutoIssue
//
//  Created by zhangrongwu on 2018/9/4.
//  Copyright © 2018年 ENN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WKFileManager : NSObject
+ (NSString *)cacheDirectory;
+ (NSString *)createPathWithChildPath:(NSString *)childPath;
+ (BOOL)removeFileAtPath:(NSString *)path;
@end
