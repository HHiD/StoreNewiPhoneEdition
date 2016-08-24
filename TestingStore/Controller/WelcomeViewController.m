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
@interface WelcomeViewController (){
    Server *_server;
}

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSString *identifier = segue.identifier;
    OrderTableViewController *orderVC = [segue destinationViewController];
    orderVC.identifier = identifier;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    _server = [[Server alloc] init];
    NSError *error = nil;
    [_server startWithName:identifier error:&error];
    if (error) {
        NSLog(@"%@", error);
        return NO;
    }
    return YES;
}

@end
