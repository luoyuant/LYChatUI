//
//  LYSessionCell.h
//  LYChatUI
//
//  Created by luoyuan on 2021/1/2.
//

#import <UIKit/UIKit.h>
#import "LYSessionContentView.h"
#import "LYSessionMessage.h"

NS_ASSUME_NONNULL_BEGIN

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
 * model
 */
@property (nonatomic, strong) LYSessionMessage *model;

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
