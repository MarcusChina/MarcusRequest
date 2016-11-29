//
//  MSDuoMiManager.m
//  MarcusRequest
//
//  Created by marcus on 2016/11/24.
//  Copyright © 2016年 marcus. All rights reserved.
//  搜索演员的歌曲列表

#import "MSDuoMiManager.h"

@implementation MSDuoMiManager

#pragma mark - life cycle
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.requestType = MSAPIManagerRequestTypeGet;
        self.requestUrl = @"http://v5.pc.duomi.com/search-ajaxsearch-searchall";
    }
    
    return self;
}

@end
