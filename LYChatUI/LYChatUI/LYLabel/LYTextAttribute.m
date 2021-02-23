//
//  LYTextAttribute.m
//  LYChatUI
//
//  Created by luoyuan on 2021/2/20.
//

#import "LYTextAttribute.h"
#import <CoreText/CTStringAttributes.h>

NSString *const LYTextTruncationToken = @"\u2026";

@implementation LYTextHighlight

- (void)setAttributes:(NSDictionary *)attributes {
    _attributes = attributes.mutableCopy;
}

+ (instancetype)highlightWithAttributes:(NSDictionary *)attributes {
    LYTextHighlight *one = [self new];
    one.attributes = attributes;
    return one;
}

+ (instancetype)highlightWithFont:(nullable UIFont *)font {
    LYTextHighlight *one = [LYTextHighlight highlightWithFont:font textColor:nil];
    return one;
}

+ (instancetype)highlightWithTextColor:(nullable UIColor *)textColor {
    LYTextHighlight *one = [LYTextHighlight highlightWithFont:nil textColor:textColor];
    return one;
}

+ (instancetype)highlightWithFont:(nullable UIFont *)font textColor:(nullable UIColor *)textColor {
    LYTextHighlight *one = [self new];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    if (!(font == (id)[NSNull null] || font == nil)) {
        attributes[NSFontAttributeName] = font;
    }
    
    if (!(textColor == (id)[NSNull null] || textColor == nil)) {
        attributes[NSForegroundColorAttributeName] = textColor;
    }
    
    one.attributes = attributes.copy;
    return one;
}

@end



@implementation NSMutableAttributedString (LYText)

- (void)ly_setAttribute:(NSString *)name value:(id)value range:(NSRange)range {
    if (!name || [NSNull isEqual:name]) return;
    if (value && ![NSNull isEqual:value]) {
        [self addAttribute:name value:value range:range];
    } else {
        [self removeAttribute:name range:range];
    }
}


+ (NSArray *)ly_allDiscontinuousAttributeKeys {
    static NSMutableArray *keys;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keys = @[(id)kCTSuperscriptAttributeName,
                 (id)kCTRunDelegateAttributeName].mutableCopy;
        
        [keys addObject:(id)kCTRubyAnnotationAttributeName];
        [keys addObject:NSAttachmentAttributeName];
    });
    return keys;
}

@end
