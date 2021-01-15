//
//  LYSessionContentView.m
//  LYChatUI
//
//  Created by luoyuan on 2021/1/4.
//

#import "LYSessionContentView.h"
#import "LYChatConfig.h"

@interface LYSessionContentView ()

@end

@implementation LYSessionContentView

#pragma mark - Setter

- (void)setModel:(LYSessionMessage *)model {
    BOOL shouldUpdate = _model != model;
    _model = model;
    if (shouldUpdate) {
        [self updateContentMask];
        [self refresh];
        [self setNeedsLayout];
    }
}

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _contentView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:_contentView];
        
        _contentLabel = [UILabel new];
        _contentLabel.numberOfLines = 0;
        _contentLabel.adjustsFontSizeToFitWidth = true;
        [_contentView addSubview:_contentLabel];
        
    }
    return self;
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self updateContentMask];
    
    [self layoutContentView];
    
    [self layoutContentLabel];
}

- (void)layoutContentView {
    if ([_model.layout isKindOfClass:[LYSessionCellLayout class]]) {
        LYSessionCellLayout *layout = _model.layout;
        CGSize size = self.bounds.size;
        BOOL onLeft = layout.layoutType == LYSessionCellLayoutTypeLeft;
        CGFloat leftMargin = onLeft ? layout.contentTriangleWidth : 0;
        _contentView.frame = CGRectMake(leftMargin, 0, size.width - layout.contentTriangleWidth, size.height);
    }
}

- (void)layoutContentLabel {
    if ([_model.layout isKindOfClass:[LYSessionCellLayout class]]) {
        LYSessionCellLayout *layout = _model.layout;
        UIEdgeInsets padding = layout.contentPadding;
        CGSize size = self.contentView.bounds.size;
        _contentLabel.frame = CGRectMake(padding.left, padding.top, size.width - padding.left - padding.right, size.height - padding.top - padding.bottom);
    }
}

#pragma mark - Update Mask

/**
 * 更新内容区域遮罩
 */
- (void)updateContentMask {
    if ([_model.layout isKindOfClass:[LYSessionCellLayout class]]) {
        LYSessionCellLayout *layout = _model.layout;
        CGSize size = self.bounds.size;
        if ((size.width == 0 || size.height == 0) || layout.contentTriangleWidth == 0) {
            return;
        }
        
        [self updateContentMaskLayer];
    }
}

/**
 * 更新遮罩Layer
 */
- (void)updateContentMaskLayer {
    LYSessionCellLayout *layout;
    if ([_model.layout isKindOfClass:[LYSessionCellLayout class]]) {
        layout = _model.layout;
    }
    if (!layout) {
        return;
    }
    
    if (!_contentMaskLayer) {
        _contentMaskLayer = [CAShapeLayer layer];
    }
    CGSize size = self.bounds.size;
    CGFloat padding = layout.contentTriangleWidth;
    CGFloat cornerRadius = 4;
    CGFloat triangleTopOffset = 14;
    CGFloat triangleHeight = 10; //三角垂直方向边长
    BOOL onLeft = layout.layoutType == LYSessionCellLayoutTypeLeft;
    
    //绘制居右maskLayer
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGPoint aPoint = CGPointMake(cornerRadius, 0);
    [path moveToPoint:aPoint];

    CGPoint bPoint = CGPointMake(size.width - padding - cornerRadius, 0);
    [path addLineToPoint:bPoint];
    
    if (cornerRadius > 0) {
        [path addArcWithCenter:CGPointMake(bPoint.x, bPoint.y + cornerRadius) radius:cornerRadius startAngle:1.5 * M_PI endAngle:2 * M_PI clockwise:true];
    }
    
    CGPoint cPoint = CGPointMake(size.width - padding, triangleTopOffset);
    [path addLineToPoint:cPoint];
    
    CGPoint dPoint = CGPointMake(size.width, cPoint.y + triangleHeight / 2);
    [path addLineToPoint:dPoint];
    
    CGPoint ePoint = CGPointMake(size.width - padding, dPoint.y + triangleHeight / 2);
    [path addLineToPoint:ePoint];
    
    CGPoint fPoint = CGPointMake(size.width - padding, size.height - cornerRadius);
    [path addLineToPoint:fPoint];
    
    if (cornerRadius > 0) {
        [path addArcWithCenter:CGPointMake(fPoint.x - cornerRadius, fPoint.y) radius:cornerRadius startAngle:0 endAngle:0.5 * M_PI clockwise:true];
    }
    
    CGPoint gPoint = CGPointMake(cornerRadius, size.height);
    [path addLineToPoint:gPoint];
    
    if (cornerRadius > 0) {
        [path addArcWithCenter:CGPointMake(gPoint.x, gPoint.y - cornerRadius) radius:cornerRadius startAngle:0.5 * M_PI endAngle:M_PI clockwise:true];
    }
    
    CGPoint hPoint = CGPointMake(0, cornerRadius);
    [path addLineToPoint:hPoint];
    if (cornerRadius > 0) {
        [path addArcWithCenter:CGPointMake(hPoint.x + cornerRadius, hPoint.y) radius:cornerRadius startAngle:M_PI endAngle:1.5 * M_PI clockwise:true];
    }
    
    //镜像
    if (onLeft) {
        CGAffineTransform mirrorOverXOrigin = CGAffineTransformMakeScale(-1.0f, 1.0f);
        CGAffineTransform translate = CGAffineTransformMakeTranslation(size.width, 0);

        [path applyTransform:mirrorOverXOrigin];
        [path applyTransform:translate];
    }
    
    _contentMaskLayer.path = path.CGPath;
    self.layer.mask = _contentMaskLayer;

}

/**
 * 刷新数据
 */
- (void)refresh {
    BOOL onLeft = _model.layout.layoutType == LYSessionCellLayoutTypeLeft;
    _contentLabel.text = _model.contentText;
    
    _contentLabel.font = _model.config.fontConfig.contentFont;
    _contentLabel.textColor = onLeft ? _model.config.colorConfig.leftContentTextColor : _model.config.colorConfig.rightContentTextColor;
}

@end
