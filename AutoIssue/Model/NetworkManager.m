//
//  NetworkManager.m
//  me
//
//  Created by KLP on 2018/1/24.
//  Copyright © 2018年 bangju. All rights reserved.
//

#import "NetworkManager.h"
#import "ZZUrlTool.h"

@implementation NetworkManager


+ (NetworkManager *)getManager
{
    
    static NetworkManager *obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSString *urlString = [ZZUrlTool main];
        NSURL *baseURL = [NSURL URLWithString:urlString];
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        [config setHTTPAdditionalHeaders:@{ @"User-Agent" : @"TuneStore iOS 1.0"}];
        config.timeoutIntervalForRequest = 50;
        config.timeoutIntervalForResource = 50;
        //设置我们的缓存大小 其中内存缓存大小设置10M  磁盘缓存5M
        
        NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:10 * 1024 * 1024
                                                          diskCapacity:50 * 1024 * 1024
                                                              diskPath:nil];
        
        [config setURLCache:cache];
        obj = [[NetworkManager alloc] initWithBaseURL:baseURL
                                 sessionConfiguration:config];
        
        obj.requestSerializer= [AFHTTPRequestSerializer serializer];
        obj.responseSerializer = [AFJSONResponseSerializer serializer];
        
        obj.responseSerializer.acceptableContentTypes =  [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain", nil];

        
    });
    return obj;
    
}


+ (NetworkManager *)getInitClient{
    NSString *urlString = [ZZUrlTool main];
    NSURL *baseURL = [NSURL URLWithString:urlString];//本地测试
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    config.timeoutIntervalForRequest = 10;
    config.timeoutIntervalForResource = 20;
    //设置我们的缓存大小 其中内存缓存大小设置10M  磁盘缓存5M
    
    NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:10 * 1024 * 1024
                                                      diskCapacity:50 * 1024 * 1024
                                                          diskPath:nil];
    
    [config setURLCache:cache];
    
    NetworkManager * obj = [[NetworkManager alloc] initWithBaseURL:baseURL
                                              sessionConfiguration:config];
    
    obj.responseSerializer = [AFJSONResponseSerializer serializer];
    
    return obj;
}



- (void)postPath:(NSString *)path parameters:(NSDictionary *)parameters success_status_ok:(successBlock)success failure:(failureBlock)failure{
    
    [self POST:path parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary*dic = responseObject;
            NSString *code = [NSString stringWithFormat:@"%@",[dic valueForKey:@"code"]];
            NSString *message = [NSString stringWithFormat:@"%@",[dic valueForKey:@"message"]];
            if ([code isEqualToString:@"0"]) {
                
                success(task,[dic valueForKey:@"data"]);
            }else{
                
                failure(task,[dic valueForKey:@"message"]);
                
                if ([code isEqualToString:@"130"] && [message isEqualToString:@"登录已失效，请重新登录！"]) {
                }
            }
        }else{
            failure(task,@"解析数据出错");
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (error!=nil) {
            
            failure(task,error.localizedDescription);
        }
        
        
    }];
    
    
}


- (void)getPath:(NSString *)path parameters:(NSDictionary *)parameters success_status_ok:(successBlock)success failure:(failureBlock)failure{
    
    [self GET:path parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary*dic = responseObject;
            NSString *code = [NSString stringWithFormat:@"%@",[dic valueForKey:@"code"]];
            NSString *message = [NSString stringWithFormat:@"%@",[dic valueForKey:@"message"]];
            if ([code isEqualToString:@"0"]) {
                
                success(task,[dic valueForKey:@"data"]);
            }else{
                
                failure(task,[dic valueForKey:@"message"]);
                
                if ([code isEqualToString:@"130"] && [message isEqualToString:@"登录已失效，请重新登录！"]) {
                }
            }
        }else{
            failure(task,@"解析数据出错");
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (error!=nil) {
            
            failure(task,error.localizedDescription);
        }
        
        
    }];
    
    
}



- (void)uploadImagePostPath:(NSString *)path parameters:(NSDictionary *)parameters image:(UIImage *)image success_status_ok:(successBlock)success failure:(failureBlock)failure{
    
    [self POST:path parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        if (image) {
            NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
            [formData appendPartWithFileData:imageData name:@"file" fileName:@"iconImgage.jpg" mimeType:@"image/jpg"];
        }
        
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary*dic = responseObject;
            NSString *code = [NSString stringWithFormat:@"%@",[dic valueForKey:@"code"]];
            if ([code isEqualToString:@"0"]) {
                
                success(task,[dic valueForKey:@"data"]);
            }else{
                
                failure(task,[dic valueForKey:@"message"]);
            }
        }else{
            failure(task,@"解析数据出错");
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error!=nil) {
            
            failure(task,error.localizedDescription);
        }
    }];
    
}


@end
