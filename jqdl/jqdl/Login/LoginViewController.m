//
//  LoginViewController.m
//  qlx
//
//  Created by Stephen Chin on 16/3/16.
//  Copyright © 2016年 Stephen Chin. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
//#import "HomeViewController.h"
#import "ForgetPwdViewController.h"
#import "LoginForCodeViewController.h"
#import "UINavigationController+JZExtension.h"
#import "UIViewController+JZExtension.h"
#import "Util.h"
#import "MainTabBarController.h"

@interface LoginViewController (){
    RegisterViewController *regVc;
    ForgetPwdViewController *forgetPwdVc;
    LoginForCodeViewController *msgVc;
}

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [_loginBtn setBackgroundImage:[Util imageWithColor:DEFAULT_COLOR] forState:UIControlStateNormal];
//    [_forgetPassword setTextColor:DEFAULT_COLOR];
//    [_toRegister setTextColor:DEFAULT_COLOR];
//    [_msgLogin setTextColor:DEFAULT_COLOR];
    
    self.jz_navigationBarBackgroundAlpha = 0;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;//状态栏白色
    
    [_account setValue:RGBA(189, 189, 189, 1) forKeyPath:@"_placeholderLabel.textColor"];
    [_password setValue:RGBA(189, 189, 189, 1) forKeyPath:@"_placeholderLabel.textColor"];
    
    [_loginBtn setBackgroundImage:[[UIImage imageNamed:@"loginBtnDisabled"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 20, 5, 20) resizingMode:UIImageResizingModeStretch] forState:UIControlStateDisabled];
    [_loginBtn setBackgroundImage:[[UIImage imageNamed:@"loginBtnHighLight"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 20, 5, 20) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
    
    UIButton *showPwd = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [showPwd setImage:[UIImage imageNamed:@"showPwd"] forState:UIControlStateNormal];
    _password.rightViewMode = UITextFieldViewModeAlways;
    _password.rightView = showPwd;
    [showPwd addTarget:self action:@selector(showPwd) forControlEvents:UIControlEventTouchUpInside];
    
//    ViewBorderRadius(_loginBtn, 6, 1.0, [UIColor whiteColor]);
    
    // Do any additional setup after loading the view from its nib.
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
//    [self.view addGestureRecognizer:tap];
//    
//    [self.navigationController setNavigationBarHidden:YES];
//    
//    [_loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [_loginBtn setBackgroundImage:[UIImage imageNamed:@"btnBg"] forState:UIControlStateNormal];
//    _loginBtn.layer.masksToBounds = YES;
//    _loginBtn.layer.cornerRadius = 20;
    [_loginBtn addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
  
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(findPassword)];
    [_forgetPassword addGestureRecognizer:tap1];
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loginForMsg)];
    [_toRegister addGestureRecognizer:tap2];
    UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loginForMsg)];
    [_msgLogin addGestureRecognizer:tap3];
    
//    NSMutableAttributedString *content = [[NSMutableAttributedString alloc]initWithString:_forgetPassword.text];
//    NSRange contentRange = {0,[content length]};
//    [content addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];
//    _forgetPassword.attributedText = content;
    
//    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"验证码登录" style:UIBarButtonItemStyleDone target:self action:@selector(loginForMsg)];
//    [rightItem setTintColor:[UIColor whiteColor]];
//    self.navigationItem.rightBarButtonItem = rightItem;
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"navi_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(dissMissView)];
    
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIButton *registerBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    
    [registerBtn setFrame:CGRectMake(15, Main_Screen_Height - 50 - 41, Main_Screen_Width - 30, 41)];
    [registerBtn setBackgroundImage:[[UIImage imageNamed:@"registerBtn"] resizableImageWithCapInsets:UIEdgeInsetsMake(40, 20.5, 40, 20.5) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
//    registerBtn.titleLabel.font = SYSTEMFONT(15);
//    registerBtn.backgroundColor = RGB(239, 246, 247);
//    ViewBorderRadius(registerBtn, 20.5, 1, RGB(66, 216, 230));
    [registerBtn setTitle:@"立即注册" forState:UIControlStateNormal];
    [registerBtn setTitleColor:RGB(66, 216, 230) forState:UIControlStateNormal];
    [registerBtn addTarget:self action:@selector(goToRegisger) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:registerBtn];

//    UIBarButtonItem *returnButtonItem = [[UIBarButtonItem alloc] init];
//    returnButtonItem.title = @"返回";
//    self.navigationItem.backBarButtonItem = returnButtonItem;
//     [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
//    [self.navigationItem setHidesBackButton:YES];
    
    
//    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(-233, -230) forBarMetrics:UIBarMetricsDefault];
    
//    UIBarButtonItem *returnButtonItem = [[UIBarButtonItem alloc] init];
//    returnButtonItem.image = [UIImage imageNamed:@"backWhite"];
////    self.navigationItem.backBarButtonItem = returnButtonItem;
//    
//    self.navigationController.navigationItem.backBarButtonItem = returnButtonItem;
    
//    self.navigationController.navigationBar.backIndicatorImage = [UIImage imageNamed:@"backWhite"];
//    self.navigationController.navigationBar.backIndicatorTransitionMaskImage = [UIImage imageNamed:@"backWhite"];
    
//    [UINavigationBar appearance].backIndicatorTransitionMaskImage = [UIImage imageNamed:@"backArrowMask.png"];
//    
//    [UINavigationBar appearance].backIndicatorImage = [UIImage imageNamed:@"icon_arrowback_n”];

    
//    if (DEBUG) {
//        _account.text = @"18671701215";
//        _password.text = @"123456";
//    }
    
//    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Main_Screen_Width, CGRectGetMinY(_account.frame) - 30)];
    
    
    
    
//    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
//    gradientLayer.colors = @[(__bridge id)RGB(37, 202, 220).CGColor, (__bridge id)RGB(77, 220, 232).CGColor];
//    gradientLayer.startPoint = CGPointMake(0, 1);
//    gradientLayer.endPoint = CGPointMake(0, 0);
    
    
//    UIImageView *imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginBg"]];
//    [imageview setFrame:CGRectMake(0, 0, Main_Screen_Width, 227)];
//    [self.view addSubview:imageview];
//    [imageview setFrame:CGRectMake(0, CGRectGetHeight(topView.frame) - CGRectGetHeight(imageview.frame), CGRectGetWidth(topView.frame), CGRectGetHeight(imageview.frame))];
    
    
//    gradientLayer.frame = CGRectMake(0, 0, CGRectGetWidth(topView.frame), CGRectGetHeight(topView.frame) - CGRectGetHeight(imageview.frame));
//    [topView.layer addSublayer:gradientLayer];
    
    
    
//    [topView addSubview:imageview];
//
//    CAGradientLayer *gradientLayer2 = [CAGradientLayer layer];
//    gradientLayer2.colors = @[(__bridge id)RGB(16, 208, 205).CGColor, (__bridge id)RGB(103, 229, 240).CGColor];
//    gradientLayer2.startPoint = CGPointMake(1, 0);
//    gradientLayer2.endPoint = CGPointMake(0, 1);
//    gradientLayer2.frame = CGRectMake(CGRectGetWidth(topView.frame)/2, 0, CGRectGetWidth(topView.frame)/2, CGRectGetHeight(topView.frame)/2);
//    [topView.layer addSublayer:gradientLayer2];
//    
//    CAGradientLayer *gradientLayer3 = [CAGradientLayer layer];
//    gradientLayer3.colors = @[(__bridge id)RGB(16, 208, 205).CGColor, (__bridge id)RGB(103, 229, 240).CGColor];
//    gradientLayer3.startPoint = CGPointMake(0, 1);
//    gradientLayer3.endPoint = CGPointMake(1, 0);
//    gradientLayer3.frame = CGRectMake(0, CGRectGetHeight(topView.frame)/2, CGRectGetWidth(topView.frame)/2, CGRectGetHeight(topView.frame)/2);
//    [topView.layer addSublayer:gradientLayer3];
//
//    CAGradientLayer *gradientLayer4 = [CAGradientLayer layer];
//    gradientLayer4.colors = @[(__bridge id)RGB(16, 208, 205).CGColor, (__bridge id)RGB(103, 229, 240).CGColor];
//    gradientLayer4.startPoint = CGPointMake(1, 1);
//    gradientLayer4.endPoint = CGPointMake(0, 0);
//    gradientLayer4.frame = CGRectMake(CGRectGetWidth(topView.frame)/2, CGRectGetHeight(topView.frame)/2, CGRectGetWidth(topView.frame)/2, CGRectGetHeight(topView.frame)/2);
//    [topView.layer addSublayer:gradientLayer4];
    
    
//    [self.view addSubview:topView];
}

-(void)dissMissView{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)showPwd{
    _password.secureTextEntry = !_password.secureTextEntry;
}

//登录
-(void)login{
    if ([_account.text isEqualToString:@""]) {
        [self showHintInView:self.view hint:@"请输入手机号码" ];
        [_account becomeFirstResponder];
        return;
    }
    if ([_password.text isEqualToString:@""]) {
        [self showHintInView:self.view hint:@"请输入密码"];
        [_password becomeFirstResponder];
        return;
    }
    [self hideKeyBoard];
    [self showHudInView:self.navigationController.view];
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:_account.text forKey:@"username"];
    [parameters setObject:_password.text forKey:@"password"];
    [parameters setObject:@"password" forKey:@"grant_type"];
    [parameters setObject:@"4e17b8ae60040835e1cf9b93ecc60edf" forKey:@"client_id"];
    [parameters setObject:@"secret.1" forKey:@"client_secret"];
    
    NSString *url = [NSString stringWithFormat:@"%@%@",@"https://api.qlxing.com",@"/oauth2/token"];
    [manager POST:url parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        [self hideHud];
        [self showHintInView:self.view hint:@"登录成功"];
        NSDictionary *dic= [NSDictionary dictionaryWithDictionary:responseObject];
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:[dic objectForKey:@"data"] forKey:LOGINED_USER];
//        data =     {
//            "access_token" = 942da2e8840c8e2ef3558d66dad65a57826d2349;
//            "created_at" = "2016-12-22T19:32:36.690Z";
//            "expires_in" = 3600;
//            id = 852240d5d7dcf8b3e866e3dbae73dc0f;
//            "last_login_time" = "2017-02-06T15:44:08.166Z";
//            name = "\U5c0f\U5f20";
//            phone = 18671701215;
//            "refresh_token" = ea8271c2618aeed1c25868cecec7bfee96edc186;
//            roles =         (
//                             judge
//                             );
//            stores =         (
//                              {
//                                  "domain_name" = snjly;
//                                  id = 66c005a1dde2152bb630142a0c797844;
//                                  key = 11887157;
//                                  name = "\U795e\U519c\U67b6";
//                                  rev = "_UfX145C---";
//                              }
//                              );
//            "token_type" = bearer;
//            "updated_at" = "2017-02-06T15:44:08.174Z";
//            username = user02;
//        };
        DLog(@"%@",[dic objectForKey:@"data"]);
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"setLeftItem" object:nil];
        }];
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
//        NSDictionary *dic= [NSDictionary dictionaryWithDictionary:responseObject];
//        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
//        [ud setObject:dic forKey:LOGINED_USER];
//        DLog(@"%@",dic);
//        
////        HomeViewController *homeVc = [[HomeViewController alloc] init];
////        homeVc.jz_wantsNavigationBarVisible = NO;
////        [homeVc setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
////        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:homeVc];
//////        nc.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:17],NSFontAttributeName, nil];
////        nc.jz_fullScreenInteractivePopGestureEnabled = YES;
//        
//        
////        MainTabBarController *tbc = [[MainTabBarController alloc] init];
////        [tbc setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
////        [self presentViewController:tbc animated:YES completion:^{
////            
////        }];
//        
//        
//        [self.navigationController dismissViewControllerAnimated:YES completion:^{
//            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINED_REFRESH_USERCENTER object:nil];
//        }];
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

//找回密码
-(void)findPassword{
    if (forgetPwdVc == nil) {
        forgetPwdVc = [[ForgetPwdViewController alloc] init];
    }
    forgetPwdVc.backToRoot = YES;
    UIBarButtonItem *backItem=[[UIBarButtonItem alloc] init];
    UIImage *backImage = [UIImage imageNamed:@"navi_back2"];
    [backItem setBackButtonBackgroundImage:[backImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, backImage.size.width, 0, 0)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];//更改背景图片
    self.navigationItem.backBarButtonItem = backItem;
    [self.navigationController pushViewController:forgetPwdVc animated:YES];
}

//注册
-(void)goToRegisger{
    if (regVc == nil) {
        regVc = [[RegisterViewController alloc] init];
    }
    UIBarButtonItem *backItem=[[UIBarButtonItem alloc] init];
    UIImage *backImage = [UIImage imageNamed:@"navi_back2"];
    [backItem setBackButtonBackgroundImage:[backImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, backImage.size.width, 0, 0)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];//更改背景图片
    self.navigationItem.backBarButtonItem = backItem;
    [self.navigationController pushViewController:regVc animated:YES];
}

//短信登录
-(void)loginForMsg{
    if (msgVc == nil) {
        msgVc = [[LoginForCodeViewController alloc] init];
//        msgVc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    }
    msgVc.loginVCAccount = self.account.text;
    UIBarButtonItem *backItem=[[UIBarButtonItem alloc] init];
    UIImage *backImage = [UIImage imageNamed:@"navi_back"];
    [backItem setBackButtonBackgroundImage:[backImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, backImage.size.width, 0, 0)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];//更改背景图片
    self.navigationItem.backBarButtonItem = backItem;
    [self.navigationController pushViewController:msgVc animated:YES];
//    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:msgVc];
//    [self presentViewController:nc animated:YES completion:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

//隐藏键盘
-(void)hideKeyBoard{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
