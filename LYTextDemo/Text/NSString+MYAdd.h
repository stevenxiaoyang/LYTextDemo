//
//  NSString+MYAdd.h
//  LYTextDemo
//
//  Created by LuYang on 16/6/28.
//  Copyright © 2016年 LuYang. All rights reserved.
//

#import <Foundation/Foundation.h>

struct MYTitleInfo {
    NSInteger length;
    NSInteger number;
};
typedef struct MYTitleInfo MYTitleInfo;

@interface NSString (MYAdd)
- (NSString *)subStringWithMaxLength:(NSInteger)maxLength;
- (MYTitleInfo)getInfoWithMaxLength:(NSInteger)maxLength;
@end
