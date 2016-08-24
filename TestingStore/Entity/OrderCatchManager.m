//
//  OrderDataManager.m
//  TestingStore
//
//  Created by HongDi Huang on 8/24/16.
//  Copyright © 2016 HHDemond. All rights reserved.
//

#import "OrderCatchManager.h"
#import "OrderEntity.h"
#define CATCH_KEY @"order_catch_key"
@implementation OrderCatchManager


+ (NSMutableArray *)getCatchedEntitiesWithIdentifier:(NSString *)identifier{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    
    NSArray *catchedArray = [NSArray arrayWithArray:[defaults objectForKey:[NSString stringWithFormat:@"%@%@",identifier ,CATCH_KEY]]];
    NSMutableArray *resultArray = [NSMutableArray array];
    
    for (NSData *data in catchedArray) {
        OrderEntity *orderEntity = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [resultArray addObject:orderEntity];
    }
    return resultArray;
}

+ (void)catchEntity:(OrderEntity *)entity identifier:(NSString *)identifier{
    
    NSMutableArray *catchedEntities = [OrderCatchManager getCatchedEntitiesWithIdentifier:identifier];
    
    NSMutableArray *tempEntities = [OrderCatchManager getCatchedEntitiesWithIdentifier:identifier];
    BOOL isRepleace = NO;
    NSInteger index = 0;
    //search if the entity aleady exist
    for (NSInteger i = 0; i < tempEntities.count; i++) {
        OrderEntity *savedEntity = tempEntities[i];
        if ([savedEntity.identifier isEqualToString:entity.identifier]) {
            isRepleace = YES;
            index = i;
        }
    }
    if (isRepleace) {
        [catchedEntities replaceObjectAtIndex:index withObject:entity];
    }else{
        [catchedEntities addObject:entity];
    }
    [self archiveAndCatchEntities:catchedEntities identifier:identifier];
}

+ (void)archiveAndCatchEntities:(NSArray *)entities identifier:(NSString *)identifier{
    NSMutableArray *copyEntities = [NSMutableArray array];;
    
    for (OrderEntity *entity in entities) {
        [copyEntities addObject:[NSKeyedArchiver archivedDataWithRootObject:entity]];
    }
    NSArray *encodeEntities = [NSArray arrayWithArray:copyEntities];
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:encodeEntities forKey:[NSString stringWithFormat:@"%@%@",identifier ,CATCH_KEY]];
    [defaults synchronize];
}

+ (void)removeAllEntityWithIdentifier:(NSString *)identifier{
    NSMutableArray *savedEntities = [self getCatchedEntitiesWithIdentifier:identifier];
    [savedEntities removeAllObjects];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:savedEntities forKey:[NSString stringWithFormat:@"%@%@",identifier ,CATCH_KEY]];
    [defaults synchronize];
}

+ (void)removeEntity:(OrderEntity *)entity identifier:(NSString *)identifier{
    NSMutableArray *entities = [self getCatchedEntitiesWithIdentifier:identifier];
    NSArray *copyEntities = [NSArray arrayWithArray:entities];
    [entities removeObject:entity];
    NSInteger index = 0;
    BOOL isNeedRemove = NO;
    for (NSInteger i = 0; i < copyEntities.count; i ++) {
        OrderEntity *copyEntity = copyEntities[i];
        if ([copyEntity.identifier isEqualToString:entity.identifier]) {
            index = i;
            isNeedRemove = YES;
        }
    }
    if (isNeedRemove) {
        [entities removeObjectAtIndex:index];
    }
    
    [self archiveAndCatchEntities:entities identifier:identifier];
}

@end
