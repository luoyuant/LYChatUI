//
//  LYSessionMessageModel.h
//  LYChatUI
//
//  Created by luoyuan on 2021/1/2.
//

#import <Foundation/Foundation.h>
#import "LYSessionCellLayout.h"
#import "LYChatConfig.h"
#import "LYChatMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface LYSessionMessageModel : NSObject

/**
 * 消息
 */
@property (nonatomic, strong) LYChatMessage *message;

/**
 * 布局
 */
@property (nonatomic, strong) LYSessionCellLayout *layout;

/**
 * 设置
 */
@property (nonatomic, weak) LYChatConfig *config;

/**
 * 时间戳(精确到毫秒)
 * timestamp和time二选一
 */
@property (nonatomic, assign) NSTimeInterval timestamp;

/**
 * 时间
 * timestamp和time二选一
 */
@property (nonatomic, strong) NSDate *time;

/**
 * layout设置
 */
- (void)setupLayout;

/**
 * 获取到时间
 */
- (void)didGetTime;

@end

NS_ASSUME_NONNULL_END
