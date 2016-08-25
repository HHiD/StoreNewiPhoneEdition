//
//  ClientBrowserService.m
//  TestingStore
//
//  Created by 黄红迪 on 8/23/16.
//  Copyright © 2016 HHDemond. All rights reserved.
//

#import "ClientServiceBrowser.h"

@interface ClientServiceBrowser()<NSNetServiceBrowserDelegate>{
    NSString *_servicename;
}
@property (nonatomic, strong)NSNetServiceBrowser *browser;

@end

@implementation ClientServiceBrowser

- (instancetype)initWithServiceName:(NSString *)serviceName
{
    self = [super init];
    if (self) {
        _servicename = serviceName;
        [self clientBrowser];
    }
    return self;
}

+ (instancetype)startWithServiceName:(NSString *)name{
    return [[ClientServiceBrowser alloc] initWithServiceName:name];
}

#pragma mark -<ClientSide>
- (void)clientBrowser{
    [self.browser stop];
    
    NSString *serviceName = [NSString stringWithFormat:@"_%@HHD._tcp.", _servicename];
    NSLog(@"Search ServiceName: %@", serviceName);
    self.browser = [NSNetServiceBrowser new];
    if (self.browser) {
        [self.browser scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                forMode:NSDefaultRunLoopMode];
        self.browser.includesPeerToPeer = YES;
        [self.browser setDelegate:self];
        [self.browser searchForServicesOfType:serviceName
                                 inDomain:@""];
        
    }
}

#pragma mark-<NSNetServiceBrowserDelegate>

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser
           didFindService:(NSNetService *)service
               moreComing:(BOOL)moreComing {
    NSLog(@"HAHA");
    if (self.delegate) {
        [self.delegate didFindService:service isMorecomming:moreComing];
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser
         didRemoveService:(NSNetService *)service
               moreComing:(BOOL)moreComing {
    NSLog(@"HAHA");
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindDomain:(NSString *)domainString moreComing:(BOOL)moreComing{
    NSLog(@"HAHA");
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)browser{
    NSLog(@"HAHA");
}

// Application resumed from background
// and Bonjour browsing operation was cancelled
// so we restart it now.
- (void)netServiceBrowser:
(NSNetServiceBrowser *)netServiceBrowser
             didNotSearch:(NSDictionary *)errorInfo {
    NSLog(@"HAHA");
    //    [self restartBrowseAndUpdateUI];
}



@end
