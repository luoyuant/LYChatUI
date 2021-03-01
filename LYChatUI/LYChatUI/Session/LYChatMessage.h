//
//  LYChatMessage.h
//  LYChatUI
//
//  Created by luoyuan on 2021/2/25.
//

#import <Foundation/Foundation.h>
#import "LYSession.h"
#import "LYChatUserModel.h"

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

@interface LYChatMessage : NSObject

/**
 * 会话对象
 */
@property (nonatomic, strong) LYSession *session;

/**
 * 消息类型
 */
@property (nonatomic, assign) LYSessionMessageType messageType;

/**
 * 用户信息
 */
@property (nonatomic, strong) LYChatUserModel *user;

/**
 * 内容
 */
@property (nonatomic, strong) NSString *text;

/**
 * 附件
 */
@property (nonatomic, strong) id attachment;


@end

NS_ASSUME_NONNULL_END
