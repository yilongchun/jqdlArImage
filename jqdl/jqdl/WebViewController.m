//
//  WebViewController.m
//  jqdl
//
//  Created by Stephen Chin on 17/2/24.
//  Copyright © 2017年 Stephen Chin. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"全景导览";
    
    [self.myWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://cs.jimiec.com/index.php?a=s&s=case&id=8604&from=singlemessage&isappinstalled=0&WebShieldDRSessionVerify=2aZ5sWcMjiclaDeWzLv4"]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
