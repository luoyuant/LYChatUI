//
//  LYSessionCellLayout.h
//  LYChatUI
//
//  Created by luoyuan on 2021/1/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LYSessionMessage;

typedef NS_ENUM(NSInteger, LYSessionCellLayoutType) {
    LYSessionCellLayoutTypeAuto  = 0, //自动布局
    LYSessionCellLayoutTypeLeft  = 1, //居左
    LYSessionCellLayoutTypeRight = 2, //居右
};


@interface LYSessionCellLayout : NSObject

/**
 * cell的类
 */
@property (nonatomic, assign) Class cellClass;

/**
 * 布局类型（居左、居右）
 */
@property (nonatomic, assign) LYSessionCellLayoutType layoutType;

/**
 * 头像偏移
 */
@property (nonatomic, assign) CGPoint avatarMargin;

/**
 * 头像大小
 */
@property (nonatomic, assign) CGSize avatarSize;

/**
 * 头像圆角
 */
@property (nonatomic, assign) CGFloat avatarCornerRadius;

/**
 * 是否显示昵称
 */
@property (nonatomic, assign) BOOL showNickname;

/**
 * 昵称偏移
 */
@property (nonatomic, assign) CGPoint nicknameMargin;

/**
 * 内容区域偏移
 * 水平方向无论居左居右均算left
 */
@property (nonatomic, assign) UIEdgeInsets contentMargin;

/**
 * label 边距
 */
@property (nonatomic, assign) UIEdgeInsets contentLabelInsets;

/**
 * 内容内边距
 */
@property (nonatomic, assign) UIEdgeInsets contentPadding;

/**
 * 内容区域 三角形占用宽度
 */
@property (nonatomic, assign) CGFloat contentTriangleWidth;

/**
 * 内容区域最大宽度
 */
@property (nonatomic, assign) CGFloat contentMaxWidth;

/**
 * 内容区域大小
 */
- (CGSize)contentSizeForCellWidth:(CGFloat)cellWidth model:(LYSessionMessage *)model;

/**
 * cell高度
 */
- (CGFloat)cellHeightForCellWidth:(CGFloat)cellWidth model:(LYSessionMessage *)model;


- (void)setupWithMessage:(LYSessionMessage *)message;

@end

NS_ASSUME_NONNULL_END
