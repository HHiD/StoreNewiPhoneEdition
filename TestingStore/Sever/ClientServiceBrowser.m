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
    NSNetServiceBrowser *_browser;
}

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
    _browser = [[NSNetServiceBrowser alloc] init];
    [_browser setDelegate:self];
    [_browser searchForServicesOfType:[NSString stringWithFormat:@"_%@._tcp.", _servicename]
                            inDomain:@""];
}

#pragma mark-<NSNetServiceBrowserDelegate>

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser
           didFindService:(NSNetService *)service
               moreComing:(BOOL)moreComing {
    NSLog(@"HAHA");
    //    [self.model addObject:service];
    //    if (!moreComing) [self.tableView reloadData];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser
         didRemoveService:(NSNetService *)service
               moreComing:(BOOL)moreComing {
    NSLog(@"HAHA");
    //    [self.model removeObject:service];
    //    if (!moreComing) [self.tableView reloadData];
}

- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)browser{
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
