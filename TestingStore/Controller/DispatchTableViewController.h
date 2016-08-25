//
//  DispatchTableViewController.h
//  TestingStore
//
//  Created by HongDi Huang on 8/24/16.
//  Copyright © 2016 HHDemond. All rights reserved.
//

#import <UIKit/UIKit.h>
@class OrderEntity;
@interface DispatchTableViewController : UITableViewController

@property (nonatomic, copy)NSString *identifier;
@property (nonatomic, strong)OrderEntity *orderEntity;
@end
