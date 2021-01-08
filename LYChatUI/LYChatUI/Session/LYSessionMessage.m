//
//  LYSessionMessage.m
//  LYChatUI
//
//  Created by luoyuan on 2021/1/2.
//

#import "LYSessionMessage.h"
#import "LYChatGlobalConfig.h"

@implementation LYSessionMessage

#pragma mark - Setter

- (void)setTimestamp:(NSTimeInterval)timestamp {
    _timestamp = timestamp;
    [self didGetTime];
}

- (void)setTime:(NSDate *)time {
    _time = time;
    [self didGetTime];
}

- (void)setContentText:(NSString *)contentText {
    _contentText = contentText;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.layout contentSizeForCellWidth:[UIScreen mainScreen].bounds.size.width model:self];
    });
}

#pragma mark - Getter

- (LYSessionCellLayout *)layout {
    if (!_layout) {
        _layout = [LYSessionCellLayout new];
    }
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
