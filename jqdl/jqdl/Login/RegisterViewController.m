//
//  RegisterViewController.m
//  qlx
//
//  Created by Stephen Chin on 16/3/16.
//  Copyright © 2016年 Stephen Chin. All rights reserved.
//

#import "RegisterViewController.h"
#import "Util.h"
#import "NSObject+Blocks.h"
#import "UIViewController+JZExtension.h"

@interface RegisterViewController (){
    UIButton *getCodeBtn;
}

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"手机号快速注册";
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],NSForegroundColorAttributeName, nil];
    self.jz_navigationBarBackgroundAlpha = 1;
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    
    self.view.backgroundColor = RGB(250, 250, 250);

    
    [_account setValue:RGBA(204, 204, 204, 1) forKeyPath:@"_placeholderLabel.textColor"];
    [_password setValue:RGBA(204, 204, 204, 1) forKeyPath:@"_placeholderLabel.textColor"];
    [_code setValue:RGBA(204, 204, 204, 1) forKeyPath:@"_placeholderLabel.textColor"];
    [_nickname setValue:RGBA(204, 204, 204, 1) forKeyPath:@"_placeholderLabel.textColor"];
    
    [_regBtn setBackgroundImage:[[UIImage imageNamed:@"loginBtnDisabled"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 20, 5, 20) resizingMode:UIImageResizingModeStretch] forState:UIControlStateDisabled];
    [_regBtn setBackgroundImage:[[UIImage imageNamed:@"loginBtnHighLight"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 20, 5, 20) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
    [_regBtn addTarget:self action:@selector(reg) forControlEvents:UIControlEventTouchUpInside];

    getCodeBtn = [[UIButton alloc] initWithFrame:CGRectMake(5, 0, 100, 40)];
    [getCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [getCodeBtn setTitleColor:RGBA(67 ,216 ,230, 1) forState:UIControlStateNormal];
    [getCodeBtn setTitleColor:RGBA(204, 204, 204, 1) forState:UIControlStateHighlighted];
    [getCodeBtn setTitleColor:RGBA(204, 204, 204, 1) forState:UIControlStateDisabled];//计时
    getCodeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [getCodeBtn addTarget:self action:@selector(getCode) forControlEvents:UIControlEventTouchUpInside];
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 105, 40)];
    [rightView addSubview:getCodeBtn];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 1, 20)];
    label.backgroundColor = RGBA(204, 204, 204, 1);
    ViewBorderRadius(label, 1, 1, RGBA(204, 204, 204, 1));
    [rightView addSubview:label];
    self.account.rightViewMode = UITextFieldViewModeAlways;
    self.account.rightView = rightView;
    
    
    UIButton *showPwd = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [showPwd setImage:[UIImage imageNamed:@"showPwd"] forState:UIControlStateNormal];
    _password.rightViewMode = UITextFieldViewModeAlways;
    _password.rightView = showPwd;
    [showPwd addTarget:self action:@selector(showPwd) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"backWhite"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(dissMissView)];
    
    self.navigationItem.leftBarButtonItem = leftItem;
}

-(void)dissMissView{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)showPwd{
    _password.secureTextEntry = !_password.secureTextEntry;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
//    self.navigationController.navigationBar.translucent = YES;
//    [self.navigationController.navigationBar setShadowImage:[Util imageWithColor:[UIColor clearColor] size:CGSizeMake(320, 3)]];
//    [self.navigationController.navigationBar setBackgroundImage:[Util imageWithColor:RGBA(252, 228, 75,0.0)] forBarMetrics:UIBarMetricsDefault];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

//注册
-(void)reg{
    if ([_account.text isEqualToString:@""]) {
        [self showHintInView:self.view hint:@"请输入手机号码"];
        [_account becomeFirstResponder];
        return;
    }
    if (![Util isValidateMobile:_account.text]) {
        [self showHintInView:self.view hint:@"请输入正确的手机号码"];
        [_account becomeFirstResponder];
        return;
    }
    if ([_code.text isEqualToString:@""]) {
        [self showHintInView:self.view hint:@"请输入验证码"];
        [_code becomeFirstResponder];
        return;
    }
    if ([_nickname.text isEqualToString:@""]) {
        [self showHintInView:self.view hint:@"请输入用户名"];
        [_nickname becomeFirstResponder];
        return;
    }
    if ([Util isValidateMobile:_nickname.text]) {
        [self showHintInView:self.view hint:@"用户名不能为手机号码"];
        [_nickname becomeFirstResponder];
        return;
    }
    if (_nickname.text.length < 6 || _password.text.length > 15) {
        [self showHintInView:self.view hint:@"用户名应为6-15位字符"];
        [_nickname becomeFirstResponder];
        return;
    }
    if ([_password.text isEqualToString:@""]) {
        [self showHintInView:self.view hint:@"请输入密码"];
        [_password becomeFirstResponder];
        return;
    }
    if (_password.text.length < 6 || _password.text.length > 20) {
        [self showHintInView:self.view hint:@"密码应为6-20位字符"];
        [_password becomeFirstResponder];
        return;
    }
    [self hideKeyBoard];
    [self showHudInView:self.navigationController.view];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:_account.text forKey:@"phone"];
    [parameters setObject:_password.text forKey:@"password"];
    [parameters setObject:_code.text forKey:@"code"];
    [parameters setObject:_nickname.text forKey:@"username"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *url = [NSString stringWithFormat:@"%@%@",kDlHost,API_AUTH_REGISTER];
    [manager POST:url parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        [self hideHud];
        DLog(@"%@",responseObject);
        //        NSDictionary *dic= [NSDictionary dictionaryWithDictionary:responseObject];
        [self showHintInView:self.view hint:@"注册成功"];
        
        [self performBlock:^{
            [self.navigationController popToRootViewControllerAnimated:YES];
        } afterDelay:1.5];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self hideHud];
        
        NSData *data =[error.userInfo objectForKey:@"com.alamofire.serialization.response.error.data"];
        if (data) {
            NSString *result  =[[ NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSDictionary *dic= [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
            NSString *message = [dic objectForKey:@"message"];
            [self showHintInView:self.view hint:NSLocalizedString(message, nil)];
            DLog(@"%@",result);
        }else{
            [self showHintInView:self.view hint:error.localizedDescription];
        }
    }];
    
    
    
//    [manager POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        
//        [self hideHud];
//        DLog(@"%@",responseObject);
////        NSDictionary *dic= [NSDictionary dictionaryWithDictionary:responseObject];
//        [self showHintInView:self.view hint:@"注册成功"];
//        
//        [self performBlock:^{
//            [self.navigationController popToRootViewControllerAnimated:YES];
//        } afterDelay:1.5];
//        
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        
//        [self hideHud];
//        
//        NSData *data =[error.userInfo objectForKey:@"com.alamofire.serialization.response.error.data"];
//        if (data) {
//            NSString *result  =[[ NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//            NSDictionary *dic= [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
//            NSString *message = [dic objectForKey:@"message"];
//            [self showHintInView:self.view hint:NSLocalizedString(message, nil)];
//            DLog(@"%@",result);
//        }else{
//            [self showHintInView:self.view hint:error.localizedDescription];
//        }
//        
//    }];

}

//获取验证码
-(void)getCode{
    if ([_account.text isEqualToString:@""]) {
        [self showHintInView:self.view hint:@"请输入手机号码"];
        [_account becomeFirstResponder];
        return;
    }
    if (![Util isValidateMobile:_account.text]) {
        [self showHintInView:self.view hint:@"请输入正确的手机号码"];
        [_account becomeFirstResponder];
        return;
    }
    [self hideKeyBoard];
    [self showHudInView:self.view];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:_account.text forKey:@"phone"];
    [parameters setObject:@"1" forKey:@"type"];
    
    NSString *url = [NSString stringWithFormat:@"%@%@",kDlHost,API_AUTH_CODE_REGISTER];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:url parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        [self hideHud];
        [self showHintInView:self.view hint:@"验证码发送成功"];
        [self startTime];
        DLog(@"%@",responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self hideHud];
        
        NSData *data =[error.userInfo objectForKey:@"com.alamofire.serialization.response.error.data"];
        if (data) {
            NSString *result  =[[ NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSDictionary *dic= [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
            NSString *message = [dic objectForKey:@"message"];
            [self showHintInView:self.view hint:NSLocalizedString(message, nil)];
            DLog(@"%@",result);
        }else{
            [self showHintInView:self.view hint:error.localizedDescription];
        }
    }];
    
//    [manager POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        
//        [self hideHud];
//        [self showHintInView:self.view hint:@"验证码发送成功"];
//        [self startTime];
//        DLog(@"%@",responseObject);
//        //        NSDictionary *dic= [NSDictionary dictionaryWithDictionary:responseObject];
//        
//        
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        
//        [self hideHud];
//        
//        NSData *data =[error.userInfo objectForKey:@"com.alamofire.serialization.response.error.data"];
//        if (data) {
//            NSString *result  =[[ NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//            NSDictionary *dic= [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
//            NSString *message = [dic objectForKey:@"message"];
//            [self showHintInView:self.view hint:NSLocalizedString(message, nil)];
//            DLog(@"%@",result);
//        }else{
//            [self showHintInView:self.view hint:error.localizedDescription];
//        }
//        
//    }];
}

//隐藏键盘
-(void)hideKeyBoard{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - 倒计时
-(void)startTime{
    __block int timeout=59; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                getCodeBtn.titleLabel.text = @"获取验证码";
                [getCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
//                [_codeBtn setBackgroundColor:[UIColor whiteColor]];
                getCodeBtn.userInteractionEnabled = YES;
                getCodeBtn.enabled = YES;
            });
        }else{
            int seconds = timeout % 60;
            NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                //NSLog(@"____%@",strTime);
//                [UIView beginAnimations:nil context:nil];
//                [UIView setAnimationDuration:1];
                getCodeBtn.titleLabel.text = [NSString stringWithFormat:@"%@秒后重试",strTime];
                [getCodeBtn setTitle:[NSString stringWithFormat:@"%@秒后重试",strTime] forState:UIControlStateNormal];
//                [_codeBtn setBackgroundColor:[UIColor lightGrayColor]];
//                [UIView commitAnimations];
                getCodeBtn.userInteractionEnabled = NO;
                getCodeBtn.enabled = NO;
            });
            timeout--;
        }
    });
    dispatch_resume(_timer);
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
