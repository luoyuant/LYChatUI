//
//  LYChatFontConfig.h
//  LYChatUI
//
//  Created by luoyuan on 2021/1/6.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LYChatFontConfig : NSObject

/**
 * 时间戳字体
 */
@property (nonatomic, strong) UIFont *timestampFont;

/**
 * 下拉加载标题字体
 */
@property (nonatomic, strong) UIFont *refreshControlTitleFont;

/**
 * 昵称字体
 */
@property (nonatomic, strong) UIFont *nicknameFont;

/**
 * 内容文字字体
 */
@property (nonatomic, strong) UIFont *contentFont;

@end

NS_ASSUME_NONNULL_END
