//
//  OrderEditingViewController.m
//  TestingStore
//
//  Created by 黄红迪 on 8/23/16.
//  Copyright © 2016 HHDemond. All rights reserved.
//

#import "OrderEditingViewController.h"
#import "OrderCatchManager.h"

typedef enum {
    kShippingMethod = 90,
    kCustomername = 91,
    kTableName = 92,
    kTableSize = 93
} TextType;

@interface OrderEditingViewController ()<UITextFieldDelegate>{

}
@property (weak, nonatomic) IBOutlet UITextField *shippingMethodTextField;
@property (weak, nonatomic) IBOutlet UITextField *customeNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *tableNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *tableSizeTextField;
@end

@implementation OrderEditingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addHideKeyboardTapGesture];
    [self fillTextField];
}

- (void)newEntity{
    if (!_orderEntity) {
        _orderEntity = [OrderEntity new];
        NSMutableArray *entities = [OrderCatchManager getCatchedEntitiesWithIdentifier:self.identifier];
        _orderEntity.identifier = [NSString stringWithFormat:@"%ld", entities.count];
    }
}

- (void)setOrderEntity:(OrderEntity *)orderEntity{
    if (orderEntity) {
        _orderEntity = orderEntity;
    }
}

- (void)fillTextField{
    
    self.shippingMethodTextField.text = _orderEntity.shippingMothod;
    self.customeNameTextField.text = _orderEntity.customerName;
    self.tableNameTextField.text = _orderEntity.tableName;
    self.tableSizeTextField.text = _orderEntity.tableSize;
}

- (void)addHideKeyboardTapGesture {
    UITapGestureRecognizer *tapGestrue = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTap:)];
    tapGestrue.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestrue];
}

- (void)viewTap:(UITapGestureRecognizer *)tapGestrue {
    [self.view endEditing:YES];
}

- (IBAction)saveClicked:(UIButton *)sender {
    [OrderCatchManager catchEntity:_orderEntity identifier:self.identifier];
    NSArray *result = [OrderCatchManager getCatchedEntitiesWithIdentifier:self.identifier];
    if (self.delegate) {
        [self.delegate completeEditing:result];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)fillOrderEntity:(UITextField *)textField{
    
    switch (textField.tag) {
        case kShippingMethod:
            _orderEntity.shippingMothod = textField.text;
            break;
        case kCustomername:
            _orderEntity.customerName = textField.text;
            break;
        case kTableName:
            _orderEntity.tableName = textField.text;
            break;
        case kTableSize:
            _orderEntity.tableSize = textField.text;
            break;
        default:
            break;
    }
    
}

#pragma mark-<UITextInputDelegate>

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    [self fillOrderEntity:textField];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    
    return YES;
}

@end
