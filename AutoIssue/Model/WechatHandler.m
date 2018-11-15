//
//  WechatHandler.m
//  HBGST
//
//  Created by URoad_MP on 15/10/30.
//  Copyright © 2015年 URoad. All rights reserved.
//

#import "WechatHandler.h"


@interface WechatHandler()
@property (nonatomic,strong)NSString *access_token;
@property (nonatomic,strong)NSString *expires_in;
@property (nonatomic,strong)NSString *openid;
@property (nonatomic,strong)NSString *refresh_token;
@property (nonatomic,strong)NSString *scope;


@end

@implementation WechatHandler
{
    NetworkManager *wechatClient;
    BOOL isLogin;
}
+ (instancetype)sharedInstance {
    static WechatHandler *obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[WechatHandler alloc]init];
    });
    return obj;
}

- (id)init{
    self = [super init];
    if (self) {
        wechatClient = [NetworkManager getInitClient];
    }
    return self;
}

- (void)wechatLogin{
    isLogin = YES;
    SendAuthReq *req = [[SendAuthReq alloc]init];
    req.scope = @"snsapi_userinfo";
    req.state = @"";
    [WXApi sendReq:req];
}

- (void)bindWechat{
    isLogin = NO;
    SendAuthReq *req = [[SendAuthReq alloc]init];
    req.scope = @"snsapi_userinfo";
    req.state = @"";
    [WXApi sendReq:req];
}

- (void)onReq:(BaseReq *)req{
    
}

- (void)onResp:(BaseResp *)resp{
    int status = resp.errCode;
    if (status == 0) {
        if ([resp isKindOfClass:[SendMessageToWXResp class]]) {

            
        }
        else if ([resp isKindOfClass:[PayResp class]]){
            PayResp*p=(PayResp*)resp;
            switch (p.errCode) {
                case WXSuccess:
                    self.paySuccessBlock(@"支付成功,感谢您的使用");
                    break;
                case WXErrCodeCommon:
                    self.payFairlureBlock(@"支付失败,请稍后重试");
                    break;
                case WXErrCodeUserCancel:
                    self.payFairlureBlock(@"支付失败,请稍后重试");
                    break;
                default:
                    self.payFairlureBlock(@"支付失败");
                    break;
            }
        }
        else {
            SendAuthResp *auth = resp;
            NSString *code = auth.code;
//            [self getAccessToken:code];
            [self beginWeChatLogin:code];

        }

    }else{
        
    }
}



- (void)beginWeChatLogin:(NSString*)code{
    
    [wechatClient postPath:@"/app/index.php?i=1&c=entry&m=ewei_shopv2&do=api&r=account.sns" parameters:@{@"sns":@"wx",@"code":code} success_status_ok:^(NSURLSessionDataTask *task, id data) {
        
    } failure:^(NSURLSessionDataTask *task, NSString *errorMsg) {
        
    }];
    
}





- (void)getAccessToken:(NSString *)code{
    
    NSString *kWechatAppKey = @"";
    NSString *kWechatAppSecret = @"";
    NSDictionary *param = @{@"code":code,@"appid":kWechatAppKey,@"secret":kWechatAppSecret,@"grant_type":@"authorization_code"};
    
//    wxa544f4ffe0ce6025
    
    
    [wechatClient POST:@"oauth2/access_token?" parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            
            self.access_token = [responseObject valueForKey:@"access_token"];
            self.expires_in = [responseObject valueForKey:@"expires_in"];
            self.openid = [responseObject valueForKey:@"openid"];
            self.refresh_token = [responseObject valueForKey:@"refresh_token"];
            self.scope = [responseObject valueForKey:@"scope"];
            [self getWechatUserInfo];
            
            
           
        }else{
            
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    }];
}





- (void)getWechatUserInfo{
    
    
    NSString *requestURL = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",self.access_token,self.openid];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestURL]];
    request.HTTPMethod = @"GET";
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
//        NSString*resp = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSError *error;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        if (json) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//            });

            NSString *nickname = [json valueForKey:@"nickname"];
            NSString *headimgurl =[json valueForKey:@"headimgurl"];
            
            NSDictionary *userinfo = @{@"nickname":nickname,@"headpic":headimgurl};
            if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(getWechatInfo:)]) {
                [self.myDelegate getWechatInfo:userinfo];
            }

        }else{
        }
    }];
    
    
}
- (BOOL)installedWechat{
    return [WXApi isWXAppInstalled];
}

@end
