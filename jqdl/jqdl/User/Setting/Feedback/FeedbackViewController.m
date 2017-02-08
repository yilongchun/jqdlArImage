//
//  FeedbackViewController.m
//  jqdl
//
//  Created by Stephen Chin on 17/2/8.
//  Copyright © 2017年 Stephen Chin. All rights reserved.
//

#import "FeedbackViewController.h"
#import "UITextView+PlaceHolder.h"

@interface FeedbackViewController (){
    UITextView *textView;
}

@end

@implementation FeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"意见反馈";
    
    [self initView];
}

-(void)initView{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 0, 0)];
    label.text = @"问题和意见描述";
    label.textColor = RGB(102, 102, 102);
    label.font = SYSTEMFONT(11);
    [label sizeToFit];
    [_myScrollView addSubview:label];
 
    textView = [[UITextView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(label.frame) + 15, Main_Screen_Width, 140)];
    textView.font = SYSTEMFONT(14);    
    textView.textContainerInset = UIEdgeInsetsMake(5, 10, 5, 10);
    [textView addPlaceHolder:@"请简要描述你的问题和意见"];
    [_myScrollView addSubview:textView];
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
