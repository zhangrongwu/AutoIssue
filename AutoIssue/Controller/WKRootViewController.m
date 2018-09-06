//
//  WKRootViewController.m
//  AutoIssue
//
//  Created by zhangrongwu on 2018/9/5.
//  Copyright © 2018年 ENN. All rights reserved.
//

#import "WKRootViewController.h"
#import "WKMiniProgramManager.h"
#import "WKProgressView.h"
#import "WKBottomView.h"
#import <WebKit/WebKit.h>
#import "WKNetworkDownLoadManager.h"
#define PROGRESS_HEIGHT     2.0f

@interface WKRootViewController ()<WKUIDelegate,WKNavigationDelegate,UIGestureRecognizerDelegate,WKBottomViewDelegate>
@property (nonatomic, strong)WKBottomView *contentBottomView;
@property (nonatomic,strong) WKProgressView *progressView;
@property (nonatomic, strong)WKWebView *kWKWebView;
@end

@implementation WKRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.contentBottomView = [[WKBottomView alloc] initWithFrame:CGRectMake(0, MainScreenHeight - TabBarHeight, MainScreenWidth, TabBarHeight)];
    self.contentBottomView.delegate = self;
    
    WKUserContentController *userContentController = [[WKUserContentController alloc] init];
    NSString *source = @"";
    WKUserScriptInjectionTime injectionTime = WKUserScriptInjectionTimeAtDocumentStart;
    BOOL forMainFrameOnly = NO;
    WKUserScript *script = [[WKUserScript alloc] initWithSource:source injectionTime:injectionTime forMainFrameOnly:forMainFrameOnly];
    [userContentController addUserScript:script];
    
    WKProcessPool *processPool = [[WKProcessPool alloc] init];
    WKWebViewConfiguration *webViewController = [[WKWebViewConfiguration alloc] init];
    webViewController.processPool = processPool;
    webViewController.userContentController = userContentController;
    
    self.kWKWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, StatusBarHeight, self.view.frame.size.width, MainScreenHeight - StatusBarHeight - self.contentBottomView.frame.size.height) configuration:webViewController];
    self.kWKWebView.UIDelegate = self;
    self.kWKWebView.navigationDelegate = self;
    self.kWKWebView.allowsBackForwardNavigationGestures = YES;
    [self.view addSubview:self.kWKWebView];
    [self.view addSubview:self.contentBottomView];
    
    if (@available(iOS 11,*)) {
        self.kWKWebView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    [self.kWKWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
    UILongPressGestureRecognizer *longPressGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    longPressGes.delegate = self;
    longPressGes.minimumPressDuration = 0.35;
    [self.kWKWebView addGestureRecognizer:longPressGes];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat height  = IsPortrait?TabBarHeight:BGNaviBarHeight;
    CGFloat originY = IsPortrait?(MainScreenHeight - height):MainScreenHeight;
    self.contentBottomView.frame = CGRectMake(0, originY, MainScreenWidth, height);
    
    [self resetContentWebFrame];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSString *name = [self.kWKWebView.URL absoluteString];
    if (name == nil) {
        [self loadMainPageContent];
    }
}

- (void)loadMainPageContent{
    [[WKMiniProgramManager shareInstance] getMiniProgramMainPageContent:self.miniProName handle:^(NSString *indexContent, NSURL *baseUrl) {
        [self.kWKWebView loadHTMLString:indexContent baseURL:baseUrl];
    }];
}

- (void)resetContentWebFrame{
    CGFloat originY = IsPortrait?(iPhoneX?(StatusBarHeight-10):StatusBarHeight):0;
    CGFloat height  = self.contentBottomView.frame.origin.y - originY;
    
    if (self.progressView) {
        self.progressView.frame = CGRectMake(0, originY, _progressView.frame.size.width, PROGRESS_HEIGHT);
    }
    
    self.kWKWebView.frame = CGRectMake(0, originY, MainScreenWidth, height);
    
    CGFloat y = 0;//IsPortrait?(IOS11?0:0):0;
    self.kWKWebView.scrollView.contentInset = UIEdgeInsetsMake(y, 0, 0, 0);
    self.kWKWebView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)performOperationWithStyle:(OperationStyle)style {
    switch (style) {
        case OperationStyleGoBack:
        {
            if ([self.kWKWebView canGoBack]) {
                [self.kWKWebView goBack];
            }

        }
            break;
        case OperationStyleGoForward:
        {
            if ([self.kWKWebView canGoForward]) {
                [self.kWKWebView goForward];
            }
        }
            break;
        case OperationStyleRefresh:
        {
            [self.kWKWebView reload];
        }
            break;
        case OperationStyleMenu:
        {
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:@"是否使用浏览器打开?" preferredStyle:UIAlertControllerStyleAlert];
            [controller addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }]];
            
            [controller addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self openContentUseB];
            }]];
            
            [self presentViewController:controller animated:YES completion:nil];
        }
            break;
        case OperationStyleHomePage:
        {
            if (self.kWKWebView.backForwardList != nil && self.kWKWebView.backForwardList.backList.count > 0) {
                [self.kWKWebView goToBackForwardListItem:[self.kWKWebView.backForwardList.backList firstObject]];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)openContentUseB{
    NSURL *url = self.kWKWebView.URL;
    if (url == nil) {
        url = [NSURL URLWithString:[url absoluteString]];
    }
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }else{
        [SVProgressHUD showInfoWithStatus:@"加载失败"];
    }
}

//保存图片
- (void)longPressAction:(UIGestureRecognizer*)ges{

    
    CGPoint point = [ges locationInView:self.kWKWebView];
    NSString *jsStr = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src",point.x,point.y];
    
    [self.kWKWebView evaluateJavaScript:jsStr completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
        NSString *imageUrlStr = (NSString*)obj;
        if ([imageUrlStr rangeOfString:@"http://"].location != NSNotFound) {
            imageUrlStr = [imageUrlStr stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([imageUrlStr length] > 0) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                [alertController addAction:[UIAlertAction actionWithTitle:@"保存图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:imageUrlStr] options:SDWebImageDownloaderHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                        
                    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);

                    }];
                }]];
                
                [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                }]];
                
                [self presentViewController:alertController animated:YES completion:nil];
            }
        });
    }];
}

#pragma mark 图片保存的回调
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo{
    if (error == nil) {
        [SVProgressHUD showSuccessWithStatus:@"图片保存成功"];
    }else{
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"图片保存失败，无法访问相册"
                                                                            message:@"请在“设置>隐私>照片”打开相册访问权限"
                                                                     preferredStyle:UIAlertControllerStyleAlert];
        [controller addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        
        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    if (object == self.kWKWebView) {
        if ([keyPath isEqualToString:@"estimatedProgress"]) {
            CGFloat newValue = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
            if (newValue == 1) {
                self.progressView.hidden = YES;
                self.progressView.frame  = CGRectMake(0, self.progressView.frame.origin.y, 0, PROGRESS_HEIGHT);
            }else{
                self.progressView.hidden = NO;
                [UIView animateWithDuration:0.2 animations:^{
                    self.progressView.frame = CGRectMake(0, self.progressView.frame.origin.y, MainScreenWidth*newValue, PROGRESS_HEIGHT);
                }];
            }
        }
    }
}

#pragma mark -------------------------  进度条
- (WKProgressView*)progressView{
    if (_progressView == nil) {
        _progressView = [[WKProgressView alloc] initWithFrame:CGRectMake(0, NaviBarHeight, 0, PROGRESS_HEIGHT)];
        [self.view addSubview:_progressView];
    }
    
    [self.view bringSubviewToFront:_progressView];
    return _progressView;
}

@end
