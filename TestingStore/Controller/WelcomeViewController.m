//
//  ViewController.m
//  TestingStore
//
//  Created by 黄红迪 on 8/23/16.
//  Copyright © 2016 HHDemond. All rights reserved.
//

#import "WelcomeViewController.h"
#import "OrderTableViewController.h"
#import "Server.h"
@interface WelcomeViewController ()<ServerPublishDelegate>{
    Server *_server;
    NSString *_identifier;
}

@end

@implementation WelcomeViewController


- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)masterSelected:(UIButton *)sender {
    _identifier = @"Master";
    [self setupServer];
}

- (IBAction)slaveSelected:(UIButton *)sender {
    _identifier = @"Slave";
    [self setupServer];
}

- (void)setupServer{
    _server = [[Server alloc] init];
    _server.delegate = self;
    NSError *error = nil;
    [_server start:_identifier error:&error];//startWithName:_identifier error:&error];
    if (error) {
        NSLog(@"%@", error);
        return;
    }
}

#pragma mark - <ServerPublishDelegate>

- (void)serverDidpublished:(NSNetService *)service{
    [self performSegueWithIdentifier:@"toOrderList" sender:nil];
}

#pragma mark -<Segue Handle>

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    OrderTableViewController *orderVC = [segue destinationViewController];
    orderVC.identifier = _identifier;
    orderVC.server = _server;
}

@end
