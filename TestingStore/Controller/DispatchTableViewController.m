//
//  DispatchTableViewController.m
//  TestingStore
//
//  Created by HongDi Huang on 8/24/16.
//  Copyright © 2016 HHDemond. All rights reserved.
//

#import "DispatchTableViewController.h"
#import "ClientServiceBrowser.h"
#import "Server.h"
#import "OrderEntity.h"
#define SERVICE_IDENTIFIER @"service_identifier_for_cell"
@interface DispatchTableViewController()<ClientServiceDelegate>{
    NSMutableArray *_serviceArray;
    NSIndexPath *_selectedIndexPath;
}
@property (nonatomic, strong) ClientServiceBrowser *serviceBrowser;

@end
@implementation DispatchTableViewController

- (void)viewDidLoad{
    _serviceArray = [NSMutableArray new];
    __weak typeof(self) weakSelf = self;
    __weak typeof(_selectedIndexPath) weakIndexPath = _selectedIndexPath;
    self.server.connectCompleteCallBack = ^{
        [weakSelf connectionComplete:weakIndexPath];
    };
    [self setupBrowser];
}

- (void)setupBrowser{
    NSString *serviceName = [self.identifier isEqualToString:@"Master"]?@"Slave":@"Master";
    _serviceBrowser = [ClientServiceBrowser startWithServiceName:serviceName];
    _serviceBrowser.delegate = self;
}

- (void)connectionComplete:(NSIndexPath *)indexPath{
    
    UIAlertController *alerController = [UIAlertController alertControllerWithTitle:@"Dispatch?" message:@"You wana dispatch" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"No"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             
    }];
    __weak typeof(self)weakSelf = self;
    self.orderEntity.isFromDispatch = @"YES";
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:weakSelf.orderEntity];
            NSError *error;
            [weakSelf.server sendData:data error:&error];
            if (error) {
                NSLog(@"%@", error);
            }

        });
    }];
    
    [alerController addAction:cancleAction];
    [alerController addAction:confirmAction];
    [self presentViewController:alerController animated:YES completion:^{}];
}

#pragma mark -<ClientServiceDelegate>
- (void)didFindService:(NSNetService *)service isMorecomming:(BOOL)moreComming{
    [_serviceArray addObject:service];
    if (!moreComming) {
        [self.tableView reloadData];
    }
}

#pragma mark -<UITableViewDataSource>

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

#pragma mark -<UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSNetService *service = _serviceArray[indexPath.row];
    
    [self.server connectToRemoteService:service];
    _selectedIndexPath = indexPath;
}

@end
