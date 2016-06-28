//
//  ViewController.m
//  LYTextDemo
//
//  Created by LuYang on 16/6/28.
//  Copyright © 2016年 LuYang. All rights reserved.
//

#import "ViewController.h"
#import "UITextField+MYAdd.h"
#import "UITextView+MYAdd.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(50, 100, 100, 15)];
    tf.layer.borderColor = [UIColor grayColor].CGColor;
    tf.layer.borderWidth = 1.f;
    tf.maxLength = 10;
    tf.placeholder = @"我是textField";
    tf.placeholderFont = [UIFont systemFontOfSize:15];
    tf.placeholderColor = [UIColor yellowColor];
    [self.view addSubview:tf];
    
    UITextView *tv = [[UITextView alloc] initWithFrame:CGRectMake(50, CGRectGetMaxY(tf.frame) + 20, 100, 50)];
    tv.layer.borderColor = [UIColor grayColor].CGColor;
    tv.layer.borderWidth = 1.f;
    tv.maxLength = 20;
    tv.placeholder = @"我是textView";
    tv.placeholderFont = [UIFont systemFontOfSize:15];
    tv.placeholderColor = [UIColor redColor];
    [self.view addSubview:tv];
}

@end
