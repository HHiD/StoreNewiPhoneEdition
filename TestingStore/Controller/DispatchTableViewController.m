//
//  DispatchTableViewController.m
//  TestingStore
//
//  Created by HongDi Huang on 8/24/16.
//  Copyright © 2016 HHDemond. All rights reserved.
//

#import "DispatchTableViewController.h"
#import "ClientServiceBrowser.h"
@interface DispatchTableViewController(){
    ClientServiceBrowser *_serviceBrowser;
}
@end
@implementation DispatchTableViewController

- (void)viewDidLoad{
    NSString *serviceName = [self.identifier isEqualToString:@"Master"]?@"Slave":@"Master";
    _serviceBrowser = [ClientServiceBrowser startWithServiceName:serviceName];
    
}

@end
