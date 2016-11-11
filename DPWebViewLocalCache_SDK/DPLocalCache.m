//
//  DPLocalCache.m
//  DPLocalCache
//
//  Created by yupeng xia on 2016/11/10.
//  Copyright © 2016年 yupeng xia. All rights reserved.
//

#import "DPLocalCache.h"

@implementation DPLocalCache
- (id)initWithMemoryCapacity:(NSUInteger)memoryCapacity diskCapacity:(NSUInteger)diskCapacity diskPath:(NSString *)path cacheTime:(NSInteger)cacheTime modeTybe:(MODE_TYPE)aModeTybe subDirectory:(NSString*)subDirectory{
    if (self = [self initWithMemoryCapacity:memoryCapacity diskCapacity:diskCapacity diskPath:path]) {
        if (path){
            self.diskPath = path;
        }else{
            self.diskPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        }
        NSLog(@"disk path %@",self.diskPath);
        
        self.cacheTime = cacheTime;
        self.aMode = aModeTybe;
        self.subDirectory = subDirectory;
        
        self.responseDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
        //手动添加本地缓存
        self.localReourcePath = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return self;
}

#pragma mark <----------重写NSURLCache函数---------->
#pragma mark 缓存的响应请求 (如果对应的NSURLRequest没有cached的response那么返回nil)
- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request{
    NSString *url = request.URL.absoluteString;
    //    NSLog(@"normal mode:%@",[[request URL]absoluteString]);
    //    NSLog(@"data from request %@",[request description]);
    
    if (_aMode == NORMAL_MODE) {//使用系统缓存类型
        return [super cachedResponseForRequest:request];
    }
    
    if ([request.HTTPMethod compare:@"GET"] != NSOrderedSame) {//不处理非get请求
        return [super cachedResponseForRequest:request];
    }
    
    if ([self.localReourcePath objectForKeyedSubscript:url] != nil) {//手动添加本地缓存不为空
        NSCachedURLResponse *cachedResponse = [self loadLocalResouce:request path:[self.localReourcePath objectForKey:url]];
        if (cachedResponse != nil) {//添加成功
            return cachedResponse;
        }else {//添加失败
            return [self dataFromRequest:request];
        }
    }
    return  [self dataFromRequest:request];
}
/*
 *网络请求本地缓存处理
 *没有网络使用本地缓存;
 *有网络使添加本地缓存;
 */
- (NSCachedURLResponse *)dataFromRequest:(NSURLRequest *)request{
    NSString *url = request.URL.absoluteString;
    //当前资源 的本地存储子目录的文件名
    NSString *fileName = [self cacheRequestFileName:url];
    //当前资源描述文件 的本地存储子目录的文件名
    NSString *otherInfoFileName = [self cacheRequestDescriptionFileName:url];
    //当前资源 的本地存储路径
    NSString *filePath = [self cacheFilePath:fileName];
    //当前资源描述文件 的本地存储路径
    NSString *otherInfoPath = [self cacheFilePath:otherInfoFileName];
    
    NSDate *date = [NSDate date];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if (internetStatus != NotReachable) {
        //my web-dependent code
        
    }else {
        //there-is-no-connection warning
    }
    if (internetStatus == NotReachable) {
        //网络不可用，使用本地缓存
        if ([fileManager fileExistsAtPath:filePath]) {
            BOOL expire = false;
            NSDictionary *otherInfo = [NSDictionary dictionaryWithContentsOfFile:otherInfoPath];
            
            if (self.cacheTime > 0) {
                NSInteger createTime = [[otherInfo objectForKey:@"time"] intValue];
                if (createTime + self.cacheTime < [date timeIntervalSince1970]) {
                    expire = true;
                }
            }
            
            if (expire == false) {//缓存有效
                NSData *data = [NSData dataWithContentsOfFile:filePath];
                NSURLResponse *response = [[NSURLResponse alloc] initWithURL:request.URL
                                                                    MIMEType:[otherInfo objectForKey:@"MIMEType"]
                                                       expectedContentLength:data.length
                                                            textEncodingName:[otherInfo objectForKey:@"textEncodingName"]];
                NSCachedURLResponse *cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:data];
                return cachedResponse;
            }else {//缓存到期
                [fileManager removeItemAtPath:filePath error:nil];
                [fileManager removeItemAtPath:otherInfoPath error:nil];
                return  nil;
            }
        }
        
    }else{
        //网络可用，相对应的网页本地缓存不存在，存储本地缓存
        
        id boolExsite = [_responseDictionary objectForKey:url];
        if (boolExsite == nil) {
            [self.responseDictionary setValue:[NSNumber numberWithBool:TRUE] forKey:url];
            
            __block NSCachedURLResponse *cachedResponse = nil;
            
            [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data,NSError *error) {
                NSLog(@"下载资源结束返回地址: %@", request.URL.absoluteString);
                
                if (response && date) {
                    //[_responseDictionary removeObjectForKey:url];
                    
                    if (error) {
                        NSLog(@"error : %@", error);
                        cachedResponse = nil;
                    }else {
                        //生成缓存资源的描述文件
                        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f", [date timeIntervalSince1970]], @"time", response.MIMEType, @"MIMEType", response.textEncodingName, @"textEncodingName", nil];
                        //缓存资源的描述文件存入本地
                        BOOL otherInfoResult = [dict writeToFile:otherInfoPath atomically:YES];
                        //缓存资源存入本地
                        BOOL result = [data writeToFile:filePath atomically:YES];
                        if(otherInfoResult == NO || result == NO) {
                            //NSLog(@"写入错误");
                        }else {
                            //NSLog(@"写入成功");
                        }
                        cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:data];
                        
                    }
                }
            }];
            [super storeCachedResponse:cachedResponse forRequest:request];
            return cachedResponse;
        }
        
    }
    return nil;
}
//手动添加本地缓存处理，输出缓存内容
- (NSCachedURLResponse*)loadLocalResouce:(NSURLRequest*)request path:(NSString*)path{
    //NSLog(@"load from local source %@,%@",request.URL.absoluteString,path);
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        return nil;
    }
    
    // Load the data
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    // Create the cacheable response
    NSURLResponse *response = [[NSURLResponse alloc]
                               initWithURL:[request URL]
                               MIMEType:[self mimeTypeForPath:[[request URL] absoluteString]]
                               expectedContentLength:[data length]
                               textEncodingName:nil];
    
    NSCachedURLResponse *cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:data];
    [self storeCachedResponse:cachedResponse forRequest:request];
    return cachedResponse;
}

#pragma mark 移除特定NSURLRequest的cache
- (void)removeCachedResponseForRequest:(NSURLRequest *)request{
    [super removeCachedResponseForRequest:request];
    //这句要不要需要测试一下
    NSString *url = request.URL.absoluteString;
    NSString *fileName = [self cacheRequestFileName:url];
    NSString *otherInfoFileName = [self cacheRequestDescriptionFileName:url];
    NSString *filePath = [self cacheFilePath:fileName];
    NSString *otherInfoPath = [self cacheFilePath:otherInfoFileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:filePath error:nil];
    [fileManager removeItemAtPath:otherInfoPath error:nil];
}

#pragma mark 移除所有的cache
- (void)removeAllCachedResponses{
    [super removeAllCachedResponses];
    
    //    [self deleteCacheFolder];
}

#pragma mark <----------缓存使用过程中的处理---------->
#pragma mark 获取文件路径_file:文件名称
- (NSString *)cacheFilePath:(NSString *)file{
    NSString *path = [NSString stringWithFormat:@"%@/%@", self.diskPath, [self cacheFolder]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if ([fileManager fileExistsAtPath:path isDirectory:&isDir] && isDir) {
        
    }else {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *subDirPath = [NSString stringWithFormat:@"%@/%@/%@",self.diskPath,[self cacheFolder],self.subDirectory];
    if ([fileManager fileExistsAtPath:subDirPath isDirectory:&isDir] && isDir) {
        
    }else {
        [fileManager createDirectoryAtPath:subDirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSLog(@"缓存本地存储路径: %@",[NSString stringWithFormat:@"%@/%@", subDirPath, file]);
    return [NSString stringWithFormat:@"%@/%@", subDirPath, file];
}

#pragma mark 删除缓存文件夹
- (void)deleteCacheFolder{
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@", self.diskPath, [self cacheFolder],_subDirectory];
    NSLog(@"delete file:%@",path);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:path error:nil];
}
#pragma mark 根据当前资源的网址，生成 当前资源 的本地存储子目录的文件名
- (NSString *)cacheRequestFileName:(NSString *)requestUrl{
    //子目录名字转义
    NSString *subPath = [Tool md5Hash:[Tool md5Hash:requestUrl]];
    //获得文件的后缀名（不带'.'）
    NSString *exestr = [requestUrl pathExtension];
    if (exestr.length > 0) {
        //处理文件，根据相对应的格式生成相对应文件名称
        subPath = [NSString stringWithFormat:@"%@.%@",subPath,exestr];
    }
    //    NSLog(@"资源_子目录:%@",subPath);
    return subPath;
}
#pragma mark 根据当前资源的网址，生成 当前资源描述文件 的本地存储子目录的文件名
- (NSString *)cacheRequestDescriptionFileName:(NSString *)requestUrl{
    NSString *subPath = [Tool md5Hash:[NSString stringWithFormat:@"%@-otherInfo", requestUrl]];
    //    NSLog(@"资源_描述文件_子目录:%@",subPath);
    return subPath;
}
#pragma mark 自定义缓存_本地存储文件夹
- (NSString *)cacheFolder{
    return @"URLCACHE";
}
#pragma mark 当前代码只有替代品PNG图像
- (NSString *)mimeTypeForPath:(NSString *)originalPath{
    return @"image/png";
}

#pragma mark <----------公共函数---------->
#pragma mark 目录完整路径
- (NSString*)subDirectoryFullPath{
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@", self.diskPath, [self cacheFolder],_subDirectory];
    return  path;
}
#pragma mark 获得磁盘缓存请求
- (NSString*) getDiskCacheForRequest:(NSString *)request{
    NSString *url = request;
    NSString *fileName = [self cacheRequestFileName:url];
    NSString *filePath = [self cacheFilePath:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        return filePath;
    }
    else
    {
        return nil;
    }
}
#pragma mark 手动添加本地缓存
- (void)addLocalReourcePath:(NSString *)path request:(NSString *)request{
    if ([self.localReourcePath objectForKey:request] != nil) {
        return;
    }
    [self.localReourcePath setObject:path forKey:request];
    return;
}
#pragma mark 不再使用系统的缓存，而是换到自定义缓存_传入自定义文件地址
-(void)changeToDownloadMode:(NSString *)downDir{
    self.aMode = DOWNLOAD_MODE;
    self.subDirectory = downDir;
}
#pragma mark 不再使用自定义缓存，而是换到系统的缓存
-(void) changeToNormalMode{
    self.aMode = NORMAL_MODE;
}
@end
