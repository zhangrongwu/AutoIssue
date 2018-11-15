//
//  WKBottomView.m
//  AutoIssue
//
//  Created by zhangrongwu on 2018/9/5.
//  Copyright © 2018年 ENN. All rights reserved.
//

#import "WKBottomView.h"
#import "ZZUrlTool.h"

@interface WKBottomView ()
{
    UIView *lineView;
    NSMutableArray *buttonsArray;
}

@end

@implementation WKBottomView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        buttonsArray = [[NSMutableArray alloc] init];
        [self setBackgroundColor:[ZZUrlTool hexColor:@"#09AC13"]];
        [self createSubViews];
    }
    return self;
}

- (void)createSubViews{
    
    NSArray *imageNameArr = [[NSArray alloc] init];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"tabTinColor"] isEqualToString:@"1"]) {
        imageNameArr = @[@"wbackForword",@"wforword",@"wRefresh",@"whomePage",@"wuserother"];
    } else {
        imageNameArr = @[@"wbackForword_white",@"wforword_white",@"wRefresh_white",@"whomePage_white",@"wuserother_white"];
    }
    
    NSInteger count = imageNameArr.count;
    CGFloat width = self.frame.size.width/count;
    CGFloat height = 49;
    for (int i = 0;i < count; i++) {
        NSString *normal = [imageNameArr objectAtIndex:i];
        NSString *highLight = [normal stringByAppendingString:@"h"];
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(width*i, 0, width, height)];
        [button setImage:[UIImage imageNamed:normal] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:highLight] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [button setTag: (i+1000)];
        [self addSubview:button];
        [button setTintColor:[UIColor whiteColor]];
        [buttonsArray addObject:button];
    }
    
    lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0.5)];
    [lineView setBackgroundColor:ColorFromSixteen(0xb4b4b4, 1)];
    [self addSubview:lineView];
}

- (void)buttonAction:(UIButton*)button{
    if (self.delegate && [self.delegate respondsToSelector:@selector(performOperationWithStyle:)]) {
        [self.delegate performOperationWithStyle:button.tag];
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    lineView.frame = CGRectMake(0, 0, self.frame.size.width, 0.5);
    
    NSInteger count = buttonsArray.count;
    CGFloat width = self.frame.size.width/count;
    CGFloat height = 49;
    [buttonsArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *button = (UIButton*)obj;
        button.frame = CGRectMake(width*idx, 0, width, height);
    }];
}

@end
