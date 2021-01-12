//
//  LYSessionMessage.h
//  LYChatUI
//
//  Created by luoyuan on 2021/1/2.
//

#import <Foundation/Foundation.h>
#import "LYSession.h"
#import "LYSessionCellLayout.h"
#import "LYChatUserModel.h"
#import "LYChatConfig.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, LYSessionMessageType) {
    /**
     * 文本消息
     */
    LYSessionMessageTypeText = 0,
    
    /**
     * 图片消息
     */
    LYSessionMessageTypeImage = 1,
    
    /**
     * 音频消息
     */
    LYSessionMessageTypeAudio = 2,
    
    /**
     * 视频消息
     */
    LYSessionMessageTypeVideo = 3,
    
    
};

@interface LYSessionMessage : NSObject

/**
 * 会话对象
 */
@property (nonatomic, strong) LYSession *session;

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
 * 用户信息
 */
@property (nonatomic, strong) LYChatUserModel *user;

/**
 * 内容
 */
@property (nonatomic, strong) NSString *contentText;

/**
 * 自定义消息
 */
@property (nonatomic, strong) id message;

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
