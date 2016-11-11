//
//  Tool.m
//  ZhongCs3.0
//
//  Created by ShaoHua Huang on 13-9-3.
//  Copyright (c) 2013年 ShaoHua Huang. All rights reserved.
//
#import "Tool.h"
@implementation Tool
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
@end
