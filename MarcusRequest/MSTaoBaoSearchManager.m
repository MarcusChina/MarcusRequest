//
//  MSTaoBaoSearchManager.m
//  MarcusRequest
//
//  Created by marcus on 2016/11/24.
//  Copyright © 2016年 marcus. All rights reserved.
//

#import "MSTaoBaoSearchManager.h"

@implementation MSTaoBaoSearchManager

#pragma mark - life cycle
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.requestType = MSAPIManagerRequestTypeGet;
        self.requestUrl = @"http://suggest.taobao.com/sug?code=utf-8";
    }
    
    return self;
}


@end
