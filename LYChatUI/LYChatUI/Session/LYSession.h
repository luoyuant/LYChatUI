//
//  LYSession.h
//  LYChatUI
//
//  Created by luoyuan on 2021/1/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, LYSessionType) {
    /**
     * 一对一
     */
    LYSessionTypeP2P   = 0,
    
    /**
     * 群聊
     */
    LYSessionTypeGroup = 1,
};

@interface LYSession : NSObject

/**
 * 会话id
 */
@property (nonatomic, copy, readonly) NSString *sessionId;

/**
 * 会话类型
 */
@property (nonatomic, assign, readonly) LYSessionType sessionType;

/**
 * 是否显示昵称
 */
@property (nonatomic, assign) BOOL showNickname;



- (instancetype)initWithSessionId:(NSString *)sessionId sessionType:(LYSessionType)sessionType;

+ (instancetype)sessionWithSessionId:(NSString *)sessionId sessionType:(LYSessionType)sessionType;

@end

NS_ASSUME_NONNULL_END
