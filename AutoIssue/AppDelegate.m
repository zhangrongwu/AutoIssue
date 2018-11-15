//
//  AppDelegate.m
//  AutoIssue
//
//  Created by zhangrongwu on 2018/9/4.
//  Copyright © 2018年 ENN. All rights reserved.
//

#import "AppDelegate.h"
#import "AFNetworking.h"
#import "WKNavigationViewController.h"
#import "WKRootViewController.h"
#import "WechatHandler.h"
@interface AppDelegate ()<JPUSHRegisterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Override point for customization after application launch.
    [self startNetworkMonitoring];
    WKRootViewController *rootVC = [[WKRootViewController alloc] init];
    rootVC.miniProName = @"index";
    //    rootVC.miniProName = @"andong";
    [AVOSCloud setApplicationId:@"mrVViqg89FzygisjKybjpDm3-gzGzoHsz" clientKey:@"LUOXP4JpU4CaEe9aAlynnpTF"];
    //    统计应用
    [AVAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    WKNavigationViewController *nav = [[WKNavigationViewController alloc] initWithRootViewController:rootVC];
    nav.orientationMask = UIInterfaceOrientationMaskAll;
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window setBackgroundColor:[UIColor whiteColor]];
    [self.window setRootViewController:nav];
    [self.window makeKeyAndVisible];
    
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        // 可以添加自定义categories
        // NSSet<UNNotificationCategory *> *categories for iOS10 or later
        // NSSet<UIUserNotificationCategory *> *categories for iOS8 and iOS9
    }
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    // Optional
    // 获取IDFA
    // 如需使用IDFA功能请添加此代码并在初始化方法的advertisingIdentifier参数中填写对应值
    
    [JPUSHService setupWithOption:launchOptions appKey:@"aace746f16fe4c3dfc373a11"
                          channel:nil
                 apsForProduction:YES
            advertisingIdentifier:nil];
    
    return YES;
}

- (void)startNetworkMonitoring{
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager startMonitoring];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkingStatusDidChanged:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
}

- (void)networkingStatusDidChanged:(NSNotification*)info{
    NSDictionary *inforDict = [info userInfo];
    NSLog(@"%@", inforDict);
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    /// Required - 注册 DeviceToken
    [JPUSHService registerDeviceToken:deviceToken];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    if ([WXApi handleOpenURL:url delegate:[WechatHandler sharedInstance]]) {
        return YES;
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    if ([WXApi handleOpenURL:url delegate:[WechatHandler sharedInstance]]) {
        return YES;
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
