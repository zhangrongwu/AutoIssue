//
//  NetworkManager.h
//  me
//
//  Created by KLP on 2018/1/24.
//  Copyright © 2018年 bangju. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  接口调用成功后的block
 *
 *  @param operation
 *  @param data      返回json数据里的data数据
 */
typedef void (^successBlock) (NSURLSessionDataTask *task , id data);
typedef void (^failureBlock) (NSURLSessionDataTask *task , NSString *errorMsg);

@interface NetworkManager : AFHTTPSessionManager

+ (NetworkManager *)getInitClient;

+ (NetworkManager *)getManager;

- (void)postPath:(NSString *)path parameters:(NSDictionary *)parameters success_status_ok:(successBlock)success failure:(failureBlock)failure;

- (void)uploadImagePostPath:(NSString *)path parameters:(NSDictionary *)parameters image:(UIImage *)image success_status_ok:(successBlock)success failure:(failureBlock)failure;


- (void)getPath:(NSString *)path parameters:(NSDictionary *)parameters success_status_ok:(successBlock)success failure:(failureBlock)failure;

@end
