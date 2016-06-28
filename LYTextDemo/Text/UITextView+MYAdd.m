//
//  UITextView+MYAdd.m
//  LYTextDemo
//
//  Created by LuYang on 16/6/28.
//  Copyright © 2016年 LuYang. All rights reserved.
//

#import "UITextView+MYAdd.h"
#import "NSString+MYAdd.h"
#import <objc/runtime.h>

#pragma mark - static char *const property
static char *const KTextViewTextMaxLength = "TextViewTextMaxLength";
static char *const KTextViewTextPlaceholder = "TextViewTextPlaceholder";
static char *const KTextViewTextPlaceholderLabel = "TextViewTextPlaceholderLabel";
static char *const KTextViewTextPlaceholderFont = "TextViewTextPlaceholderFont";
static char *const KTextViewTextPlaceholderColor = "TextViewTextPlaceholderColor";

@implementation UITextView (MYAdd)
#pragma mark - swizzling
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(setText:);
        SEL swizzledSelector = @selector(swizzling_setText:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        method_exchangeImplementations(originalMethod, swizzledMethod);
        
        originalSelector = @selector(setAttributedText:);
        swizzledSelector = @selector(swizzling_setAttributedText:);
        
        originalMethod = class_getInstanceMethod(class, originalSelector);
        swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        method_exchangeImplementations(originalMethod, swizzledMethod);
        
        originalSelector = @selector(layoutSubviews);
        swizzledSelector = @selector(swizzling_layoutSubviews);
        
        originalMethod = class_getInstanceMethod(class, originalSelector);
        swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        method_exchangeImplementations(originalMethod, swizzledMethod);
        
        originalSelector = @selector(initWithFrame:);
        swizzledSelector = @selector(swizzling_initWithFrame:);
        
        originalMethod = class_getInstanceMethod(class, originalSelector);
        swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}

- (void)swizzling_setText:(NSString *)text {
    [self swizzling_setText:text];
    if (text.length == 0) {
        self.placeholderLabel.hidden = NO;
    } else {
        self.placeholderLabel.hidden = YES;
    }
}

- (void)swizzling_setAttributedText:(NSAttributedString *)attributedText {
    [self swizzling_setAttributedText:attributedText];
    if (attributedText.length == 0) {
        self.placeholderLabel.hidden = NO;
    } else {
        self.placeholderLabel.hidden = YES;
    }
}

- (instancetype)swizzling_initWithFrame:(CGRect)frame {
    [self swizzling_initWithFrame:frame];
    [self textView_addObserver];
    return self;
}

- (void)swizzling_layoutSubviews {
    [self swizzling_layoutSubviews];
    UITextRange *selectedRange = [self markedTextRange];
    UITextPosition *position = [self positionFromPosition:selectedRange.start offset:0];
    if (position || self.text.length || self.attributedText.length) {
        self.placeholderLabel.hidden = YES;
    } else {
        self.placeholderLabel.hidden = NO;
    }
    
    CGFloat lineHeight = self.font ? self.font.lineHeight : 15.f;
    UIEdgeInsets edgeInsets = self.textContainerInset;
    self.placeholderLabel.textAlignment = self.textAlignment;
    self.placeholderLabel.frame = CGRectMake(edgeInsets.left+5, edgeInsets.top, CGRectGetWidth(self.bounds)-(edgeInsets.left+5)*2, lineHeight);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - getter setter
- (NSUInteger)maxLength {
    NSNumber *maxLengthNum = objc_getAssociatedObject(self, KTextViewTextMaxLength);
    if (!maxLengthNum) {
        return NSUIntegerMax;
    }
    return [maxLengthNum unsignedIntegerValue];
}

- (void)setMaxLength:(NSUInteger)maxLength {
    objc_setAssociatedObject(self, KTextViewTextMaxLength, @(maxLength), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)placeholder {
    return objc_getAssociatedObject(self, KTextViewTextPlaceholder);
}

- (void)setPlaceholder:(NSString *)placeholder {
    objc_setAssociatedObject(self, KTextViewTextPlaceholder, placeholder, OBJC_ASSOCIATION_COPY_NONATOMIC);
    self.placeholderLabel.text = self.placeholder;
}

- (UILabel *)placeholderLabel {
    UILabel *placeholderLabel = objc_getAssociatedObject(self, KTextViewTextPlaceholderLabel);
    if (!placeholderLabel) {
        placeholderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        placeholderLabel.backgroundColor = [UIColor clearColor];
        placeholderLabel.opaque = YES;
        placeholderLabel.textColor = self.placeholderColor;
        placeholderLabel.font = self.placeholderFont;
        [self addSubview:placeholderLabel];
        
        placeholderLabel.textAlignment = self.textAlignment;
        [placeholderLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(becomeFirstResponder)]];
        self.placeholderLabel = placeholderLabel;
    }
    return placeholderLabel;
}

- (void)setPlaceholderLabel:(UILabel *)placeholderLabel {
    objc_setAssociatedObject(self, KTextViewTextPlaceholderLabel, placeholderLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIFont *)placeholderFont {
    return objc_getAssociatedObject(self, KTextViewTextPlaceholderFont);
}

- (void)setPlaceholderFont:(UIFont *)placeholderFont {
    objc_setAssociatedObject(self, KTextViewTextPlaceholderFont, placeholderFont, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.placeholderLabel.font = placeholderFont;
}

- (UIColor *)placeholderColor {
    UIColor *placeholderColor = objc_getAssociatedObject(self, KTextViewTextPlaceholderColor);
    if (!placeholderColor) {
        placeholderColor = [UIColor colorWithRed:0 green:0 blue:0.0980392 alpha:0.22];
    }
    return placeholderColor;
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor {
    objc_setAssociatedObject(self, KTextViewTextPlaceholderColor, placeholderColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.placeholderLabel.textColor = placeholderColor;
}

#pragma mark - Private Method
- (void)textView_addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textView_textDidChange:) name:UITextViewTextDidChangeNotification object:self];
}

#pragma mark - Notification Action-Event
- (void)textView_textDidChange:(NSNotification *)notification {
    UITextView *textView = notification.object;
    UITextRange *selectedRange = [textView markedTextRange];
    UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
    NSString *text = textView.text;
    if (self.maxLength != NSUIntegerMax) {
        MYTitleInfo titleInfo = [text getInfoWithMaxLength:self.maxLength];
        if (titleInfo.length > self.maxLength) {
            if (!position) {
                UITextRange *textRange = textView.selectedTextRange;
                textView.text = [textView.text subStringWithMaxLength:self.maxLength];
                textView.selectedTextRange = textRange;
            }
        }
    }
    
    if (position || self.text.length || self.attributedText.length) {
        self.placeholderLabel.hidden = YES;
    } else {
        self.placeholderLabel.hidden = NO;
    }
}

@end
