//
//  OrderEditingViewController.h
//  TestingStore
//
//  Created by 黄红迪 on 8/23/16.
//  Copyright © 2016 HHDemond. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderEntity.h"
@protocol OrderEditingDelegate <NSObject>

- (void)completeEditing:(NSArray *)orders;

@end

@interface OrderEditingViewController : UIViewController

@property (nonatomic, weak) id<OrderEditingDelegate>delegate;
@property (nonatomic, strong)OrderEntity *orderEntity;
@property (nonatomic, copy) NSString *identifier;
- (void)newEntity;

@end
