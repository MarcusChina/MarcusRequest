//
//  MSAPIBaseManager.m
//  MarcusOC
//
//  Created by marcus on 16/11/15.
//  Copyright © 2016年 marcus. All rights reserved.
//

#import "MSAPIBaseManager.h"
#import "MSNetWorkingManager.h"

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
        NSLog(@"请求成功：%@ %@\n",weakSelf,weakSelf.task);
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
        weakSelf.errorType = errorType;
        switch (weakSelf.errorType) {
            case MSAPIManagerErrorTypeNoNetWork:
                weakSelf.errorMessage = NSLocalizedString(@"APIManagerErrorTypeNoNetwork", nil);
                break;
                
            case MSAPIManagerErrorTypeDefault:
                weakSelf.errorMessage = NSLocalizedString(@"APIManagerErrorTypeDefault", nil);
                break;
                
            case MSAPIManagerErrorTypeTimeout:
                weakSelf.errorMessage = NSLocalizedString(@"APIManagerErrorTypeTimeout", nil);
                break;
             
            case MSAPIManagerErrorTypeParamsError:
                weakSelf.errorMessage = NSLocalizedString(@"APIManagerErrorTypeParamsError", nil);
                break;
                
            case MSAPIManagerErrorTypeInvalidURL:
                weakSelf.errorMessage = NSLocalizedString(@"APIManagerErrorTypeInvalidURL", nil);
                break;
                
            case MSAPIManagerErrorTypeNoHost:
                weakSelf.errorMessage = NSLocalizedString(@"APIManagerErrorTypeNoHost", nil);
                break;
                
            case MSAPIManagerErrorTypeCancelled:
                weakSelf.errorMessage = NSLocalizedString(@"APIManagerErrorTypeCancelled", nil);
                break;
                
            case MSAPIManagerErrorTypeUnknown:
                weakSelf.errorMessage = NSLocalizedString(@"APIManagerErrorTypeUnknown", nil);
                break;
                
            default:
                weakSelf.errorMessage = @"";
                break;
        }
        NSLog(@"请求失败：%@ %@ errorMessage:%@ \n",weakSelf,weakSelf.task,weakSelf.errorMessage);

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
