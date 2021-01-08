//
//  LYSession.m
//  LYChatUI
//
//  Created by luoyuan on 2021/1/8.
//

#import "LYSession.h"

@implementation LYSession

@synthesize sessionId = _sessionId;
@synthesize sessionType = _sessionType;

#pragma mark - Init

- (instancetype)initWithSessionId:(NSString *)sessionId sessionType:(LYSessionType)sessionType {
    self = [super init];
    if (self) {
        _sessionId = sessionId;
        _sessionType = sessionType;
    }
    return self;
}

+ (instancetype)sessionWithSessionId:(NSString *)sessionId sessionType:(LYSessionType)sessionType {
    LYSession *session = [[LYSession alloc] initWithSessionId:sessionId sessionType:sessionType];
    return session;
}

@end
