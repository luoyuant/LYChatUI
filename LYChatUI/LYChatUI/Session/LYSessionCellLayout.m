//
//  LYSessionCellLayout.m
//  LYChatUI
//
//  Created by luoyuan on 2021/1/2.
//

#import "LYSessionCellLayout.h"
#import "LYChatConfig.h"
#import "LYSessionCell.h"
#import "LYChatConst.h"
#import "LYTextLayout.h"

@interface LYSessionCellLayout ()


@end


@implementation LYSessionCellLayout

#pragma mark - Init

- (instancetype)init {
    self = [super init];
    if (self) {
        _showNickname = true;
        _avatarCornerRadius = 5;
    }
    return self;
}

#pragma mark - Getter

- (NSMutableDictionary<NSNumber *, NSValue *> *)contentSizeJson {
    if (!_contentSizeJson) {
        _contentSizeJson = [NSMutableDictionary dictionary];
    }
    return _contentSizeJson;
}

/**
 * cell的类
 */
- (Class)cellClass {
    if (!_cellClass) {
        _cellClass = [LYSessionCell class];
    }
    return _cellClass;
}

- (Class)contentViewClass {
    return nil;
}

/**
 * 头像偏移
 */
- (CGPoint)avatarMargin {
    if (CGPointEqualToPoint(_avatarMargin, CGPointZero)) {
        _avatarMargin = CGPointMake(12, 6);
    }
    return _avatarMargin;
}

/**
 * 头像大小
 */
- (CGSize)avatarSize {
    if (CGSizeEqualToSize(_avatarSize, CGSizeZero)) {
        _avatarSize = CGSizeMake(40, 40);
    }
    return _avatarSize;
}

/**
 * 昵称偏移
 */
- (CGPoint)nicknameMargin {
    if (CGPointEqualToPoint(_nicknameMargin, CGPointZero)) {
        _nicknameMargin = CGPointMake(13, 3);
    }
    return _nicknameMargin;
}

/**
 * 内容区域偏移
 * 水平方向无论居左居右均算left
 */
- (UIEdgeInsets)contentMargin {
    if (UIEdgeInsetsEqualToEdgeInsets(_contentMargin, UIEdgeInsetsZero)) {
        _contentMargin = UIEdgeInsetsMake(6, 8, 6, 0);
    }
    return _contentMargin;
}

/**
 * 内容内边距
 */
- (UIEdgeInsets)contentPadding {
    if (UIEdgeInsetsEqualToEdgeInsets(_contentPadding, UIEdgeInsetsZero)) {
        _contentPadding = UIEdgeInsetsMake(10, 12, 10, 12);
    }
    return _contentPadding;
}

/**
 * 内容区域 三角形占用宽度
 */
- (CGFloat)contentTriangleWidth {
    if (_contentTriangleWidth <= 0) {
        _contentTriangleWidth = 5;
    }
    return _contentTriangleWidth;;
}

/**
 * 内容区域最大宽度
 */
- (CGFloat)contentMaxWidth {
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    _contentMaxWidth = width - self.avatarMargin.x - self.avatarSize.width - self.contentMargin.left - 61;
    return _contentMaxWidth;
}

#pragma mark - Public Method

/**
 * 内容区域大小
 */
- (CGSize)contentSizeForCellWidth:(CGFloat)cellWidth model:(LYSessionMessageModel *)model {
    if (cellWidth <= 0) {
        return CGSizeZero;
    }
    CGSize contentSize = [self.contentSizeJson[@(cellWidth)] CGSizeValue];
    if (CGSizeEqualToSize(contentSize, CGSizeZero)) {
        UIEdgeInsets padding = self.contentPadding;
        CGFloat widthOffset = self.contentTriangleWidth + padding.left + padding.right;
        CGFloat minHeight = self.avatarSize.height;
        CGFloat maxWidth = self.contentMaxWidth - widthOffset;
        
        CGFloat width = maxWidth;
        CGFloat height = minHeight;
        contentSize = CGSizeMake(width, height);
        self.contentSizeJson[@(cellWidth)] = [NSValue valueWithCGSize:contentSize];
    }
    return contentSize;
}


/**
 * cell高度
 */
- (CGFloat)cellHeightForCellWidth:(CGFloat)cellWidth model:(LYSessionMessageModel *)model {
    UIEdgeInsets margin = self.contentMargin;
    CGFloat topMargin = _showNickname ? 25 : margin.top;
    CGFloat height = [self contentSizeForCellWidth:cellWidth model:model].height + topMargin + margin.bottom;
    return height;
}

- (void)setupWithMessage:(LYSessionMessageModel *)messageModel {
    LYSession *session = messageModel.message.session;
    LYChatUserModel *user = messageModel.message.user;
    if (!session) {
        LYDLog(@"session为NULL");
    }
    if (!user) {
        LYDLog(@"user为NULL");
    }
    BOOL isSelf = [user.userId isEqualToString:[LYChatConfig shared].currentUser.userId];
    self.showNickname = session.sessionType != LYSessionTypeP2P && (session.showNickname && !isSelf);
    self.layoutType = isSelf ? LYSessionCellLayoutTypeRight : LYSessionCellLayoutTypeLeft;
}

@end
