//
//  UITextField+MYAdd.m
//  LYTextDemo
//
//  Created by LuYang on 16/6/28.
//  Copyright © 2016年 LuYang. All rights reserved.
//

#import "UITextField+MYAdd.h"
#import "NSString+MYAdd.h"
#import <objc/runtime.h>

#pragma mark - static char *const property
static char *const KTextFieldTextMaxLength = "TextFieldTextMaxLength";
static char *const KTextFieldPlaceholderFont = "TextFieldPlaceholderFont";
static char *const KTextFieldPlaceholderColor = "TextFieldPlaceholderColor";

#pragma mark - static char *const method
static char *const KTextFieldTextDidChangeMethod = "TextFieldTextDidChangeMethod";

@implementation UITextField (MYAdd)
#pragma mark - Swizzling
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(setPlaceholder:);
        SEL swizzledSelector = @selector(swizzling_setPlaceholder:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        method_exchangeImplementations(originalMethod, swizzledMethod);
        
        originalSelector = @selector(placeholder);
        swizzledSelector = @selector(swizzling_placeholder);
        
        originalMethod = class_getInstanceMethod(class, originalSelector);
        swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        method_exchangeImplementations(originalMethod, swizzledMethod);
        
        originalSelector = @selector(initWithFrame:);
        swizzledSelector = @selector(swizzling_initWithFrame:);
        
        originalMethod = class_getInstanceMethod(class, originalSelector);
        swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        method_exchangeImplementations(originalMethod, swizzledMethod);
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wundeclared-selector"
        protocol_addMethodDescription(objc_getProtocol([@"UITextField" UTF8String]), @selector(textFieldDidChange:), KTextFieldTextDidChangeMethod, NO, YES);
#pragma clang diagnostic pop
    });
}

- (NSString *)swizzling_placeholder {
    return self.attributedPlaceholder.string;
}

- (void)swizzling_setPlaceholder:(NSString *)placeholder {
    if (!placeholder) {
        return;
    }
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:placeholder];
    if (self.placeholderColor) {
        [attributedString addAttribute:NSForegroundColorAttributeName value:self.placeholderColor range:NSMakeRange(0, placeholder.length)];
    }
    if (self.placeholderFont) {
        [attributedString addAttribute:NSFontAttributeName value:self.placeholderFont range:NSMakeRange(0, placeholder.length)];
    }
    self.attributedPlaceholder = attributedString;
}

- (instancetype)swizzling_initWithFrame:(CGRect)frame {
    [self swizzling_initWithFrame:frame];
    [self textField_addObserver];
    return self;
}

#pragma mark - @property setter getter
- (NSUInteger)maxLength {
    NSNumber *maxLengthNum = objc_getAssociatedObject(self, KTextFieldTextMaxLength);
    if (!maxLengthNum) {
        return NSUIntegerMax;
    }
    return [maxLengthNum unsignedIntegerValue];
}

- (void)setMaxLength:(NSUInteger)maxLength {
    objc_setAssociatedObject(self, KTextFieldTextMaxLength, @(maxLength), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIFont *)placeholderFont {
    return objc_getAssociatedObject(self, KTextFieldPlaceholderFont);
}

- (void)setPlaceholderFont:(UIFont *)placeholderFont {
    objc_setAssociatedObject(self, KTextFieldPlaceholderFont, placeholderFont, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setPlaceholder:self.placeholder];
}

- (UIColor *)placeholderColor {
    return objc_getAssociatedObject(self, KTextFieldPlaceholderColor);
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor {
    objc_setAssociatedObject(self, KTextFieldPlaceholderColor, placeholderColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setPlaceholder:self.placeholder];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private method
- (void)textField_addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textField_textDidChange:) name:UITextFieldTextDidChangeNotification object:self];
}

#pragma mark - Notification Action-Event
- (void)textField_textDidChange:(NSNotification *)notification {
    UITextField *textField = notification.object;
    NSString *text = textField.text;
    if (self.maxLength != NSUIntegerMax) {
        MYTitleInfo titleInfo = [text getInfoWithMaxLength:self.maxLength];
        if (titleInfo.length > self.maxLength) {
            UITextRange *selectedRange = [textField markedTextRange];
            UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
            if (!position) {
                UITextRange *textRange = textField.selectedTextRange;
                textField.text = [textField.text subStringWithMaxLength:self.maxLength];
                textField.selectedTextRange = textRange;
            }
        }
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wundeclared-selector"
    if (self.delegate && [self.delegate respondsToSelector:@selector(textFieldDidChange:)]) {
        [self.delegate performSelector:@selector(textFieldDidChange:) withObject:self];
    }
#pragma clang diagnostic pop
}

@end
