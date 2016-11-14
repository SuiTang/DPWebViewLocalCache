//
//  ViewController.m
//  DPWebViewLocalCacheDemo
//
//  Created by yupeng xia on 2016/11/11.
//  Copyright © 2016年 yupeng xia. All rights reserved.
//

#import "ViewController.h"
#import "DPLocalCache.h"

@interface ViewController ()

@end

@implementation ViewController

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
    [self.myWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://github.com/xiayuqingfeng"]]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    DPLocalCache *urlCache = (DPLocalCache *)[NSURLCache sharedURLCache];
    [urlCache removeAllCachedResponses];
}


@end
