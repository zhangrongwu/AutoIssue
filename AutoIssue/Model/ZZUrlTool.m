//
//  ZZUrlTool.m
//  yangsheng
//
//  Created by Macx on 17/7/7.
//  Copyright © 2017年 jam. All rights reserved.
//

#import "ZZUrlTool.h"

@implementation ZZUrlTool

+(NSString*)main
{
#if DEBUG
    return @"http://ewei.bangju.com";
#else
//    return @"http://192.168.1.131:8094";
    return @"http://ewei.bangju.com";
#endif
}

+(NSString*)fullUrlWithTail:(NSString *)tail
{
    NSString* str=[NSString stringWithFormat:@"%@/%@",[self main],tail];
    return str;
}

//+(NSURL*)qqUrl
//{
//    //[NSURL URLWithString:@"mqq://im/chat?chat_type=wpa&uin=157696423&version=1&src_type=web"]
//    NSString* qq=[[UniversalModel getUniversal]qq_number];
//    if (qq.length==0) {
////        qq=@"10001";
//        return nil;
//    }
////    return nil;
//    NSString* qqu=[NSString stringWithFormat:@"mqq://im/chat?chat_type=wpa&uin=%@&version=1&src_type=web",qq];
//    return [NSURL URLWithString:qqu];
//}

+ (UIColor*)hexColor:(NSString*)hexColor {
    
    unsigned int red, green, blue, alpha;
    NSRange range;
    range.length = 2;
    @try {
        if ([hexColor hasPrefix:@"#"]) {
            hexColor = [hexColor stringByReplacingOccurrencesOfString:@"#" withString:@""];
        }
        range.location = 0;
        [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&red];
        range.location = 2;
        [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&green];
        range.location = 4;
        [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&blue];
        
        if ([hexColor length] > 6) {
            range.location = 6;
            [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&alpha];
        }
    }
    @catch (NSException * e) {
        //        [MAUIToolkit showMessage:[NSString stringWithFormat:@"颜色取值错误:%@,%@", [e name], [e reason]]];
        //        return [UIColor blackColor];
    }
    
    return [UIColor colorWithRed:(float)(red/255.0f) green:(float)(green/255.0f) blue:(float)(blue/255.0f) alpha:(float)(1.0f)];
}


@end
