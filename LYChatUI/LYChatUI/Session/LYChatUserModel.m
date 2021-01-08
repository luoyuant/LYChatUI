//
//  LYChatUserModel.m
//  LYChatUI
//
//  Created by luoyuan on 2021/1/8.
//

#import "LYChatUserModel.h"

@implementation LYChatUserModel

- (instancetype)initWithUserId:(NSString *)userId nickname:(NSString *)nickname avatarImage:(UIImage *)avatarImage {
    self = [super init];
    if (self) {
        _userId = userId;
        _nickname = nickname;
        _avatarImage = avatarImage;
    }
    return self;
}

+ (instancetype)userWithUserId:(NSString *)userId nickname:(NSString *)nickname avatarImage:(UIImage *)avatarImage {
    LYChatUserModel *user = [[LYChatUserModel alloc] initWithUserId:userId nickname:nickname avatarImage:avatarImage];
    return user;
}

@end
