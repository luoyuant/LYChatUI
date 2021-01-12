//
//  LYSessionTimestampMessage.m
//  LYChatUI
//
//  Created by luoyuan on 2021/1/8.
//

#import "LYSessionTimestampMessage.h"
#import "LYSessionTimestampCellLayout.h"
#import "LYChatGlobalConfig.h"

@implementation LYSessionTimestampMessage

#pragma mark - Init

- (instancetype)init {
    self = [super init];
    if (self) {
        self.layout = [LYSessionTimestampCellLayout new];
    }
    return self;
}

- (void)didGetTime {
    [super didGetTime];
    if (self.timestamp > 0) {
        self.timestampText = [[LYChatGlobalConfig shared] sessionTimeTextWithTimestamp:self.timestamp];
    } else {
        self.timestampText = [[LYChatGlobalConfig shared] sessionTimeTextWithDate:self.time];
    }
}

@end
