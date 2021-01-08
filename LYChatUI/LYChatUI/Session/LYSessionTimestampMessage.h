//
//  LYSessionTimestampMessage.h
//  LYChatUI
//
//  Created by luoyuan on 2021/1/8.
//

#import <Foundation/Foundation.h>
#import "LYSessionMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface LYSessionTimestampMessage : LYSessionMessage

/**
 * 时间文本
 */
@property (nonatomic, strong) NSString *timestampText;

@end

NS_ASSUME_NONNULL_END
