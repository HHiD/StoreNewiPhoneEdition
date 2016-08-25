//
//  TestServer.h
//  TestingStoreiPhoneEdition
//
//  Created by HongDi Huang on 8/23/16.
//  Copyright © 2016 HongDi Huang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kServerCouldNotBindToIPv4Address = 1,
    kServerCouldNotBindToIPv6Address = 2,
    kServerNoSocketsAvailable = 3,
    kServerNoSpaceOnOutputStream = 4,
    kServerOutputStreamReachedCapacity = 5 // should be able to try again 'later'
} ServerErrorCode;

typedef void(^serverRemoteConnectionComplete)();
typedef void(^didRecieveData)(NSData *data);
@protocol ServerPublishDelegate <NSObject>

- (void)serverDidpublished:(NSNetService *)service;

@end

@interface Server : NSObject

@property (nonatomic, weak)id<ServerPublishDelegate> delegate;
@property (nonatomic, copy)serverRemoteConnectionComplete connectCompleteCallBack;
@property (nonatomic, copy)didRecieveData didRecieveDataCallback;

- (BOOL)start:(NSString *)name error:(NSError **)error;
- (void)connectToRemoteService:(NSNetService *)selectedService;
- (BOOL)sendData:(NSData *)data error:(NSError **)error;

@end
