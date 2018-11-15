//
//  WechatHandler.h
//  HBGST
//
//  Created by URoad_MP on 15/10/30.
//  Copyright © 2015年 URoad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"
#import "NetworkManager.h"

@class weChatDelegateHelper;

@protocol WechatHandlerDelegate <NSObject>

- (void)getWechatInfo:(NSDictionary *)userinfo;

- (void)bindWechatReturnUnionid:(NSString *)uid withName:(NSString *)name;
@end

@interface WechatHandler : NSObject<WXApiDelegate>

+ (instancetype)sharedInstance;

@property (nonatomic,assign)id<WechatHandlerDelegate>myDelegate;
@property (nonatomic,strong)NSString *type;
@property (nonatomic,strong) NSString * ID;

- (void)wechatLogin;

- (void)bindWechat;

//+ (void)sendMsg:(EtyEvent *)msg byType:(NSInteger)type;
+ (void)sendMsg:(NSString *)msg byType:(NSInteger)type;
//+ (void)sendMsgWithEty:(EtyTour *)ety byType:(NSInteger)type;
//+ (void)sendNewsMsgWithEty:(EtyNewsTop *)ety byType:(NSInteger)type;
//+(void)sendCCtvWith:(EtyCCTV *)cctv byType:(NSInteger)type;
//+(void)sendFenliuWith:(EtyFenLiu *)cctv byType:(NSInteger)type;
+(void)cutMsg:(NSString *)msg;

@property (nonatomic,copy)void(^paySuccessBlock)(NSString *);
@property (nonatomic,copy)void(^payFairlureBlock)(NSString *);
- (BOOL)installedWechat;

@end
