//
//  ClientBrowserService.h
//  TestingStore
//
//  Created by 黄红迪 on 8/23/16.
//  Copyright © 2016 HHDemond. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ClientServiceDelegate <NSObject>

- (void)didFindService:(NSNetService *)service isMorecomming:(BOOL)moreComming;

@end

@interface ClientServiceBrowser : NSObject

@property (nonatomic, weak) id<ClientServiceDelegate>delegate;

+ (instancetype)startWithServiceName:(NSString *)name;

@end
