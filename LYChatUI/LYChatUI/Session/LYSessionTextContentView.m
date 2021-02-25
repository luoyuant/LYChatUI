//
//  LYSessionTextContentView.m
//  LYChatUI
//
//  Created by luoyuan on 2021/2/24.
//

#import "LYSessionTextContentView.h"

@implementation LYSessionTextContentView

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _contentLabel = [LYLabel new];
        _contentLabel.numberOfLines = 0;
        _contentLabel.selectable = true;
        _contentLabel.magnifierSize = CGSizeMake(128, 42);
//        _contentLabel.adjustsFontSizeToFitWidth = true;
        [self.contentView addSubview:_contentLabel];
    }
    return self;
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self layoutContentLabel];
}

- (void)layoutContentLabel {
    if ([self.message.layout isKindOfClass:[LYSessionCellLayout class]]) {
        LYSessionCellLayout *layout = self.message.layout;
        UIEdgeInsets padding = layout.contentPadding;
        CGSize size = self.contentView.bounds.size;
        _contentLabel.textContentInsets = layout.contentLabelInsets;
        _contentLabel.frame = CGRectMake(padding.left, padding.top, size.width - padding.left - padding.right, size.height - padding.top - padding.bottom);
    }
}

/**
 * 刷新数据
 */
- (void)refresh {
    [super refresh];
    
    BOOL onLeft = self.message.layout.layoutType == LYSessionCellLayoutTypeLeft;
    _contentLabel.font = self.message.config.fontConfig.contentFont;
    _contentLabel.textColor = onLeft ? self.message.config.colorConfig.leftContentTextColor : self.message.config.colorConfig.rightContentTextColor;
    
    _contentLabel.text = self.message.message.text;
    
    [self setNeedsLayout];
}

@end
