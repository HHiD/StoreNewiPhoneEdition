//
//  OrderTableViewController.m
//  TestingStore
//
//  Created by 黄红迪 on 8/23/16.
//  Copyright © 2016 HHDemond. All rights reserved.
//

#import "OrderTableViewController.h"
#import "OrderEditingViewController.h"
#import "OrderCatchManager.h"
#import "OrderTableViewCell.h"
#import "DispatchTableViewController.h"
#import "Server.h"
#define CELL_IDENTIFIER @"store_identifier"
@interface OrderTableViewController ()<OrderEditingDelegate>{
    OrderEditingViewController *_editingViewController;
    DispatchTableViewController*_dispatchViewController;
    NSMutableArray *_orderArray;
    OrderEntity *_selectedEntity;
}
@end

@implementation OrderTableViewController

- (void)viewDidLoad {
    _selectedEntity = nil;
    [super viewDidLoad];
    [self setupServer];
    [self setupDataComponent];
    [self setupNavigationStaff];
}
- (void)setupServer{
    __weak typeof(self) weakSelf = self;
    self.server.didRecieveDataCallback = ^(NSData *data){
        [weakSelf handleRecievedData:data];
    };
}
- (void)setupDataComponent{
    _orderArray = [OrderCatchManager getCatchedEntitiesWithIdentifier:self.identifier];
}

- (void)setupNavigationStaff{
    UIButton *addingButton = [UIButton buttonWithType:UIButtonTypeSystem];
    addingButton.bounds = CGRectMake(0, 0, 80, 30);
    [addingButton setTitle:@"AddOrder" forState:UIControlStateNormal];
    [addingButton addTarget:self action:@selector(addOrder:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:addingButton];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)handleRecievedData:(NSData *)data{
    
    OrderEntity *orderEntity = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [_orderArray addObject:orderEntity];
    [OrderCatchManager catchEntity:orderEntity identifier:self.identifier];
    [self.tableView reloadData];
}


- (void)addOrder:(UIButton *)button{
    [self performSegueWithIdentifier:@"showEditing" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    //Going to new/edit order page
    if ([segue.identifier isEqualToString:@"showEditing"]) {
        _editingViewController = (OrderEditingViewController *)segue.destinationViewController;
        _editingViewController.delegate = self;
        _editingViewController.identifier = self.identifier;
        //To distinguish if this is new order
        if (sender) {
            _editingViewController.orderEntity = (OrderEntity *)sender;
        }else{
            [_editingViewController newEntity];
        }
    }
    //Going to order dispatching page
    else{
        _dispatchViewController = (DispatchTableViewController *)segue.destinationViewController;
        _dispatchViewController.identifier = self.identifier;
        _dispatchViewController.server = self.server;
        _dispatchViewController.orderEntity = _selectedEntity;
    }
}

- (void)deleteOrder:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
    OrderEntity *entity = _orderArray[indexPath.row];
    [OrderCatchManager removeEntity:entity identifier:self.identifier];
    [_orderArray removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)dispatchOrder:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
    _selectedEntity = _orderArray[indexPath.row];
    [self performSegueWithIdentifier:@"goDispatch" sender:nil];
}

#pragma mark - <OrderEditingDelegate>

- (void)completeEditing:(NSArray *)orders{
    _orderArray = [NSMutableArray arrayWithArray:orders];
    [self.tableView reloadData];
}

#pragma mark - <Tableview datasource>

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return _orderArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    
    OrderEntity *entity = _orderArray[indexPath.row];
    cell.tableName.text = [NSString stringWithFormat:@"TableName: %@", entity.tableName];
    cell.tableSize.text = [NSString stringWithFormat:@"TableSize: %@", entity.tableSize];
    cell.customeName.text = [NSString stringWithFormat:@"CustomeName: %@", entity.customerName];
    cell.shippingMethod.text = [NSString stringWithFormat:@"ShippingMethod: %@", entity.shippingMothod];
    if ([entity.isFromDispatch isEqualToString:@"YES"]) {
        cell.backgroundColor = [UIColor redColor];
    }
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    __weak typeof(self)weakSelf = self;
    
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                                                      title:@" Delete "
                                                                    handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        [weakSelf deleteOrder:indexPath tableView:tableView];
    }];
    delete.backgroundColor = [UIColor redColor];
    
    UITableViewRowAction *dispatchSelection = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@" Dispatch " handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
    {
        [weakSelf dispatchOrder:indexPath tableView:tableView];
    }];
    dispatchSelection.backgroundColor = [UIColor colorWithRed:0.188 green:0.514 blue:0.984 alpha:1];
   
    return @[delete, dispatchSelection];
}

#pragma mark -<UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    OrderEntity *orderEntity = _orderArray[indexPath.row];
    [self performSegueWithIdentifier:@"showEditing" sender:orderEntity];
}

@end
