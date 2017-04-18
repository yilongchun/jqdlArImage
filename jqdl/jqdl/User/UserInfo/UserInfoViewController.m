//
//  UserInfoViewController.m
//  qlxing
//
//  Created by Stephen Chin on 16/7/26.
//  Copyright © 2016年 Stephen Chin. All rights reserved.
//

#import "UserInfoViewController.h"
#import "UserInfoTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "Util.h"
#import "NSString+DictionaryValue.h"
#import "BWStatusBarOverlay.h"

@interface UserInfoViewController (){
    UIImageView *headImageView;
    NSMutableDictionary *userInfo;
    
    int type;
    UIImage *avatar;
    UIImage *backgroundImage;
    
    NSMutableDictionary *updateUserInfoDic;
    UITextField *nicknameTF;
    UITextField *cityTF;
    UITextField *sexTF;
    UITextField *taglineTF;
}

@end

@implementation UserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    updateUserInfoDic = [NSMutableDictionary dictionary];
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    [cancelItem setTintColor:RGB(67,216,230)];
    self.navigationItem.leftBarButtonItem = cancelItem;
    UIBarButtonItem *okItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(ok)];
    [okItem setTintColor:RGB(67,216,230)];
    self.navigationItem.rightBarButtonItem = okItem;
    
    headImageView = [[UIImageView alloc] init];
    [headImageView setFrame:CGRectMake(0, 0, 60, 60)];
    ViewBorderRadius(headImageView, 30, 1, [UIColor whiteColor]);
//    //设置头像显示形状
//    UIRectCorner corners = UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft;
//    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:headImageView.bounds
//                                                   byRoundingCorners:corners
//                                                         cornerRadii:CGSizeMake(headImageView.frame.size.width/2, headImageView.frame.size.width/2)];
//    CAShapeLayer *maskLayer = [CAShapeLayer layer];
//    maskLayer.frame = headImageView.bounds;
//    maskLayer.path = maskPath.CGPath;
//    headImageView.layer.mask = maskLayer;
    
    [self loadData];
}

//加载个人信息
-(void)loadData{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    userInfo = [NSMutableDictionary dictionaryWithDictionary:[ud objectForKey:LOGINED_USER]];
    
    [_myTableView reloadData];
}

-(void)cancel{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)ok{
    
    if (![nicknameTF.text isEqualToString:@""]) {
        [updateUserInfoDic setObject:nicknameTF.text forKey:@"nickname"];//昵称
    }
    if (![cityTF.text isEqualToString:@""]) {
        [updateUserInfoDic setObject:cityTF.text forKey:@"city"];//城市
    }
//    if (![taglineTF.text isEqualToString:@""]) {
//        [updateUserInfoDic setObject:taglineTF.text forKey:@"tagline"];//个性签名
//    }
    if ([sexTF.text isEqualToString:@"男"]) {
        [updateUserInfoDic setObject:@"male" forKey:@"sex"];//性别
    }else if ([sexTF.text isEqualToString:@"女"]){
        [updateUserInfoDic setObject:@"female" forKey:@"sex"];//性别
    }
    
    [self.view endEditing:YES];
    [self showHudInView:self.view];
    [self saveData:updateUserInfoDic dissmissView:YES];
    
}

-(void)showSexAlert{
    UIAlertController *sexAlert = [UIAlertController alertControllerWithTitle:@"请选择性别" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"男" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        sexTF.text = @"男";
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"女" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        sexTF.text = @"女";
    }];
    [sexAlert addAction:action1];
    [sexAlert addAction:action2];
    [self presentViewController:sexAlert animated:YES completion:nil];
}

-(void)showImagePicker{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"用户相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UIImagePickerController *imagePicker2 = [[UIImagePickerController alloc] init];
        imagePicker2.delegate = self;
        imagePicker2.allowsEditing = NO;
        imagePicker2.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker2.mediaTypes =  [[NSArray alloc] initWithObjects:@"public.image", nil];
        [[imagePicker2 navigationBar] setTintColor:RGB(67,216,230)];
        [[imagePicker2 navigationBar] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], NSForegroundColorAttributeName, nil]];
        [self presentViewController:imagePicker2 animated:YES completion:nil];
    }];
    [alert addAction:action1];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //检查相机模式是否可用
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            NSLog(@"sorry, no camera or camera is unavailable.");
            return;
        }
        UIImagePickerController  *imagePicker1 = [[UIImagePickerController alloc] init];
        imagePicker1.delegate = self;
        imagePicker1.allowsEditing = NO;
        imagePicker1.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker1.mediaTypes =  [[NSArray alloc] initWithObjects:@"public.image", nil];
        [self presentViewController:imagePicker1 animated:YES completion:nil];
    }];
    [alert addAction:action2];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:^{
        
    }];
}

//七牛上传图片
/**************************************/
//上传第一步
-(void)getToken:(NSData *)data{
    [self showHudInView:self.navigationController.view];
    
    NSString *uuid = [Util uuidString];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:uuid forKey:@"key"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSString *url = [NSString stringWithFormat:@"%@%@%@",kHost,kVERSION,API_QINIU_UPTOKEN];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDictionary *loginedUser = [ud objectForKey:LOGINED_USER];
    NSString *value = [NSString stringWithFormat:@"Bearer %@",[loginedUser objectForKey:@"access_token"]];
    [manager.requestSerializer setValue:value forHTTPHeaderField:@"Authorization"];
    
    [manager GET:url parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        DLog(@"%@",responseObject);
        NSString *token = [responseObject objectForKey:@"token"];
        [self uploadImage:token imageData:data uuid:uuid];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self hideHud];
        DLog(@"%@",error);
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
}

//上传第二步
-(void)uploadImage:(NSString *)token imageData:(NSData *)data uuid:(NSString *)uuid{
    
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.navigationController.view];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        hud.mode = MBProgressHUDModeAnnularDeterminate;
        hud.label.text = @"上传中";
    });
    
//    [BWStatusBarOverlay setAnimation:BWStatusBarOverlayAnimationTypeFade];
//    [BWStatusBarOverlay showWithMessage:@"正在上传图片" loading:YES animated:YES];
//    [BWStatusBarOverlay setProgress:0.0 animated:YES];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:token forKey:@"token"];
    NSString *urlString = [NSString stringWithFormat:@"%@",API_QINIU_UPLOAD];
    [parameters setValue:uuid forKey:@"key"];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDictionary *loginedUser = [ud objectForKey:LOGINED_USER];
    [parameters setValue:[NSString stringWithFormat:@"%@",[loginedUser objectForKey:@"id"]] forKey:@"x:userId"];
    
    
    AFHTTPRequestOperationManager* _manager = [AFHTTPRequestOperationManager manager];
    
    _manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    
    NSMutableURLRequest* request = [_manager.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:data name:@"file" fileName:@"1.png" mimeType:@"image/png"];
    } error:nil];
    
    AFHTTPRequestOperation *operation = [_manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        DLog(@"上传图片 第二步 带上 token 上传文件 成功");
        
//        [BWStatusBarOverlay setMessage:@"上传成功" animated:NO];
//        [BWStatusBarOverlay setProgress:1.0 animated:YES];
//        [BWStatusBarOverlay dismissAnimated:YES duration:1.0];
        
        NSString *result  =[[ NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        DLog(@"%@",result);
        
        //        {
        //            id = "7f1bc291-0ad4-4276-b2b8-a1b033f0a896";
        //            type = image;
        //            url = "http://o85ghilm8.bkt.clouddn.com//7f1bc291-0ad4-4276-b2b8-a1b033f0a896";
        //            userId = 57ba76b31f5496001a31e7ee;
        //        }
        
        
        NSDictionary *resultDic = [result dictionaryValue];
        DLog(@"%@",resultDic);
        NSString *imgUrl = [resultDic objectForKey:@"url"];
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        if (type == 1) {//用户头像
            [parameters setObject:imgUrl forKey:@"avatar"];
        }
//        else if (type == 2){//背景图片
//            [parameters setObject:imgUrl forKey:@"backgroundImage"];
//        }
        [self saveData:parameters dissmissView:NO];
        
        //        NSDictionary *dic = [NSDictionary di]
        
        //        {"id":"54176ff8-8299-4ea9-9140-cd1b89456648","type":"image","url":"http://o85ghilm8.bkt.clouddn.com//54176ff8-8299-4ea9-9140-cd1b89456648","userId":"57ba76b31f5496001a31e7ee"}
        
        //        NSError *error;
        //        NSDictionary *dic= [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        //        if (dic == nil) {
        //            NSLog(@"json parse failed \r\n");
        //        }else{
        //            NSString *key = [dic objectForKey:@"key"];
        //            DLog(@"key:%@",key);
        ////            [self saveData:key];
        //        }
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        
        NSLog(@"发生错误！%@",error);
        DLog(@"上传图片 第二步 带上 token 上传文件 失败");
        //        [BWStatusBarOverlay dismissAnimated:YES];
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
    
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        
        DLog(@"%f",(float)totalBytesWritten/totalBytesExpectedToWrite);
        
        float progress = (float)totalBytesWritten/totalBytesExpectedToWrite;
        
//        dispatch_sync(dispatch_get_main_queue(), ^{
//            [[BWStatusBarOverlay shared] setProgress:progress animated:YES];
//        });

        dispatch_async(dispatch_get_main_queue(), ^{
            hud.progress = progress;
        });
        
        
        
    }];  
    
    [operation start];
}

//保存数据
-(void)saveData:(NSDictionary *)parameters dissmissView:(BOOL)flag{
    
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.navigationController.view];
    dispatch_async(dispatch_get_main_queue(), ^{
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.label.text = @"";
    });
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSString *url = [NSString stringWithFormat:@"%@%@%@",kHost,kVERSION,API_USERS_CURRENT];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDictionary *loginedUser = [ud objectForKey:LOGINED_USER];
    NSString *value = [NSString stringWithFormat:@"Bearer %@",[loginedUser objectForKey:@"access_token"]];
    [manager.requestSerializer setValue:value forHTTPHeaderField:@"Authorization"];
    
    [manager PUT:url parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        DLog(@"%@",responseObject);

        
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [userInfo setValuesForKeysWithDictionary:parameters];
        [ud setObject:userInfo forKey:LOGINED_USER];
        
        DLog(@"%@",userInfo);

        [[NSNotificationCenter defaultCenter] postNotificationName:@"loadUserCenterInfo" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"setLeftItem" object:nil];
        
        if (flag) {
            [self hideHud];
            [self dismissViewControllerAnimated:YES completion:nil];
        }else{
            [self loadData];

            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *image = [[UIImage imageNamed:@"Checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
                hud.customView = imageView;
                hud.mode = MBProgressHUDModeCustomView;
                hud.label.text = @"修改成功";
                
            });
            [hud hideAnimated:YES afterDelay:1.5];
            
            
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DLog(@"%@",error);
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
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
//    [BWStatusBarOverlay dismissAnimated];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.operationQueue cancelAllOperations];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIImagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"public.image"]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        NSData* data = UIImageJPEGRepresentation(image,1.0f);
        DLog(@"%lu",(unsigned long)data.length);
        if (type == 1) {
            avatar = [UIImage imageWithData:data];
        }
//        if (type == 2) {
//            backgroundImage = [UIImage imageWithData:data];
//        }

        [self getToken:data];
        //        [self uploadImage];
        
        
        //        [self.chooseBtn setImage:choosedImage forState:UIControlStateNormal];
        
        //        NSData* data = UIImageJPEGRepresentation(img,0.7f);
        //        DLog(@"type:%d",type);
        //[self uploadImage:data];
        
        
        
        
        
        //        NSData *fildData = UIImageJPEGRepresentation(img, 0.5);//UIImagePNGRepresentation(img); //
        //照片
        //        [self uploadImg:fildData];
        //        self.fileData = UIImageJPEGRepresentation(img, 1.0);
    }
    [picker dismissViewControllerAnimated:YES completion:^{
        
        
    }];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    // bug fixes: UIIMagePickerController使用中偷换StatusBar颜色的问题
    if ([navigationController isKindOfClass:[UIImagePickerController class]] &&
        ((UIImagePickerController *)navigationController).sourceType ==     UIImagePickerControllerSourceTypePhotoLibrary) {
//        [[UIApplication sharedApplication] setStatusBarHidden:NO];
//        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    }
    //    if([viewController isKindOfClass:[SettingViewController class]]){
    //        NSLog(@"返回");
    //        return;
    //    }
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 80;
    }
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    
    if (indexPath.section == 0) {
        static NSString *CellIdentifier = @"cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            cell.textLabel.textColor = RGB(102, 102, 102);
            
        }
        
        if (indexPath.row == 0) {
            cell.textLabel.text = @"更换头像";
            
            NSString *avatarUrl = [userInfo objectForKey:@"avatar"];
            if (avatarUrl) {
                [headImageView setImageWithURL:[NSURL URLWithString:avatarUrl]];
            }else{
                [headImageView setImage:[UIImage imageNamed:@"member_no.gif"]];
            }
            
            cell.accessoryView = headImageView;
            
        }
        
        return cell;
    }else if (indexPath.section == 1){
        
        static NSString *CellIdentifier = @"userInfoCell";
        UserInfoTableViewCell *cell = (UserInfoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil){
            cell= (UserInfoTableViewCell *)[[[NSBundle  mainBundle] loadNibNamed:@"UserInfoTableViewCell" owner:self options:nil]  lastObject];
        
        }
        if (indexPath.row == 0) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.myTitleLabel.text = @"昵称";
            NSString *nickname = [userInfo objectForKey:@"nickname"];
            cell.myTextField.text = nickname;
            cell.myTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
            nicknameTF = cell.myTextField;
        }
        if (indexPath.row == 1) {
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.myTitleLabel.text = @"性别";
            NSString *sex = [userInfo objectForKey:@"sex"];
            if (sex) {
                if ([sex isEqualToString:@"male"]) {
                    cell.myTextField.text = @"男";
                }else if ([sex isEqualToString:@"female"]){
                    cell.myTextField.text = @"女";
                }
            }else{
                cell.myTextField.placeholder = @"未设置";
            }
            cell.myTextField.userInteractionEnabled = NO;
            sexTF = cell.myTextField;
        }
        if (indexPath.row == 2) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.myTitleLabel.text = @"城市";
            NSString *city = [userInfo objectForKey:@"city"];
            if (city) {
                cell.myTextField.text = city;
            }else{
                cell.myTextField.placeholder = @"未设置";
            }
            cell.myTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
            cityTF = cell.myTextField;
        }
//        if (indexPath.row == 3) {
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            cell.myTitleLabel.text = @"个性签名";
//            NSString *tagline = [userInfo objectForKey:@"tagline"];
//            if (tagline) {
//                cell.myTextField.text = tagline;
//            }else{
//                cell.myTextField.placeholder = @"未设置";
//            }
//            cell.myTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
//            taglineTF = cell.myTextField;
//        }
        return cell;
    }
//    else if (indexPath.section == 2){
//        static NSString *CellIdentifier = @"cell2";
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//        if (cell == nil) {
//            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//            cell.textLabel.font = [UIFont systemFontOfSize:14];
//            cell.textLabel.textColor = RGB(102, 102, 102);
//            cell.textLabel.textAlignment = NSTextAlignmentCenter;
//        }
//        cell.textLabel.text = @"更换个人背景";
//        return cell;
//    }
    return nil;
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    if (indexPath.section == 0) {
        type = 1;
        [self showImagePicker];
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 1) {
            [self showSexAlert];
        }
    }
//    if (indexPath.section == 2) {
//        type = 2;
//        [self showImagePicker];
//    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.1;
    }
    return 0.1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    //    if (section == 2) {
    //        return 45;
    //    }
    return 11;
}



@end
