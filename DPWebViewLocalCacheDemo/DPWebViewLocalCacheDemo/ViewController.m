//
//  ViewController.m
//  DPWebViewLocalCacheDemo
//
//  Created by yupeng xia on 2016/11/11.
//  Copyright © 2016年 yupeng xia. All rights reserved.
//

#import "ViewController.h"
#import "DPLocalCache.h"

@interface ViewController ()<UIWebViewDelegate>{

}
//网络请求活动指示器
@property(nonatomic, strong) UIActivityIndicatorView* activityIndicatorView;
@end

static NSString *const VideoHandlerScheme = @"videohandler";

@implementation ViewController
#pragma mark <----------View LifeCycle---------->
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}
-(void)dealloc{

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    DPLocalCache *urlCache = (DPLocalCache *)[NSURLCache sharedURLCache];
    [urlCache removeAllCachedResponses];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    DPLocalCache *urlCache = [[DPLocalCache alloc] initWithMemoryCapacity:20 * 1024 * 1024
                                                             diskCapacity:200 * 1024 * 1024
                                                                 diskPath:nil
                                                                cacheTime:0
                                                                 modeTybe:DOWNLOAD_MODE
                                                             subDirectory:@"dir"];
    [NSURLCache setSharedURLCache:urlCache];
    
    [self createActivityIndicatorView];
    
    self.myWebView.delegate = self;
    [self.myWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]]];
}

- (void)didEnterFullScreen:(id)sender{

}
- (void)didExitFullScreen:(id)sender{
    
}

#pragma mark <----------UIWebViewDelegate---------->
//开始网络请求
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    //显示网页加载"Loading框"和"状态栏的网络活动标志"
    [self webViewStartLoading];
    
    if ([request.URL.scheme isEqualToString:VideoHandlerScheme]) {
        NSLog(@"%@", request.URL);//在这里可以获得事件
        return NO;
    }
    return YES;
}

//开始加载
- (void)webViewDidStartLoad:(UIWebView *)webView{
    [self webViewStartLoading];
}
//加载完成
- (void)webViewDidFinishLoad:(UIWebView *) webView{
    //隐藏网页加载"Loading框"和"状态栏的网络活动标志"
    [self webViewStopLoading];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"video" ofType:@"js"];
    NSString *videoHandlerString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    
    if (videoHandlerString) {
        [webView stringByEvaluatingJavaScriptFromString:videoHandlerString];
    }
}
//加载失败与错误
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    //隐藏网页加载"Loading框"和"状态栏的网络活动标志"
    [self webViewStopLoading];
}

#pragma mark 网页加载"开始"或"结束",加载loading框，加载状态栏的网络活动标志
//创建网络请求"菊花"
- (void)createActivityIndicatorView{
    if (!_activityIndicatorView) {
        self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityIndicatorView.color = [UIColor darkGrayColor];
        _activityIndicatorView.center = self.view.center;
        [self.view bringSubviewToFront:_activityIndicatorView];
        _activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        [self.view addSubview:_activityIndicatorView];
    }else{
        [self.view bringSubviewToFront:_activityIndicatorView];
    }
}
//显示网页加载"Loading框"和"状态栏的网络活动标志"
- (void)webViewStartLoading{
    //菊花开始旋转
    if (_activityIndicatorView) {
        [self.view bringSubviewToFront:_activityIndicatorView];
        [_activityIndicatorView startAnimating];
    }
    //打开状态栏的网络活动标志
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}
//隐藏网页加载"Loading框"和"状态栏的网络活动标志"
- (void)webViewStopLoading{
    //菊花停止旋转
    if (_activityIndicatorView) {
        [_activityIndicatorView stopAnimating];
    }
    //关闭状态栏的网络活动标志
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}


@end
