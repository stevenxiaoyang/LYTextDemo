//
//  NSString+MYAdd.m
//  LYTextDemo
//
//  Created by LuYang on 16/6/28.
//  Copyright © 2016年 LuYang. All rights reserved.
//

#import "NSString+MYAdd.h"

@implementation NSString (MYAdd)
- (NSString *)subStringWithMaxLength:(NSInteger)maxLength {
    __block NSString *aString = @"";
    __block int length = 0;
    [self enumerateSubstringsInRange:NSMakeRange(0, self.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        char *p = (char *)[substring cStringUsingEncoding:NSUnicodeStringEncoding];
        for (int i = 0; i < [substring lengthOfBytesUsingEncoding:NSUnicodeStringEncoding]; i++) {
            if (*p && p != '\0') {
                length++;
            }
            p++;
        }
        if (length <= maxLength) {
            aString = [aString stringByAppendingString:substring];
        }
    }];
    
    return aString;
}

//判断中英混合的的字符串长度及字符个数
- (MYTitleInfo)getInfoWithMaxLength:(NSInteger)maxLength {
    MYTitleInfo title;
    int length = 0;
    int singleNum = 0;
    int totalNum = 0;
    char *p = (char *)[self cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i = 0; i < [self lengthOfBytesUsingEncoding:NSUnicodeStringEncoding]; i++) {
        if (*p && p != '\0') {
            length++;
            if (length <= maxLength) {
                totalNum++;
            }
        }
        else {
            if (length <= maxLength) {
                singleNum++;
            }
        }
        p++;
    }
    
    title.length = length;
    title.number = (totalNum - singleNum) / 2 + singleNum;
    
    return title;
}

@end
