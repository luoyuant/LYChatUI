//
//  LYChatUserModel.h
//  LYChatUI
//
//  Created by luoyuan on 2021/1/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LYChatUserModel : NSObject

/**
 * 用户id
 */
@property (nonatomic, copy) NSString *userId;

/**
 * 昵称
 */
@property (nonatomic, strong) NSString *nickname;

/**
 * 头像
 * 优先使用avatarUrlString
 */
@property (nonatomic, strong) UIImage *avatarImage;

/**
 * 头像url
 * 优先使用avatarUrlString
 */
@property (nonatomic, strong) NSString *avatarUrlString;


- (instancetype)initWithUserId:(NSString *)userId nickname:(NSString *)nickname avatarImage:(UIImage * _Nullable)avatarImage;

+ (instancetype)userWithUserId:(NSString *)userId nickname:(NSString *)nickname avatarImage:(UIImage * _Nullable)avatarImage;

@end

NS_ASSUME_NONNULL_END
