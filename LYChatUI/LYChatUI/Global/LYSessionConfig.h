//
//  LYSessionConfig.h
//  LYChatUI
//
//  Created by luoyuan on 2021/2/25.
//

#import <Foundation/Foundation.h>
#import "LYSessionCellLayout.h"
#import "LYChatMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface LYSessionConfig : NSObject

- (void)setLayoutClass:(Class)cls forMessageType:(LYSessionMessageType)messageType;

- (Class)layoutClassForMessageType:(LYSessionMessageType)messageType;

- (Class)layoutClassForMessage:(LYChatMessage *)message;

@end

NS_ASSUME_NONNULL_END
