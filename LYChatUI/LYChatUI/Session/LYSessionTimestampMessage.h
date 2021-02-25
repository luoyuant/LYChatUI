//
//  LYSessionTimestampMessage.h
//  LYChatUI
//
//  Created by luoyuan on 2021/1/8.
//

#import <Foundation/Foundation.h>
#import "LYSessionMessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LYSessionTimestampMessage : LYSessionMessageModel

/**
 * 时间文本
 */
@property (nonatomic, strong) NSString *timestampText;

@end

NS_ASSUME_NONNULL_END
