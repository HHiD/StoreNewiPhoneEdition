//
//  DispatchTableViewController.m
//  TestingStore
//
//  Created by HongDi Huang on 8/24/16.
//  Copyright © 2016 HHDemond. All rights reserved.
//

#import "DispatchTableViewController.h"
#import "ClientServiceBrowser.h"

#define SERVICE_IDENTIFIER @"service_identifier_for_cell"
@interface DispatchTableViewController()<ClientServiceDelegate>{
    NSMutableArray *_serviceArray;
}
@property (nonatomic, strong) ClientServiceBrowser *serviceBrowser;

@end
@implementation DispatchTableViewController

- (void)viewDidLoad{
    _serviceArray = [NSMutableArray new];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:SERVICE_IDENTIFIER];
    [self setupBrowser];
}

- (void)setupBrowser{
    NSString *serviceName = [self.identifier isEqualToString:@"Master"]?@"Slave":@"Master";
    _serviceBrowser = [ClientServiceBrowser startWithServiceName:serviceName];
    _serviceBrowser.delegate = self;
}

#pragma mark -<ClientServiceDelegate>
- (void)didFindService:(NSNetService *)service isMorecomming:(BOOL)moreComming{
    [_serviceArray addObject:service];
    if (!moreComming) {
        [self.tableView reloadData];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _serviceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SERVICE_IDENTIFIER forIndexPath:indexPath];
    
    NSNetService *service = _serviceArray[indexPath.row];
    cell.textLabel.text = service.name;
    cell.detailTextLabel.text = service.type;
    return cell;
}

@end
