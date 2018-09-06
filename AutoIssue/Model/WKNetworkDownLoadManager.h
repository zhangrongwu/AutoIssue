//
//  WKNetworkDownLoadManager.h
//  AutoIssue
//
//  Created by zhangrongwu on 2018/9/4.
//  Copyright © 2018年 ENN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFURLSessionManager.h>

typedef void (^DownLoadSuccessHandle)(NSURL *filePath, NSURLResponse *response);
typedef void (^DownLoadFailHandle)(NSError *error, NSInteger statusCode);
typedef void (^DownLoadProgressHandle)(CGFloat progress);

@interface WKNetworkDownLoadManager : NSObject

+ (instancetype)shareInstance;

/**
 文件下载
 @param urlHost 下载地址
 @param progress 下载进度
 @param localPath 本地存储路径
 @param success 下载成功
 @param failure 下载失败
 @return downLoadTask
 */
- (NSURLSessionDownloadTask *)downLoadFileWithURL:(NSString *)urlHost
                                         progress:(DownLoadProgressHandle)progress
                                    fileLocalPath:(NSURL *)localPath
                                          success:(DownLoadSuccessHandle)success
                                          failure:(DownLoadFailHandle)failure;

- (void)stopAllDownLoadTasks;
@end
