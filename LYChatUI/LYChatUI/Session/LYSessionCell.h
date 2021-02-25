//
//  LYSessionCell.h
//  LYChatUI
//
//  Created by luoyuan on 2021/1/2.
//

#import <UIKit/UIKit.h>
#import "LYSessionContentView.h"
#import "LYSessionMessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol LYSessionCellDelegate <NSObject>

@required

/**
 * 头像获取
 */
- (void)avatarImageView:(UIImageView *)avatarImageView imageForMessage:(LYSessionMessageModel *)message;

@optional

/**
 * 点击了头像
 */
- (void)didTapAvatar:(UIImageView *)avatarImageView message:(LYSessionMessageModel *)message;

@end

@interface LYSessionCell : UITableViewCell

/**
 * 头像
 */
@property (nonatomic, strong) UIImageView *avatarImageView;

/**
 * 头像圆角layer
 */
@property (nonatomic, strong) CAShapeLayer *avatarMaskLayer;

/**
 * 昵称
 */
@property (nonatomic, strong) UILabel *nicknameLabel;

/**
 * 内容区域
 */
@property (nonatomic, strong) LYSessionContentView *sessionContentView;

/**
 * 消息
 */
@property (nonatomic, strong) LYSessionMessageModel *message;


@property (nonatomic, weak) id<LYSessionCellDelegate> delegate;

/**
 * 更新布局
 */
- (void)updateLayout;

/**
 * 数据刷新
 */
- (void)refresh;

@end

NS_ASSUME_NONNULL_END
