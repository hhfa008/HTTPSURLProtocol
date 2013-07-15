//
//  XHTTPSURLProtocol.h
//  XHTTPSURLProtocol
//
//  Created by hhfa008 on 13-6-27.
//  Copyright (c) 2013年 hhfa008 Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
	该类用于处理https类型的ajax请求
 */
@interface HTTPSURLProtocol : NSURLProtocol
{
    NSMutableData* _data;
}

@end
