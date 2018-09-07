//
//  WKMiniProgramManager.m
//  AutoIssue
//
//  Created by zhangrongwu on 2018/9/5.
//  Copyright © 2018年 ENN. All rights reserved.
//

#import "WKMiniProgramManager.h"
#import "ZipArchive.h"
#import "WKFileManager.h"
#import "WKNetworkDownLoadManager.h"
@interface WKMiniProgramManager()
@property (nonatomic, copy)MainContentHandle handle;
@end
@implementation WKMiniProgramManager


+ (instancetype)shareInstance {
    static dispatch_once_t once;
    static WKMiniProgramManager *program;
    dispatch_once(&once, ^{
        program = [[self alloc] init];
    });
    return program;
}

- (NSString *)getMiniProgramRootPath {
    return [WKFileManager createPathWithChildPath:@"MiniProgram"];
}

//当前小程序路径
- (NSString *)getMiniProgramPathWithProgramName:(NSString *)ProgramName {
    return [[self getMiniProgramRootPath] stringByAppendingPathComponent:ProgramName];
}

- (NSString *)createMiniProgramPathWithProgramName:(NSString *)ProgramName {
    NSString *path = [[self getMiniProgramRootPath] stringByAppendingPathComponent:ProgramName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirExist = [fileManager fileExistsAtPath:path];
    if (!isDirExist) {
        NSError *err;
        BOOL isCreateDir = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&err];
        if (!isCreateDir) {
            return nil;
        }
    }
    return path;
}

//解压
- (void)UnzipFileWithPath:(NSString *)sourceFilePath toPath:(NSString *)destinationPath handle:(UnzipFileHandle)handle {
    
    ZipArchive* zip = [[ZipArchive alloc] init];
    if( [zip UnzipOpenFile:sourceFilePath] ){
        BOOL result = [zip UnzipFileTo:destinationPath overWrite:YES];
        if( NO==result ){
            //添加代码
            NSLog(@"解压失败");
            if (handle) {
                handle(NO);
            }
        }else{
            NSLog(@"解压成功");
            handle(YES);
        }
        [zip UnzipCloseFile];
    }
}

- (void)getMiniProgramMainPageContent:(NSString *)programName handle:(MainContentHandle)Handle {
    self.handle=Handle;
    NSString *index = [[[WKMiniProgramManager shareInstance] getMiniProgramPathWithProgramName:programName] stringByAppendingPathComponent:@"dist/index.html"];
    NSString *basePath = [[[WKMiniProgramManager shareInstance] getMiniProgramPathWithProgramName:programName] stringByAppendingPathComponent:@"dist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:index]) {
        NSLog(@"存在");
        [self loadRequestWithPath:basePath];
    } else {
        NSLog(@"不存在");
        NSString *toPath = [[WKMiniProgramManager shareInstance] getMiniProgramRootPath];
        
        if ([programName isEqualToString:@"index"]) {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"index.zip" ofType:nil];
            [[WKMiniProgramManager shareInstance] UnzipFileWithPath:path toPath:toPath handle:^(BOOL status) {
                //本地加载页面
                [self loadRequestWithPath:basePath];
            }];
        } else {
            NSString *local = [[WKMiniProgramManager shareInstance] getMiniProgramRootPath];
            NSString *fileLocal = [local stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip", programName]];
          
            [[WKNetworkDownLoadManager shareInstance] downLoadFileWithURL:[NSString stringWithFormat:@"%@%@.zip", BASE_URL, programName]
                                                                 progress:^(CGFloat progress) {
            } fileLocalPath:[NSURL fileURLWithPath:fileLocal isDirectory:NO] success:^(NSURL *filePath, NSURLResponse *response) {
                NSString *newFilePath = [[[filePath absoluteString] stringByReplacingOccurrencesOfString:@"file://" withString:@""] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [[WKMiniProgramManager shareInstance] UnzipFileWithPath:newFilePath
                                                                 toPath:toPath
                                                                 handle:^(BOOL status) {
                                                                     //本地加载页面
                                                                     if (status) {
                                                                         [self loadRequestWithPath:basePath];
                                                                         [WKFileManager removeFileAtPath:newFilePath];
                                                                     }
                                                                 }];
            } failure:^(NSError *error, NSInteger statusCode) {
            }];
            
        }
    }
}

- (void)loadRequestWithPath:(NSString *)basePath {
    NSURL *baseUrl = [NSURL fileURLWithPath: basePath isDirectory: YES];
    NSString *indexPath = [NSString stringWithFormat: @"%@/index.html", basePath];
    NSString *indexContent = [NSString stringWithContentsOfFile:
                              indexPath encoding: NSUTF8StringEncoding error:nil];
    if (self.handle) {
        self.handle(indexContent, baseUrl);
    }
}



@end
