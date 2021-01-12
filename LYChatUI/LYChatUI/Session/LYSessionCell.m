//
//  LYSessionCell.m
//  LYChatUI
//
//  Created by luoyuan on 2021/1/2.
//

#import "LYSessionCell.h"
#import "LYChatConfig.h"
#import "LYChatConst.h"

@interface LYSessionCell ()

/**
 * 头像圆角
 */
@property (nonatomic, assign) CGFloat avatarCornerRadius;

@property (nonatomic, weak) LYSessionCellLayout *layout;

@end

@implementation LYSessionCell

#pragma mark - Setter

- (void)setMessage:(LYSessionMessage *)message {
    BOOL shouldUpdate = _message != message;
    _message = message;
    _sessionContentView.model = message;
    if (shouldUpdate) {
        [self refresh];
        [self setNeedsLayout];
    }
}

#pragma mark - Getter

- (LYSessionCellLayout *)layout {
    if ([_message.layout isKindOfClass:[LYSessionCellLayout class]]) {
        _layout = _message.layout;
    }
    return _layout;
}

#pragma mark - Init

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _avatarImageView = [UIImageView new];
        _avatarImageView.layer.masksToBounds = true;
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarImageView.clipsToBounds = true;
        [self.contentView addSubview:_avatarImageView];
        
        _nicknameLabel = [UILabel new];
        _nicknameLabel.hidden = true;
        [self.contentView addSubview:_nicknameLabel];
        
        _sessionContentView = [[LYSessionContentView alloc] initWithFrame:self.contentView.bounds];
        [self.contentView addSubview:_sessionContentView];
        
    }
    return self;
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self updateLayout];
}

/**
 * 更新布局
 */
- (void)updateLayout {
    LYSessionCellLayoutType layoutType = self.layout.layoutType;
    if (layoutType == LYSessionCellLayoutTypeAuto) {
        return;
    }
    [self layoutAvatar];
    
    [self layoutNickname];
    
    [self layoutSessionContentView];
}

/**
 * 头像布局
 */
- (void)layoutAvatar {
    LYSessionCellLayoutType layoutType = self.layout.layoutType;

    CGPoint avatarMargin = self.layout.avatarMargin;
    CGSize avatarSize = self.layout.avatarSize;
    
    CGFloat x = layoutType == LYSessionCellLayoutTypeLeft ? avatarMargin.x : self.contentView.bounds.size.width - avatarMargin.x - avatarSize.width;
    _avatarImageView.frame = CGRectMake(x, avatarMargin.y, avatarSize.width, avatarSize.height);
    
    [self drawAvatarMaskLayer];
    
}

- (void)drawAvatarMaskLayer {
    if (self.layout.avatarCornerRadius <= 0) {
        return;
    }
    if (!_avatarMaskLayer) {
        _avatarMaskLayer = [CAShapeLayer layer];
    }
    if (_avatarCornerRadius != self.layout.avatarCornerRadius) {
        _avatarCornerRadius = self.layout.avatarCornerRadius;
        CGSize size = self.layout.avatarSize;
        UIBezierPath *path = [UIBezierPath bezierPath];
        CGPoint aPoint = CGPointMake(_avatarCornerRadius, 0);
        [path moveToPoint:aPoint];

        CGPoint bPoint = CGPointMake(size.width - _avatarCornerRadius, 0);
        [path addLineToPoint:bPoint];
        
        [path addArcWithCenter:CGPointMake(bPoint.x, bPoint.y + _avatarCornerRadius) radius:_avatarCornerRadius startAngle:1.5 * M_PI endAngle:2 * M_PI clockwise:true];
        
        CGPoint cPoint = CGPointMake(size.width, size.height - _avatarCornerRadius);
        [path addLineToPoint:cPoint];
        
        [path addArcWithCenter:CGPointMake(cPoint.x - _avatarCornerRadius, cPoint.y) radius:_avatarCornerRadius startAngle:0 endAngle:0.5 * M_PI clockwise:true];
        
        CGPoint dPoint = CGPointMake(_avatarCornerRadius, size.height);
        [path addLineToPoint:dPoint];
        
        [path addArcWithCenter:CGPointMake(dPoint.x, dPoint.y - _avatarCornerRadius) radius:_avatarCornerRadius startAngle:0.5 * M_PI endAngle:M_PI clockwise:true];
        
        CGPoint ePoint = CGPointMake(0, _avatarCornerRadius);
        [path addLineToPoint:ePoint];
        
        [path addArcWithCenter:CGPointMake(ePoint.x + _avatarCornerRadius, ePoint.y) radius:_avatarCornerRadius startAngle:M_PI endAngle:1.5 * M_PI clockwise:true];
        
        _avatarMaskLayer.path = path.CGPath;
        _avatarImageView.layer.mask = _avatarMaskLayer;
    }
}

/**
 * 昵称布局
 */
- (void)layoutNickname {
    LYSessionCellLayoutType layoutType = self.layout.layoutType;
    if (!self.layout.showNickname) {
        _nicknameLabel.hidden = true;
        return;
    }
    _nicknameLabel.hidden = false;
    BOOL onLeft = layoutType == LYSessionCellLayoutTypeLeft;
    CGPoint margin = self.layout.nicknameMargin;
    CGFloat width = self.layout.contentMaxWidth - self.layout.contentTriangleWidth;
    CGFloat x = onLeft ? CGRectGetMaxX(self.avatarImageView.frame) + margin.x : self.avatarImageView.frame.origin.x - margin.x - width;
    [_nicknameLabel sizeToFit];
    _nicknameLabel.frame = CGRectMake(x, margin.y, width, _nicknameLabel.bounds.size.height);
}

/**
 * 气泡布局
 */
- (void)layoutSessionContentView {
    LYSessionCellLayoutType layoutType = self.layout.layoutType;
    
    BOOL onLeft = layoutType == LYSessionCellLayoutTypeLeft;
    UIEdgeInsets margin = self.message.layout.contentMargin;
    CGSize size = [self.message.layout contentSizeForCellWidth:self.contentView.bounds.size.width model:_message];
    CGFloat x = onLeft ? CGRectGetMaxX(self.avatarImageView.frame) + margin.left : self.avatarImageView.frame.origin.x - margin.left - size.width;
    CGFloat y = self.layout.showNickname ? (CGRectGetMaxY(_nicknameLabel.frame) + 2) : margin.top;
    _sessionContentView.frame = CGRectMake(x, y, size.width, size.height);
    _sessionContentView.backgroundColor = onLeft ? _message.config.colorConfig.leftSessionContentColor : _message.config.colorConfig.rightSessionContentColor;
}

#pragma mark - Refresh

/**
 * 数据刷新
 */
- (void)refresh {
    BOOL onLeft = self.layout.layoutType == LYSessionCellLayoutTypeLeft;
    _nicknameLabel.text = _message.user.nickname;
    _nicknameLabel.textAlignment = onLeft ? NSTextAlignmentLeft : NSTextAlignmentRight;
    
    _nicknameLabel.font = _message.config.fontConfig.nicknameFont;
    _nicknameLabel.textColor = _message.config.colorConfig.nicknameTextColor;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(avatarImageView:imageForMessage:)]) {
        [self.delegate avatarImageView:_avatarImageView imageForMessage:_message];
    }
    
}


@end
