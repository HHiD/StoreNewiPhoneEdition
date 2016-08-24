//
//  OrderDataManager.h
//  TestingStore
//
//  Created by HongDi Huang on 8/24/16.
//  Copyright © 2016 HHDemond. All rights reserved.
//

#import <Foundation/Foundation.h>
@class OrderEntity;
@interface OrderCatchManager : NSObject
/**
 *  Getting the catched entities
 *
 *  @param identifier To distinguish who you are
 *
 *  @return The catched value
 */
+ (NSMutableArray *)getCatchedEntitiesWithIdentifier:(NSString *)identifier;
/**
 *  To save the entity you have just fill
 *
 */
+ (void)catchEntity:(OrderEntity *)entity identifier:(NSString *)identifier;
/**
 *  To remove all entities
 *
 */
+ (void)removeAllEntityWithIdentifier:(NSString *)identifier;
/**
 *  To remove the specified entity
 *
 */
+ (void)removeEntity:(OrderEntity *)entity identifier:(NSString *)identifier;
@end
