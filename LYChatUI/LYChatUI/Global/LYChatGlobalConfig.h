//
//  LYChatGlobalConfig.h
//  LYChatUI
//
//  Created by luoyuan on 2021/1/5.
//

#import <Foundation/Foundation.h>
#import "LYChatUserModel.h"
#import "LYChatGlobalColorConfig.h"
#import "LYChatGlobalFontConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface LYChatGlobalConfig : NSObject

+ (instancetype)shared;

/**
 * 当前登录用户
 */
@property (nonatomic, strong) LYChatUserModel *currentUser;

/**
 * 颜色
 */
@property (nonatomic, strong) LYChatGlobalColorConfig *colorConfig;

/**
 * 字体
 */
@property (nonatomic, strong) LYChatGlobalFontConfig *fontConfig;

/**
 * 相隔多久显示一条时间戳(精确到毫秒)
 * 默认一分钟
 */
@property (nonatomic, assign) NSTimeInterval showTimestampWithTimeInterval;

/**
 * 时间戳(精确到毫秒) 转为显示时间
 */
- (NSString *)sessionTimeTextWithTimestamp:(NSTimeInterval)timestamp;

/**
 * 时间date 转为显示时间
 */
- (NSString *)sessionTimeTextWithDate:(NSDate *)date;



@end

NS_ASSUME_NONNULL_END
