//
//  DPLocalCacheTool.m
//  DPWebViewLocalCacheDemo
//
//  Created by yupeng xia on 2016/11/14.
//  Copyright © 2016年 yupeng xia. All rights reserved.
//

#import "DPLocalCacheTool.h"

@implementation DPLocalCacheTool
///加密
+ (NSString *)md5Hash:(NSString *)str{
    const char *cStr = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
            ];
}
///删除URL中的参数（键值对） aParam:键
+ (NSString *)urlDeleteValueOfParam:(NSString *)url withParam:(NSString *)aParam{
    
    NSError *error;
    NSString *regTags=[[NSString alloc] initWithFormat:@"(^|&|\\?)+%@=+([^&]*)(&|$)",aParam];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regTags
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    // 执行匹配的过程
    NSArray *matches = [regex matchesInString:url
                                      options:0
                                        range:NSMakeRange(0, [url length])];
    NSString *tagValue = @"";
    for (NSTextCheckingResult *match in matches) {
        tagValue = [url substringWithRange:[match rangeAtIndex:2]];  // 分组2所对应的
    }
    
    NSMutableString *mutableUrl = [NSMutableString stringWithFormat:@"%@",url];
    
    NSString *newUrl;
    
    NSString *oldKeyValue = [NSString stringWithFormat:@"&%@=%@",aParam,tagValue];
    NSRange range = [mutableUrl rangeOfString:oldKeyValue];
    if (range.location != NSNotFound) {
        newUrl = [mutableUrl stringByReplacingOccurrencesOfString:oldKeyValue withString:@""];
    }else{
        oldKeyValue = [NSString stringWithFormat:@"%@=%@",aParam,tagValue];
        range = [mutableUrl rangeOfString:oldKeyValue];
        if (range.location != NSNotFound) {
            newUrl = [mutableUrl stringByReplacingOccurrencesOfString:oldKeyValue withString:@""];
        }
    }
    return newUrl;
    
}
@end
