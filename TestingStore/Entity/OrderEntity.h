//
//  orderEntity.h
//  TestingStore
//
//  Created by 黄红迪 on 8/23/16.
//  Copyright © 2016 HHDemond. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderEntity : NSObject<NSCoding>

@property (nonatomic, copy)NSString *shippingMothod;
@property (nonatomic, copy)NSString *customerName;
@property (nonatomic, copy)NSString *tableName;
@property (nonatomic, copy)NSString *tableSize;
@property (nonatomic, copy)NSString *identifier;
@property (nonatomic, copy)NSString *isFromDispatch;
@end
