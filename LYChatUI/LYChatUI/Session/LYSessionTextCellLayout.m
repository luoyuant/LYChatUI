//
//  LYSessionTextCellLayout.m
//  LYChatUI
//
//  Created by luoyuan on 2021/2/25.
//

#import "LYSessionTextCellLayout.h"
#import "LYLabel.h"
#import "LYSessionTextContentView.h"

@interface LYSessionTextCellLayout ()



@end

@implementation LYSessionTextCellLayout

- (Class)contentViewClass {
    return [LYSessionTextContentView class];
}

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
        UIEdgeInsets contentLabelInsets = self.contentLabelInsets;
        CGFloat widthOffset = self.contentTriangleWidth + padding.left + padding.right + contentLabelInsets.left + contentLabelInsets.right;
        CGFloat minHeight = self.avatarSize.height;
        CGFloat maxWidth = self.contentMaxWidth - widthOffset;
        
//        CGRect rect = [model.contentText boundingRectWithSize:CGSizeMake(maxWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : model.config.fontConfig.contentFont} context:nil];
        CGSize textSize = [LYTextLayout sizeThatFits:CGSizeMake(maxWidth, MAXFLOAT) text:[[NSAttributedString alloc] initWithString:model.message.text attributes:@{NSFontAttributeName : model.config.fontConfig.contentFont}] textContentInsets:UIEdgeInsetsZero];
        CGFloat width = textSize.width + widthOffset;
        CGFloat height = textSize.height + padding.top + padding.bottom + contentLabelInsets.top + contentLabelInsets.bottom;
        contentSize = CGSizeMake(MIN(width, self.contentMaxWidth), MAX(minHeight, height));
        self.contentSizeJson[@(cellWidth)] = [NSValue valueWithCGSize:contentSize];
    }
    return contentSize;
}

@end
