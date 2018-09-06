//
//  WKBottomView.h
//  AutoIssue
//
//  Created by zhangrongwu on 2018/9/5.
//  Copyright © 2018年 ENN. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger,OperationStyle) {
    OperationStyleGoBack = 1000,
    OperationStyleGoForward,
    OperationStyleRefresh,
    OperationStyleHomePage,
    OperationStyleMenu
};

@protocol WKBottomViewDelegate <NSObject>

@optional

- (void)performOperationWithStyle:(OperationStyle)style;

@end

@interface WKBottomView : UIView

@property (nonatomic,assign) id<WKBottomViewDelegate>delegate;

@end
