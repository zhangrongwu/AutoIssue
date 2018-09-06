//
//  WKMiniProgramManager.h
//  AutoIssue
//
//  Created by zhangrongwu on 2018/9/5.
//  Copyright © 2018年 ENN. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^UnzipFileHandle)(BOOL status);
typedef void (^MainContentHandle)(NSString *indexContent, NSURL *baseUrl);
@interface WKMiniProgramManager : NSObject
+ (instancetype)shareInstance;
//小程序根路径
- (NSString *)getMiniProgramRootPath;
//当前桥程序路径
- (NSString *)getMiniProgramPathWithProgramName:(NSString *)ProgramName;
- (NSString *)createMiniProgramPathWithProgramName:(NSString *)ProgramName;
- (void)UnzipFileWithPath:(NSString *)sourceFilePath toPath:(NSString *)destinationPath handle:(UnzipFileHandle)handle;
- (void)getMiniProgramMainPageContent:(NSString *)programName handle:(MainContentHandle)Handle;
@end
