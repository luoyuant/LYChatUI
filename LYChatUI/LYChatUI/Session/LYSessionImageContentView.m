//
//  LYSessionImageContentView.m
//  LYChatUI
//
//  Created by luoyuan on 2021/2/26.
//

#import "LYSessionImageContentView.h"
#import "LYSessionImageCellLayout.h"

@implementation LYSessionImageContentView

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [UIImageView new];
        _imageView.clipsToBounds = true;
//        _contentLabel.adjustsFontSizeToFitWidth = true;
        [self.contentView addSubview:_imageView];
    }
    return self;
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self layoutImageView];
}

- (void)layoutImageView {
    if ([self.message.layout isKindOfClass:[LYSessionImageCellLayout class]]) {
        LYSessionImageCellLayout *layout = (LYSessionImageCellLayout *)self.message.layout;
        UIEdgeInsets padding = layout.contentPadding;
        CGSize size = self.contentView.bounds.size;
        _imageView.frame = CGRectMake(padding.left, padding.top, size.width - padding.left - padding.right, size.height - padding.top - padding.bottom);
    }
}

/**
 * 刷新数据
 */
- (void)refresh {
    self.layer.mask = nil;
    
    
    
    [self setNeedsLayout];
}

@end
