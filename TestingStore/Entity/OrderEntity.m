//
//  orderEntity.m
//  TestingStore
//
//  Created by 黄红迪 on 8/23/16.
//  Copyright © 2016 HHDemond. All rights reserved.
//

#import "OrderEntity.h"
#define PRE_NAME @"order"
@implementation OrderEntity

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.identifier forKey:[NSString stringWithFormat:@"%@%@", PRE_NAME, @"identifier"]];
    [aCoder encodeObject:self.shippingMothod forKey:[NSString stringWithFormat:@"%@%@", PRE_NAME, @"shippingMethod"]];
    [aCoder encodeObject:self.customerName forKey:[NSString stringWithFormat:@"%@%@", PRE_NAME, @"customeName"]];
    [aCoder encodeObject:self.tableSize forKey:[NSString stringWithFormat:@"%@%@", PRE_NAME, @"tableSize"]];
    [aCoder encodeObject:self.tableName forKey:[NSString stringWithFormat:@"%@%@", PRE_NAME, @"tableName"]];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.identifier = [coder decodeObjectForKey:[NSString stringWithFormat:@"%@%@", PRE_NAME, @"identifier"]];
        self.shippingMothod = [coder decodeObjectForKey:[NSString stringWithFormat:@"%@%@", PRE_NAME, @"shippingMethod"]];
        self.customerName = [coder decodeObjectForKey:[NSString stringWithFormat:@"%@%@", PRE_NAME, @"customeName"]];
        self.tableSize = [coder decodeObjectForKey:[NSString stringWithFormat:@"%@%@", PRE_NAME, @"tableSize"]];
        self.tableName = [coder decodeObjectForKey:[NSString stringWithFormat:@"%@%@", PRE_NAME, @"tableName"]];
    }
    return self;
}

@end
