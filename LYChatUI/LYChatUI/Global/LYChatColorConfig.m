//
//  LYChatColorConfig.m
//  LYChatUI
//
//  Created by luoyuan on 2021/1/5.
//

#import "LYChatColorConfig.h"

@implementation LYChatColorConfig

#pragma mark - Getter

/**
 * 时间戳文字颜色
 */
- (UIColor *)timestampTextColor {
    if (!_timestampTextColor) {
        _timestampTextColor = [UIColor colorWithHexUserInterfaceStyleLight:0xafafaf dark:0x4a4a4a];
    }
    return _timestampTextColor;
}

/**
 * 下拉加载标题颜色
 */
- (UIColor *)refreshControlTitleColor {
    if (!_refreshControlTitleColor) {
        _refreshControlTitleColor = [UIColor colorWithHexUserInterfaceStyleLight:0x7a7a7a dark:0x555555];
    }
    return _refreshControlTitleColor;
}

/**
 * 昵称文字颜色
 */
- (UIColor *)nicknameTextColor {
    if (!_nicknameTextColor) {
        _nicknameTextColor = [UIColor colorWithHexUserInterfaceStyleLight:0x7a7a7a dark:0x555555];
    }
    return _nicknameTextColor;
}

/**
 * 内容文字颜色
 */
- (UIColor *)contentTextColor {
    if (!_contentTextColor) {
        _contentTextColor = [UIColor colorWithHexUserInterfaceStyleLight:0x222222 dark:0xd1d1d1];
    }
    return _contentTextColor;
}

/**
 * 聊天页面背景颜色
 */
- (UIColor *)sessionBackgroundColor {
    if (!_sessionBackgroundColor) {
        _sessionBackgroundColor = [UIColor colorWithHexUserInterfaceStyleLight:0xededed dark:0x111111];
    }
    return _sessionBackgroundColor;
}

/**
 * 左侧气泡背景颜色
 */
- (UIColor *)leftSessionContentColor {
    if (!_leftSessionContentColor) {
        _leftSessionContentColor = [UIColor colorWithHexUserInterfaceStyleLight:0xffffff dark:0x2c2c2c];
    }
    return _leftSessionContentColor;
}

/**
 * 右侧气泡背景颜色
 */
- (UIColor *)rightSessionContentColor {
    if (!_rightSessionContentColor) {
        _rightSessionContentColor = [UIColor colorWithHexUserInterfaceStyleLight:0x94ec68 dark:0x34b561];
    }
    return _rightSessionContentColor;
}

@end


@implementation UIColor (LYChat)

+ (instancetype)colorWithHex:(NSInteger)hexValue {
    return [UIColor colorWithHex:hexValue alpha:1];
}

+ (instancetype)colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:((CGFloat)((hexValue & 0xFF0000) >> 16)) / 255.0
                           green:((CGFloat)((hexValue & 0x00FF00) >> 8)) / 255.0
                            blue:((CGFloat)(hexValue & 0x0000FF)) / 255.0
                           alpha:alpha];
}

+ (instancetype)colorWithHexUserInterfaceStyleLight:(NSInteger)lightHexValue dark:(NSInteger)darkHexValue {
    UIColor *color;
    if (@available(iOS 13.0, *)) {
        color = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return [UIColor colorWithHex:darkHexValue];
            } else {
                return [UIColor colorWithHex:lightHexValue];
            }
        }];
    } else {
        color = [UIColor colorWithHex:lightHexValue];
    }
    return color;
}

@end
