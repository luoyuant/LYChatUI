//
//  LYChatFontConfig.m
//  LYChatUI
//
//  Created by luoyuan on 2021/1/6.
//

#import "LYChatFontConfig.h"

@implementation LYChatFontConfig

#pragma mark - Getter

/**
 * 时间戳字体
 */
- (UIFont *)timestampFont {
    if (!_timestampFont) {
        _timestampFont = [UIFont systemFontOfSize:14];
    }
    return _timestampFont;
}

/**
 * 下拉加载标题字体
 */
- (UIFont *)refreshControlTitleFont {
    if (!_refreshControlTitleFont) {
        _refreshControlTitleFont = [UIFont systemFontOfSize:14];
    }
    return _refreshControlTitleFont;
}

/**
 * 昵称字体
 */
- (UIFont *)nicknameFont {
    if (!_nicknameFont) {
        _nicknameFont = [UIFont systemFontOfSize:12];
    }
    return _nicknameFont;
}

/**
 * 内容文字字体
 */
- (UIFont *)contentFont {
    if (!_contentFont) {
        _contentFont = [UIFont systemFontOfSize:16];
    }
    return _contentFont;
}

@end
