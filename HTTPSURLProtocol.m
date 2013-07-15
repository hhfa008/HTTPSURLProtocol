//
//  HTTPSURLProtocol.m
//  HTTPSURLProtocol
//
//  Created by hhfa008 on 13-6-27.
//  Copyright (c) 2013年 hhfa008 Inc. All rights reserved.
//

#import "HTTPSURLProtocol.h"

static BOOL gExchangeCredentialFinished = YES;             /**< 用于标记是否完成证书交换 */

@implementation HTTPSURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)theRequest
{
    //FIXME: 后来的https类型的reqeust应该也要被处理
    return ([[[theRequest URL] scheme] isEqualToString:@"https"] && gExchangeCredentialFinished);
}

+ (NSURLRequest*)canonicalRequestForRequest:(NSURLRequest*)request
{
    return request;
}

- (void)startLoading
{
    gExchangeCredentialFinished = NO;
    NSURLConnection *theConncetion = [[NSURLConnection alloc] initWithRequest:self.request delegate:self];
    if (theConncetion) {
        _data = [NSMutableData data];
    }
}

- (void)stopLoading
{
    // NOTE:如有清理工作，可以在此处添加
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest*)requestA toRequest:(NSURLRequest*)requestB
{
    return NO;
}

#pragma mark - NSURLConnectionDelegate

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    //响应服务器证书认证请求和客户端证书认证请求
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust] ||
    [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodClientCertificate];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    NSURLCredential* credential;
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        //服务器证书认证
        credential= [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
    }
    else if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodClientCertificate])
    {
        //客户端证书认证
        //TODO:设置客户端证书认证
        credential = nil;
    }

    if (credential != nil)
    {
        [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
    }
    else
    {
        [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [[self client] URLProtocol:self didLoadData:_data];
    [[self client] URLProtocolDidFinishLoading:self];
    gExchangeCredentialFinished = YES;
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [[self client] URLProtocol:self didFailWithError:error];
    gExchangeCredentialFinished = YES;
}

@end
