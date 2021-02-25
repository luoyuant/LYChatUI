//
//  LYSessionMessageModel.m
//  LYChatUI
//
//  Created by luoyuan on 2021/1/2.
//

#import "LYSessionMessageModel.h"
#import "LYChatConfig.h"

@implementation LYSessionMessageModel

#pragma mark - Setter

- (void)setTimestamp:(NSTimeInterval)timestamp {
    _timestamp = timestamp;
    [self didGetTime];
}

- (void)setTime:(NSDate *)time {
    _time = time;
    _timestamp = [_time timeIntervalSince1970] * 1000.0;
    [self didGetTime];
}

- (void)setMessage:(LYChatMessage *)message {
    _message = message;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.layout contentSizeForCellWidth:[UIScreen mainScreen].bounds.size.width model:self];
    });
}

#pragma mark - Getter

- (LYSessionCellLayout *)layout {
    if (!_layout) {
        Class cls = [[LYChatConfig shared].sessionConfig layoutClassForMessage:_message];
        if (cls) {
            _layout = [[cls alloc] init];
        }
    }
    NSAssert(_layout, @"Layout can not be nil");
    [self setupLayout];
    return _layout;
}


#pragma mark - Public Method

/**
 * layout设置
 */
- (void)setupLayout {
    [_layout setupWithMessage:self];
}

/**
 * 获取到时间
 */
- (void)didGetTime {
    
}

@end
