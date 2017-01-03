//
//  ForgetPwdViewController.h
//  qlxing
//
//  Created by Stephen Chin on 16/6/23.
//  Copyright © 2016年 Stephen Chin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgetPwdViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *regBtn;
//@property (strong, nonatomic) IBOutlet UIButton *codeBtn;
@property (weak, nonatomic) IBOutlet UITextField *account;
@property (weak, nonatomic) IBOutlet UITextField *code;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *password2;

@end
