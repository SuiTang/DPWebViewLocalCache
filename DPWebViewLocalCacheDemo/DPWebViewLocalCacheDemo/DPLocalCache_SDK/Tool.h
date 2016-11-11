//
//  Tool.h
//  ZhongCs3.0
//
//  Created by ShaoHua Huang on 13-9-3.
//  Copyright (c) 2013年 ShaoHua Huang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface Tool : NSObject
///加密
+ (NSString *)md5Hash:(NSString *)str;
@end
