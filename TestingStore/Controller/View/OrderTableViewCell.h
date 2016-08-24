//
//  OrderTableViewCell.h
//  TestingStore
//
//  Created by HongDi Huang on 8/24/16.
//  Copyright © 2016 HHDemond. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *tableName;
@property (weak, nonatomic) IBOutlet UILabel *tableSize;
@property (weak, nonatomic) IBOutlet UILabel *customeName;
@property (weak, nonatomic) IBOutlet UILabel *shippingMethod;

@end
