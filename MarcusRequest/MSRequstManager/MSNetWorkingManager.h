//
//  MSNetWorkingManager.h
//  MarcusOC
//
//  Created by marcus on 16/11/15.
//  Copyright © 2016年 marcus. All rights reserved.
//

#import <Foundation/Foundation.h>

//网络请求类型
typedef NS_ENUM(NSUInteger, MSAPIManagerRequestType) {
    MSAPIManagerRequestTypeGet = 0,                  //Get 请求
    MSAPIManagerRequestTypePost,                     //Post 请求
    MSAPIManagerRequestTypeUpload,                   //上传
    MSAPIManagerRequestTypeDownload                  //下载
};

//网络请求错误类型
typedef NS_ENUM (NSUInteger, MSAPIManagerErrorType){
    MSAPIManagerErrorTypeDefault = 0,       //没有产生过API请求，这个是manager的默认状态。
    MSAPIManagerErrorTypeSuccess,           //API请求成功且返回数据正确，此时manager的数据是可以直接拿来使用的。
    MSAPIManagerErrorTypeNoContent,         //API请求成功但返回数据不正确。如果回调数据验证函数返回值为NO，manager的状态就会是这个。
    MSAPIManagerErrorTypeParamsError,       //参数错误，此时manager不会调用API，因为参数验证是在调用API之前做的。
    MSAPIManagerErrorTypeTimeout,           //请求超时。ERApiProxy设置的是20秒超时，具体超时时间的设置请自己去看ERApiProxy的相关代码。
    MSAPIManagerErrorTypeNoNetWork,         //网络不通。在调用API之前会判断一下当前网络是否通畅，这个也是在调用API之前验证的，和上面超时的状态是有区别的。
    MSAPIManagerErrorTypeInvalidURL        // 请求失败， 无效的URL
};


typedef void(^MSCallback)(id responseObject, MSAPIManagerErrorType errorType);

@interface MSNetWorkingManager : NSObject

+ (instancetype)sharedManager;

- (NSURLSessionDataTask *)callApiWithUrl:(NSString *)url params:(NSDictionary *)params requestType:(MSAPIManagerRequestType)requestType success:(MSCallback)success fail:(MSCallback)fail;

@end
