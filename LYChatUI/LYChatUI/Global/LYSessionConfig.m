//
//  LYSessionConfig.m
//  LYChatUI
//
//  Created by luoyuan on 2021/2/25.
//

#import "LYSessionConfig.h"
#import "LYSessionTextCellLayout.h"

@interface LYSessionConfig ()

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSString *> *layoutDict;

@end

@implementation LYSessionConfig

- (instancetype)init {
    if (self = [super init]) {
        _layoutDict = [NSMutableDictionary dictionaryWithDictionary:@{@(LYSessionMessageTypeText) : NSStringFromClass(LYSessionTextCellLayout.class)}];
    }
    return self;
}

- (void)setLayoutClass:(Class)cls forMessageType:(LYSessionMessageType)messageType {
    if (!cls) {
        return;
    }
    _layoutDict[@(messageType)] = NSStringFromClass(cls);
}

- (Class)layoutClassForMessageType:(LYSessionMessageType)messageType {
    NSString *clsName = _layoutDict[@(messageType)];
    if (!clsName) {
        return nil;
    }
    return NSClassFromString(clsName);
}

- (Class)layoutClassForMessage:(LYChatMessage *)message {
    if (!message) {
        return nil;
    }
    NSString *clsName = _layoutDict[@(message.messageType)];
    if (!clsName) {
        return nil;
    }
    return NSClassFromString(clsName);
}

@end
