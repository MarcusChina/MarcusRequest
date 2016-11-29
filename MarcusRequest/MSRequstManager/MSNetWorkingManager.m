//
//  MSNetWorkingManager.m
//  MarcusOC
//
//  Created by marcus on 16/11/15.
//  Copyright © 2016年 marcus. All rights reserved.
//

#import "MSNetWorkingManager.h"
#import "AFURLRequestSerialization.h"
#import "AFHTTPSessionManager.h"
#import "AFURLResponseSerialization.h"

@interface MSNetWorkingManager()
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;   //通用会话管理器
@end

@implementation MSNetWorkingManager

/**
 *  创建及获取单例对象的方法
 *
 *  @return 管理请求的单例对象
 */
+ (instancetype)sharedManager
{
    static MSNetWorkingManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MSNetWorkingManager alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    if (self = [super init])
    {
        [self initSessionManager];
    }
    return self;
}

- (void)initSessionManager
{
    //  *** 通用请求会话管理器 ***
    // 设置全局会话管理实例
    _sessionManager = [[AFHTTPSessionManager alloc] init];
    
    // 设置请求序列化器
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy; // 默认缓存策略
    requestSerializer.timeoutInterval = 10;
    _sessionManager.requestSerializer = requestSerializer;
    
    // 设置响应序列化器，解析Json对象
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];
    responseSerializer.removesKeysWithNullValues = YES; // 清除返回数据的 NSNull
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:  @"application/x-javascript", @"application/json", @"text/json", @"text/javascript", @"text/html", nil]; // 设置接受数据的格式
    _sessionManager.responseSerializer = responseSerializer;
    // 设置安全策略
    self.sessionManager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];;
}

- (NSURLSessionDataTask *)callApiWithUrl:(NSString *)url params:(NSDictionary *)params requestType:(MSAPIManagerRequestType)requestType success:(MSCallback)success fail:(MSCallback)fail {
    //  url 长度为0是， 返回错误
    if ( !url || url.length == 0)
    {
        if (fail) {
            fail(nil,MSAPIManagerErrorTypeInvalidURL);
        }
        return nil;
    }
    // 会话管理对象为空时
    if (!_sessionManager)
    {
        [self initSessionManager];
    }
    
    // 请求成功时的回调
    void (^successWrap)(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) = ^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject){
        if (!responseObject || (![responseObject isKindOfClass:[NSDictionary class]] && ![responseObject isKindOfClass:[NSArray class]])) // 若解析数据格式异常，返回错误
        {
            if (fail)
            {
                fail(nil,MSAPIManagerErrorTypeNoContent);
            }
        }
        else // 若解析数据正常，判断API返回的code，
        {
            if (success) {
                success(responseObject,MSAPIManagerErrorTypeSuccess);
            }
        }
    };
    
    // 请求失败时的回调
    void (^failureWrap)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) = ^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error){
        if (fail) {
            AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
            fail(nil,manager.isReachable ? MSAPIManagerErrorTypeNoNetWork : MSAPIManagerErrorTypeTimeout);
        }
    };
    
    // 设置请求头
    [self formatRequestHeader];
    
    //  分离URL中的参数信息, 重建参数列表
    params = [self formatParametersForURL:url withParams:params];
    url = [url componentsSeparatedByString:@"?"][0];
    __block NSURLSessionDataTask * urlSessionDataTask;
    
    if (requestType == MSAPIManagerRequestTypePost)  // Post 请求
    {
        // 检查url
        if (![NSURL URLWithString:url]) {
            url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        }
        
        urlSessionDataTask = [_sessionManager POST:url
                                        parameters:params
                                          progress:nil
                                           success:successWrap
                                           failure:failureWrap];
    }
    else if (requestType == MSAPIManagerRequestTypeGet) // Get 请求
    {
        // 检查url
        if (![NSURL URLWithString:url]) {
            url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        }
        
        urlSessionDataTask = [_sessionManager GET:url
                                       parameters:params
                                         progress:nil
                                          success:successWrap
                                          failure:failureWrap];
    }
    else if (requestType == MSAPIManagerRequestTypeUpload) // 上传
    {
        // 检查url
        if (![NSURL URLWithString:url]) {
            url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        }
        
        // POST请求时，分离参数中的字符串参数和文件数据
        NSMutableDictionary *values = [params mutableCopy]; // 保存 字符串参数
        NSMutableDictionary *files = [@{} mutableCopy]; // 保存 文件数据
        [params enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
            // 类型为 NSData 或者 UIImage 时，从参数列表中删除，添加至文件列表，并将UIImage对象转化为NSData类型
            if ([obj isKindOfClass:[NSData class]] || [obj isKindOfClass:[UIImage class]])
            {
                [values removeObjectForKey:key];
                [files setObject:[obj isKindOfClass:[UIImage class]]? UIImageJPEGRepresentation(obj, 0.5): obj forKey:key];
            }
        }];
        
        urlSessionDataTask = [_sessionManager POST:url
                                        parameters:values
                         constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                             // 将文件列表中的数据逐个添加到请求对象中
                             [files enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSData *obj, BOOL *stop) {
                                 NSString *fileName = [NSString stringWithFormat:@"%ld%c%c.jpg", (long)[[NSDate date] timeIntervalSince1970], arc4random_uniform(26) + 'a', arc4random_uniform(26) + 'a'];
                                 [formData appendPartWithFileData:obj name:@"file" fileName:fileName mimeType:@"image/jpeg"];
                             }];
                         }
                                          progress:nil
                                           success:successWrap
                                           failure:failureWrap];
    }
    else if (requestType == MSAPIManagerRequestTypeDownload) //下载
    {
        
    }
    return urlSessionDataTask;
}

//  分离URL中的参数信息, 重建参数列表
- (NSDictionary *)formatParametersForURL:(NSString *)url withParams:(NSDictionary *)params
{
    NSMutableDictionary *fixedParams = [params mutableCopy];
    //    分离URL中的参数信息
    NSArray *urlComponents = [[url stringByReplacingOccurrencesOfString:@" " withString:@""] componentsSeparatedByString:@"?"];
    NSArray *paramsComponets = urlComponents.count >= 2 && [urlComponents[1] length] > 0 ? [urlComponents[1] componentsSeparatedByString:@"&"] : nil;
    [paramsComponets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSArray *paramComponets = [obj componentsSeparatedByString:@"="];
        if (!fixedParams[paramsComponets[0]])
        {
            [fixedParams setObject:(paramComponets.count>=2 ? paramComponets[1] : @"") forKey:paramComponets[0]];
        }
    }];
    
    //    检查param的个数，为0时，置为nil
    fixedParams = fixedParams.allKeys.count ? fixedParams : nil;
    return [fixedParams copy];
}


#pragma mark 根据需要设置安全策略
- (AFSecurityPolicy *)creatCustomPolicy
{
    AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    policy.allowInvalidCertificates = YES;
    return policy;
}

#pragma mark 根据需要设置请求头信息
- (void)formatRequestHeader
{
    [_sessionManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
}

@end
