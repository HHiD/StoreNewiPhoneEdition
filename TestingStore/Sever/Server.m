//
//  TestServer.m
//  TestingStoreiPhoneEdition
//
//  Created by HongDi Huang on 8/23/16.
//  Copyright © 2016 HongDi Huang. All rights reserved.
//

#import "Server.h"
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>
#include <CFNetwork/CFSocketStream.h>

@interface Server()<NSNetServiceDelegate, NSStreamDelegate>{
    uint16_t _port;
    NSNetService *_service;
}
@end

@implementation Server

- (void)startWithName:(NSString *)name error:(NSError **)error{
    
    int fd4 = socket(AF_INET, SOCK_STREAM, 0);
    struct sockaddr_in sin;
    memset(&sin, 0, sizeof(sin));
    sin.sin_family = AF_INET;
    sin.sin_len = sizeof(sin);
    sin.sin_port = 0;
    
    _port = ntohs(sin.sin_port);
    
    int err = bind(fd4, (const struct sockaddr *) &sin, sin.sin_len);
    socklen_t addrLen = sizeof(sin);
    err = getsockname(fd4, (struct sockaddr *) &sin, &addrLen);
    err = listen(fd4, 5);
    
    
    int fd6 = socket(AF_INET6, SOCK_STREAM, 0);
    int one = 1;
    err = setsockopt(fd6, IPPROTO_IPV6, IPV6_V6ONLY, &one, sizeof(one));
    struct sockaddr_in6 sin6;
    memset(&sin6, 0, sizeof(sin6));
    sin6.sin6_family = AF_INET6;
    sin6.sin6_len = sizeof(sin6);
    sin6.sin6_port = sin.sin_port;
    
    err = bind(fd6, (const struct sockaddr *) &sin6, sin6.sin6_len);
    err = listen(fd6, 5);
    
    
    CFSocketContext    context = { 0, NULL, NULL, NULL, NULL };
    CFSocketRef        sock4, sock6;
    CFRunLoopSourceRef rls4, rls6;
    sock4 = CFSocketCreateWithNative(NULL, fd4,
                                    kCFSocketAcceptCallBack,
                                    ListeningSocketCallback,
                                    &context);
    sock6 = CFSocketCreateWithNative(NULL, fd6,
                                    kCFSocketAcceptCallBack,
                                    ListeningSocketCallback,
                                    &context);

    if (sock4 == NULL || sock6 == NULL) {
        *error = [[NSError alloc] initWithDomain:@"SeverErrorDoamin"
                                            code:kServerNoSocketsAvailable
                                        userInfo:nil];
        return;
    }else{
        rls4 = CFSocketCreateRunLoopSource(NULL, sock4, 0);
        rls6 = CFSocketCreateRunLoopSource(NULL, sock6, 0);
        
        CFRunLoopAddSource(CFRunLoopGetCurrent(), rls4, kCFRunLoopCommonModes);
        CFRelease(rls4);
        CFRelease(sock4);
        
        CFRunLoopAddSource(CFRunLoopGetCurrent(), rls6, kCFRunLoopCommonModes);
        CFRelease(rls6);
        CFRelease(sock6);
        
        [self publishService:name];
    }
    
}


void ListeningSocketCallback(CFSocketRef sock,
                             CFSocketCallBackType type,
                             CFDataRef address,
                             const void *data,
                             void *info){
    int fd = * (const int *) data;
    CFReadStreamRef   readStream;
    CFWriteStreamRef  writeStream;
    NSInputStream  *  inputStream;
    NSOutputStream *  outputStream;
    CFStreamCreatePairWithSocket(NULL, fd, &readStream,
                                 &writeStream);
    inputStream  = (__bridge NSInputStream *)(readStream);
    outputStream = (__bridge NSOutputStream *)(writeStream);
    [inputStream setProperty:(id)kCFBooleanTrue
                      forKey:(NSString *)kCFStreamPropertyShouldCloseNativeSocket];
}


#pragma mark -<Server side>
- (void)publishService:(NSString *)name{
    _service = [[NSNetService alloc] initWithDomain:@""//pick all domain it works
                                               type:[NSString stringWithFormat:@"_%@._tcp.", name]
                                               name:[NSString stringWithFormat:@"%@ Device", name]
                                               port:_port];
    if (_service) {
        _service.includesPeerToPeer = YES;
        [_service scheduleInRunLoop:[NSRunLoop currentRunLoop]
                           forMode:NSRunLoopCommonModes];
        [_service setDelegate:self];
        [_service publish];
    }
}

#pragma -<NSNetServiceDelegate>
- (void)netServiceDidPublish:(NSNetService *)sender {
    NSString *name = [sender name];
    NSLog(@"My name is: %@", name);
}

- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict {
    NSLog(@"Error publishing: %@", errorDict);
}

#pragma mark -<WhenUserChooseService>

- (void)whenUserChooseOneService:(NSNetService *)service{
    
    NSInputStream  * inStream;
    NSOutputStream * outStream;
    [service getInputStream:&inStream
               outputStream:&outStream];
    inStream.delegate = self;
    outStream.delegate = self;
    [inStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                        forMode:NSDefaultRunLoopMode];
    [outStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                         forMode:NSDefaultRunLoopMode];
    [inStream open];
    [outStream open];
}

@end
