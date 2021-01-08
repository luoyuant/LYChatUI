//
//  LYChatGlobalColorConfig.h
//  LYChatUI
//
//  Created by luoyuan on 2021/1/5.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LYChatGlobalColorConfig : NSObject

/**
 * 时间戳文字颜色
 */
@property (nonatomic, strong) UIColor *timestampTextColor;

/**
 * 下拉加载标题颜色
 */
@property (nonatomic, strong) UIColor *refreshControlTitleColor;

/**
 * 昵称文字颜色
 */
@property (nonatomic, strong) UIColor *nicknameTextColor;

/**
 * 内容文字颜色
 */
@property (nonatomic, strong) UIColor *contentTextColor;

/**
 * 聊天页面背景颜色
 */
@property (nonatomic, strong) UIColor *sessionBackgroundColor;

/**
 * 左侧气泡背景颜色
 */
@property (nonatomic, strong) UIColor *leftSessionContentColor;

/**
 * 右侧气泡背景颜色
 */
@property (nonatomic, strong) UIColor *rightSessionContentColor;

@end


@interface UIColor (LYChat)

+ (instancetype)colorWithHex:(NSInteger)hexValue;

+ (instancetype)colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alpha;

+ (instancetype)colorWithHexUserInterfaceStyleLight:(NSInteger)lightHexValue dark:(NSInteger)darkHexValue;

@end

NS_ASSUME_NONNULL_END
