//
//  ForgetPwdViewController.m
//  qlxing
//
//  Created by Stephen Chin on 16/6/23.
//  Copyright © 2016年 Stephen Chin. All rights reserved.
//

#import "ForgetPwdViewController.h"
#import "Util.h"
#import "NSObject+Blocks.h"
#import "UIViewController+JZExtension.h"

@interface ForgetPwdViewController (){
    UIButton *getCodeBtn;
}

@end

@implementation ForgetPwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"找回密码";
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName, nil];
    self.jz_navigationBarBackgroundAlpha = 0;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;//状态栏白色
    
    [_account setValue:RGBA(255, 255, 255, 0.5) forKeyPath:@"_placeholderLabel.textColor"];
    [_code setValue:RGBA(255, 255, 255, 0.5) forKeyPath:@"_placeholderLabel.textColor"];
    [_password setValue:RGBA(255, 255, 255, 0.5) forKeyPath:@"_placeholderLabel.textColor"];
    [_password2 setValue:RGBA(255, 255, 255, 0.5) forKeyPath:@"_placeholderLabel.textColor"];
    
    [_regBtn setBackgroundImage:[[UIImage imageNamed:@"loginBtnBg"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 20, 5, 20) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
    [_regBtn setBackgroundImage:[[UIImage imageNamed:@"loginBtnBg2"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 20, 5, 20) resizingMode:UIImageResizingModeStretch] forState:UIControlStateHighlighted];
    
    [_regBtn addTarget:self action:@selector(reg) forControlEvents:UIControlEventTouchUpInside];

    getCodeBtn = [[UIButton alloc] initWithFrame:CGRectMake(5, 0, 100, 40)];
    [getCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [getCodeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [getCodeBtn setTitleColor:RGBA(255, 255, 255, 0.5) forState:UIControlStateHighlighted];
    [getCodeBtn setTitleColor:RGBA(255, 255, 255, 0.5) forState:UIControlStateDisabled];
    getCodeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [getCodeBtn addTarget:self action:@selector(getCode) forControlEvents:UIControlEventTouchUpInside];
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 105, 40)];
    [rightView addSubview:getCodeBtn];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 1, 20)];
    label.backgroundColor = RGBA(255, 255, 255, 0.5);
    ViewBorderRadius(label, 1, 1, RGBA(255, 255, 255, 0.5));
    [rightView addSubview:label];
    self.account.rightViewMode = UITextFieldViewModeAlways;
    self.account.rightView = rightView;
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"backWhite"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(dissMissView)];
    
    self.navigationItem.leftBarButtonItem = leftItem;
    
}

-(void)dissMissView{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    //    self.navigationController.navigationBar.translucent = YES;
    //    [self.navigationController.navigationBar setShadowImage:[Util imageWithColor:[UIColor clearColor] size:CGSizeMake(320, 3)]];
    //    [self.navigationController.navigationBar setBackgroundImage:[Util imageWithColor:RGBA(252, 228, 75,0.0)] forBarMetrics:UIBarMetricsDefault];
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
    if ([_password.text isEqualToString:@""]) {
        [self showHintInView:self.view hint:@"请输入密码"];
        [_password becomeFirstResponder];
        return;
    }
    if ([_password2.text isEqualToString:@""]) {
        [self showHintInView:self.view hint:@"请输入确认密码"];
        [_password2 becomeFirstResponder];
        return;
    }
    if (![_password2.text isEqualToString:_password.text]) {
        [self showHintInView:self.view hint:@"两次密码不一致，请重新输入"];
        return;
    }
    [self hideKeyBoard];
    [self showHudInView:self.navigationController.view];
    
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:_account.text forKey:@"identity"];
    [parameters setObject:_password.text forKey:@"password"];
    [parameters setObject:_code.text forKey:@"code"];
    //    [parameters setObject:_nickname.text forKey:@""];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *url = [NSString stringWithFormat:@"%@%@",kDlHost,API_AUTH_RESETPWD];
    
    
    [manager POST:url parameters:parameters
    
    success:^(NSURLSessionDataTask *task, id responseObject) {
        [self hideHud];
        DLog(@"%@",responseObject);
        //        NSDictionary *dic= [NSDictionary dictionaryWithDictionary:responseObject];
        [self showHintInView:self.view hint:@"重置成功"];
        
        [self performBlock:^{
            [self.navigationController popToRootViewControllerAnimated:YES];
        } afterDelay:1.5];
    }
    failure:^(NSURLSessionDataTask *task, NSError *error) {
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
//        //        NSDictionary *dic= [NSDictionary dictionaryWithDictionary:responseObject];
//        [self showHintInView:self.view hint:@"重置成功"];
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
    
    NSString *url = [NSString stringWithFormat:@"%@%@",kDlHost,API_AUTH_CODE_RESETPWD];
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
@end
