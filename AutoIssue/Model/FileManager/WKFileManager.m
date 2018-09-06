//
//  WKFileManager.m
//  AutoIssue
//
//  Created by zhangrongwu on 2018/9/4.
//  Copyright © 2018年 ENN. All rights reserved.
//

#import "WKFileManager.h"

@implementation WKFileManager
+ (NSString *)cacheDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

+ (NSString *)createPathWithChildPath:(NSString *)childPath {
    NSString *path = [[self cacheDirectory] stringByAppendingPathComponent:childPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirExist = [fileManager fileExistsAtPath:path];
    if (!isDirExist) {
        NSError *err;
        BOOL isCreateDir = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&err];
        if (!isCreateDir) {
            NSLog(@"create%@", err);
            return nil;
        }
    }
    return path;
}

+ (BOOL)removeFileAtPath:(NSString *)path
{
    return [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

@end
