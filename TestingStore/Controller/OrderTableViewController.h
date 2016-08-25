//
//  OrderTableViewController.h
//  TestingStore
//
//  Created by 黄红迪 on 8/23/16.
//  Copyright © 2016 HHDemond. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Server;
@interface OrderTableViewController : UITableViewController

@property (nonatomic, copy)NSString *identifier;
@property (nonatomic, strong)Server *server;

@end
