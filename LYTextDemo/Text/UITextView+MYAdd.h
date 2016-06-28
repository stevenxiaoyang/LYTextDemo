//
//  UITextView+MYAdd.h
//  LYTextDemo
//
//  Created by LuYang on 16/6/28.
//  Copyright © 2016年 LuYang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextView (MYAdd)
@property (nonatomic, assign) NSUInteger maxLength;
@property (nonatomic,   copy) NSString *placeholder;
@property (nonatomic, strong) UIFont *placeholderFont;
@property (nonatomic, strong) UIColor *placeholderColor;
@end
