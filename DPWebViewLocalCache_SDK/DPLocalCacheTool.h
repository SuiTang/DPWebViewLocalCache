//
//  DPLocalCacheTool.h
//  DPWebViewLocalCacheDemo
//
//  Created by yupeng xia on 2016/11/14.
//  Copyright © 2016年 yupeng xia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface DPLocalCacheTool : NSURLCache
///加密
+ (NSString *)md5Hash:(NSString *)str;
///删除URL中的参数（键值对） aParam:键
+ (NSString *)urlDeleteValueOfParam:(NSString *)url withParam:(NSString *)aParam;
@end
