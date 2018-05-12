//
//  ViewController.m
//  TouchIdDemo
//
//  Created by zmubai on 2018/5/9.
//  Copyright © 2018年 zmubai. All rights reserved.
//

#import "ViewController.h"
#import "TouchIdManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
   
}

- (IBAction)touchIdAction:(id)sender {
    if ([TouchIdManager touchIdInfoDidChange]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"指纹信息变更" message:nil delegate:nil cancelButtonTitle:@"cannel" otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
        [TouchIdManager showTouchIdWithTitle:@"验证已有指纹" falldBackTitle:@"8888888" fallBackBlock:^{
            NSLog(@"fallback");
        } resultBlock:^(BOOL useable, BOOL success, NSError *error) {
            
        }];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
