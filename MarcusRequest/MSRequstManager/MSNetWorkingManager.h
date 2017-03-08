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
    MSAPIManagerErrorTypeNoContent,         //API请求成功但返回数据不正确，或数据超长。如果回调数据验证函数返回值为NO，manager的状态就会是这个。
    MSAPIManagerErrorTypeParamsError,       //参数错误，
    MSAPIManagerErrorTypeTimeout,           //请求超时。
    MSAPIManagerErrorTypeNoNetWork,         //网络不通。
    MSAPIManagerErrorTypeInvalidURL,        //请求失败， 无效的URL
    MSAPIManagerErrorTypeNoHost,            //服务器异常 （找不到服务器，服务器不支持等）
    MSAPIManagerErrorTypeCancelled,         //取消网络请求
    MSAPIManagerErrorTypeUnknown            //未知错误

};


typedef void(^MSCallback)(id responseObject, MSAPIManagerErrorType errorType);

@interface MSNetWorkingManager : NSObject

+ (instancetype)sharedManager;

- (NSURLSessionDataTask *)callApiWithUrl:(NSString *)url params:(NSDictionary *)params requestType:(MSAPIManagerRequestType)requestType success:(MSCallback)success fail:(MSCallback)fail;

- (void)cancelAllRequest;
@end
