//
//  LYTextAttribute.h
//  LYChatUI
//
//  Created by luoyuan on 2021/2/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN NSString *const LYTextTruncationToken; 

typedef NS_ENUM (NSUInteger, LYTextTruncationType) {
    /// No truncate.
    LYTextTruncationTypeNone   = 0,
    
    /// Truncate at the beginning of the line, leaving the end portion visible.
    LYTextTruncationTypeStart  = 1,
    
    /// Truncate at the end of the line, leaving the start portion visible.
    LYTextTruncationTypeEnd    = 2,
    
    /// Truncate in the middle of the line, leaving both the start and the end portions visible.
    LYTextTruncationTypeMiddle = 3,
};

@interface LYTextHighlight : NSObject

@property (nonatomic, assign) NSRange range;

@property (nullable, nonatomic, copy) NSDictionary<NSString *, id> *attributes;

+ (instancetype)highlightWithAttributes:(nullable NSDictionary<NSString *, id> *)attributes;

+ (instancetype)highlightWithFont:(nullable UIFont *)font;

+ (instancetype)highlightWithTextColor:(nullable UIColor *)textColor;

+ (instancetype)highlightWithFont:(nullable UIFont *)font textColor:(nullable UIColor *)textColor;

@end


@interface NSMutableAttributedString (LYText)

- (void)ly_setAttribute:(NSString *)name value:(id)value range:(NSRange)range;

+ (NSArray<NSString *> *)ly_allDiscontinuousAttributeKeys;

@end

NS_ASSUME_NONNULL_END
