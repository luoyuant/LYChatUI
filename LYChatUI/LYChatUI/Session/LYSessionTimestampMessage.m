//
//  LYSessionTimestampMessage.m
//  LYChatUI
//
//  Created by luoyuan on 2021/1/8.
//

#import "LYSessionTimestampMessage.h"
#import "LYSessionTimestampCellLayout.h"
#import "LYChatConfig.h"

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
        self.timestampText = [self.config sessionTimeTextWithTimestamp:self.timestamp];
    } else {
        self.timestampText = [self.config sessionTimeTextWithDate:self.time];
    }
}

@end
