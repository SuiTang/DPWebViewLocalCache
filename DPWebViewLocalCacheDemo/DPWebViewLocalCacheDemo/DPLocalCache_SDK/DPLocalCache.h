//
//  DPLocalCache.h
//  DPLocalCache
//
//  Created by yupeng xia on 2016/11/10.
//  Copyright © 2016年 yupeng xia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
#import "Tool.h"

typedef enum : NSUInteger{
    NORMAL_MODE = 0,    //系统的缓存 (ustomCache和NSURLCache的功能是一样的)
    DOWNLOAD_MODE = 1   //自定义缓存 (CustomURLCache则可以实现包含自定义下载目录，设置过期时间的子功能的下载功能)
}MODE_TYPE;
@interface DPLocalCache : NSURLCache
@property(nonatomic, assign) NSInteger cacheTime;       //缓存有效时间
@property(nonatomic, strong) NSString *diskPath;        //沙盒路径
@property(nonatomic, strong) NSString *subDirectory;    //子路径
@property(nonatomic, assign) MODE_TYPE aMode;           //缓存类型
@property(nonatomic, strong) NSMutableDictionary *responseDictionary;   //响应的字典
@property(nonatomic, strong) NSMutableDictionary *localReourcePath;     //手动添加本地缓存

///初始缓存存储本地空间
- (id)initWithMemoryCapacity:(NSUInteger)memoryCapacity diskCapacity:(NSUInteger)diskCapacity diskPath:(NSString *)path cacheTime:(NSInteger)cacheTime modeTybe:(MODE_TYPE)aModeTybe subDirectory:(NSString*)subDirectory;

///目录完整路径
- (NSString*)subDirectoryFullPath;
///获得磁盘缓存请求
- (NSString*)getDiskCacheForRequest:(NSString *)request;
///添加本地资源到本地
- (void)addLocalReourcePath:(NSString*)path request:(NSString*)request;
///不再使用系统的缓存，而是换到自定义缓存_传入自定义文件地址
- (void)changeToDownloadMode:(NSString *)downDir;
///不再使用自定义缓存，而是换到系统的缓存
- (void)changeToNormalMode;
@end
