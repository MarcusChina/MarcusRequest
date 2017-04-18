//
//  MSAPIBaseManager.m
//  MarcusOC
//
//  Created by marcus on 16/11/15.
//  Copyright © 2016年 marcus. All rights reserved.
//

#import "MSAPIBaseManager.h"
#import "MSNetWorkingManager.h"

//DEBUG 时，打印出相应请求数据

#ifdef DEBUG
#define MSRequestLog(__result_,__ViewControllerName_, __Url_, __Type_, __Params_, __ResponseData_) \
fprintf(stderr, "\n\n================ 数据请求%s(%s): ================\n",__result_.UTF8String,__ViewControllerName_.UTF8String); \
fprintf(stderr, "-- RequestUrl: %s\n", __Url_.UTF8String); \
fprintf(stderr, "-- Type: %s (0:Get 1:Post 2:Upload 3:Download)\n", __Type_.UTF8String); \
if (__Params_) {\
fprintf(stderr, "-- Params: %s\n", [NSString stringWithFormat:@"%@", __Params_].UTF8String); \
} \
if (__ResponseData_) {\
fprintf(stderr, "-- ResponseData: %s\n", [NSString stringWithFormat:@"%@", __ResponseData_].UTF8String); \
}\
fprintf(stderr, "===========================================================================\n\n\n");
#else
#define MSRequestLog(__ViewControllerName_,__Url_, __Type_, __Params_, __ResponseData_)
#endif

@interface MSAPIBaseManager()
@property (nonatomic, copy, readwrite) NSString *errorMessage;
@property (nonatomic, readwrite) MSAPIManagerErrorType errorType;

@property (nonatomic, strong) NSDictionary *params;
@property (nonatomic, strong) NSURLSessionTask *task;
@end

@implementation MSAPIBaseManager

#pragma mark - life cycle
- (instancetype)init {
    self = [super init];
    if (self) {
        self.delegate = nil;
        self.paramSource = nil;
        self.task = nil;
        self.params = nil;
        self.errorType = MSAPIManagerErrorTypeDefault;
        self.responseObject = nil;
    }
    return self;
}

- (void)loadData {
    if (self.paramSource) {
        if ([self.paramSource respondsToSelector:@selector(paramsForApi:)]) {
            self.params = [self.paramSource paramsForApi:self];
        }
    }
    
    NSLog(@"开始请求\n");
    
   __weak __typeof(self)weakSelf = self;
    self.task = [[MSNetWorkingManager sharedManager]callApiWithUrl:self.requestUrl params:self.params?:@{} requestType:self.requestType success:^(id responseObject, MSAPIManagerErrorType errorType) {
        NSString * requestType = [NSString stringWithFormat:@"%lu",(unsigned long)weakSelf.requestType];
        MSRequestLog(@"成功",NSStringFromClass([weakSelf class]), weakSelf.requestUrl, requestType, weakSelf.params, responseObject);
        if (weakSelf.delegate) {
            if (errorType == MSAPIManagerErrorTypeSuccess) {
                weakSelf.errorType = MSAPIManagerErrorTypeSuccess;
                if ([weakSelf.delegate respondsToSelector:@selector(managerCallAPIDidSuccess:)] ) {
                    weakSelf.responseObject = responseObject;
                    [weakSelf.delegate managerCallAPIDidSuccess:weakSelf];
                    weakSelf.task = nil;
                }
            }else {
                weakSelf.errorType = errorType;
                if ([weakSelf.delegate respondsToSelector:@selector(managerCallAPIDidFailed:)]) {
                    [weakSelf.delegate managerCallAPIDidFailed:weakSelf];
                    weakSelf.task = nil;
                }
            }
        }
    } fail:^(id responseObject, MSAPIManagerErrorType errorType) {
        NSString * errorMessage = @"";
        switch (errorType) {
            case MSAPIManagerErrorTypeNoNetWork:
                errorMessage = NSLocalizedString(@"APIManagerErrorTypeNoNetwork", nil);
                break;
                
            case MSAPIManagerErrorTypeDefault:
                errorMessage = NSLocalizedString(@"APIManagerErrorTypeDefault", nil);
                break;
                
            case MSAPIManagerErrorTypeTimeout:
                errorMessage = NSLocalizedString(@"APIManagerErrorTypeTimeout", nil);
                break;
             
            case MSAPIManagerErrorTypeParamsError:
                errorMessage = NSLocalizedString(@"APIManagerErrorTypeParamsError", nil);
                break;
                
            case MSAPIManagerErrorTypeInvalidURL:
                errorMessage = NSLocalizedString(@"APIManagerErrorTypeInvalidURL", nil);
                break;
                
            case MSAPIManagerErrorTypeNoHost:
                errorMessage = NSLocalizedString(@"APIManagerErrorTypeNoHost", nil);
                break;
                
            case MSAPIManagerErrorTypeCancelled:
                errorMessage = NSLocalizedString(@"APIManagerErrorTypeCancelled", nil);
                break;
                
            case MSAPIManagerErrorTypeUnknown:
                errorMessage = NSLocalizedString(@"APIManagerErrorTypeUnknown", nil);
                break;
                
            default:
                errorMessage = @"";
                break;
        }
        
        NSString * requestType = [NSString stringWithFormat:@"%lu",(unsigned long)weakSelf.requestType];
        NSString * error = [NSString stringWithFormat:@"失败-->原因:%@",errorMessage];
        MSRequestLog(error,NSStringFromClass([weakSelf class]), weakSelf.requestUrl, requestType, weakSelf.params, responseObject);
        
        weakSelf.errorType = errorType;
        weakSelf.errorMessage = errorMessage;

        if (weakSelf.delegate) {
            if ([weakSelf.delegate respondsToSelector:@selector(managerCallAPIDidFailed:)]) {
                [weakSelf.delegate managerCallAPIDidFailed:weakSelf];
                weakSelf.task = nil;
            }
        }
    }];
}

- (void)dealloc {
    [self cancelRequest];
}

- (void)cancelRequest {
    if (self.task) {
        NSLog(@"取消数据请求 %@ %@\n",self,self.task);
        [self.task cancel];
        self.task = nil;
    }
}


@end
