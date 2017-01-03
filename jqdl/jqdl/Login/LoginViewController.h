//
//  LoginViewController.h
//  qlx
//
//  Created by Stephen Chin on 16/3/16.
//  Copyright © 2016年 Stephen Chin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController


@property (strong, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UITextField *account;
@property (weak, nonatomic) IBOutlet UITextField *password;

@property (weak, nonatomic) IBOutlet UILabel *forgetPassword;
@property (weak, nonatomic) IBOutlet UILabel *toRegister;
@property (weak, nonatomic) IBOutlet UILabel *msgLogin;

@end
