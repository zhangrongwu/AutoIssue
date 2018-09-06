//
//  WKNetworkDownLoadManager.m
//  AutoIssue
//
//  Created by zhangrongwu on 2018/9/4.
//  Copyright © 2018年 ENN. All rights reserved.
//

#import "WKNetworkDownLoadManager.h"

@interface WKNetworkDownLoadManager()
@property (nonatomic,strong) AFURLSessionManager *manager;
//用于管理下载的任务数据
@property (nonatomic,strong) NSMutableDictionary *downLoadHistoryDictionary;
//历史管理文件目录
@property (nonatomic,strong) NSString  *fileHistoryPath;

@end
@implementation WKNetworkDownLoadManager
+ (instancetype)shareInstance {
    static WKNetworkDownLoadManager *networkManager;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        networkManager = [[self alloc] init];
    });
    return networkManager;
}

-(instancetype)init {
    if (self = [super init]) {
        NSDictionary *dic =[[NSBundle mainBundle] infoDictionary];
        NSString *appIdentifier  = [dic objectForKey:@"CFBundleIdentifier"];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:appIdentifier];
        configuration.timeoutIntervalForRequest = 30;
        //在蜂窝网络情况下是否继续请求（上传或下载）
        configuration.allowsCellularAccess = YES;
        
        self.manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        
        NSURLSessionDownloadTask *task;
        [[NSNotificationCenter defaultCenter] addObserverForName:AFNetworkingTaskDidCompleteNotification object:task queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            
            if ([note.object isKindOfClass:[NSURLSessionDownloadTask class]]) {
                NSURLSessionDownloadTask *task = note.object;
                NSString *urlHost = [task.currentRequest.URL absoluteString];// 用于再次缓存
                NSError *error = [note.userInfo objectForKey:AFNetworkingTaskDidCompleteErrorKey];// 错误处理
                if (error) {
                    if (error.code == -1001) {
                        NSLog(@"下载出错,看一下网络是否正常");
                    }
                    //这个是因为 用户比如强退程序之后 ,再次进来的时候 存进去这个继续的data
                    NSData *resumeData = [error.userInfo objectForKey:@"NSURLSessionDownloadTaskResumeData"];
                    [self saveHistoryWithKey:urlHost DownloadTaskResumeData:resumeData];
                } else  {
                    if ([self.downLoadHistoryDictionary valueForKey:urlHost]) {
                        [self.downLoadHistoryDictionary removeObjectForKey:urlHost];
                        [self saveDownLoadHistoryDirectory];
                    }
                }
            }
        }];
        NSString *path=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) firstObject];
        self.fileHistoryPath = [path stringByAppendingPathComponent:@"fileDownLoadHistory.plist"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.fileHistoryPath]) {
            self.downLoadHistoryDictionary =[NSMutableDictionary dictionaryWithContentsOfFile:self.fileHistoryPath];
        } else {
            self.downLoadHistoryDictionary = [[NSMutableDictionary alloc] init];
            [self.downLoadHistoryDictionary writeToFile:self.fileHistoryPath atomically:YES];
        }
    }
    return self;
}

- (void)saveHistoryWithKey:(NSString *)key DownloadTaskResumeData:(NSData *)data{
    if (!data) {
        NSString *emptyData = [NSString stringWithFormat:@""];
        [self.downLoadHistoryDictionary setObject:emptyData forKey:key];
        
    }else{
        [self.downLoadHistoryDictionary setObject:data forKey:key];
    }
    [self saveDownLoadHistoryDirectory];
}

- (void)saveDownLoadHistoryDirectory{
    [self.downLoadHistoryDictionary writeToFile:self.fileHistoryPath atomically:YES];
}


- (NSURLSessionDownloadTask *)downLoadFileWithURL:(NSString *)urlHost
                                         progress:(DownLoadProgressHandle)progress
                                    fileLocalPath:(NSURL *)localPath
                                          success:(DownLoadSuccessHandle)success
                                          failure:(DownLoadFailHandle)failure {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlHost]];
    NSURLSessionDownloadTask *downloadTask = nil;
    NSData *downLoadHistoryData = [self.downLoadHistoryDictionary objectForKey:urlHost];
    if (downLoadHistoryData.length > 0) {//断点续传下载
        downloadTask = [self.manager downloadTaskWithResumeData:downLoadHistoryData progress:^(NSProgress * _Nonnull downloadProgress) {
            if (progress) {
                progress(1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
            }
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            return localPath;
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if (httpResponse.statusCode == 404) {
                [[NSFileManager defaultManager] removeItemAtURL:filePath error:nil];
            }
            if (error) {
                if (failure) {
                    failure(error, httpResponse.statusCode);
                }
            } else {
                if (success) {
                    success(filePath, response);
                }
            }
        }];
    } else {
        //重新下载
        downloadTask = [self.manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
            if (progress) {
                progress(1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
            }
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            return localPath;
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if (httpResponse.statusCode == 404) {
                [[NSFileManager defaultManager] removeItemAtURL:filePath error:nil];
            }
            if (error) {
                if (failure) {
                    failure(error, httpResponse.statusCode);
                }
            } else {
                if (success) {
                    success(filePath, response);
                }
            }
        }];
    }
    [downloadTask resume];
    return downloadTask;
}

- (void)stopAllDownLoadTasks{
    //停止所有的下载
    if ([[self.manager downloadTasks] count]  == 0) {
        return;
    }
    for (NSURLSessionDownloadTask *task in  [self.manager downloadTasks]) {
        if (task.state == NSURLSessionTaskStateRunning) {
            [task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                
            }];
        }
    }
}

@end
