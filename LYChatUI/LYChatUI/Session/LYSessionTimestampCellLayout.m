//
//  LYSessionTimestampCellLayout.m
//  LYChatUI
//
//  Created by luoyuan on 2021/1/8.
//

#import "LYSessionTimestampCellLayout.h"
#import "LYSessionTimestampCell.h"

@interface LYSessionTimestampCellLayout ()


@end

@implementation LYSessionTimestampCellLayout

#pragma mark - Getter

- (Class)cellClass {
    return [LYSessionTimestampCell class];
}

- (UIEdgeInsets)contentMargin {
    return UIEdgeInsetsMake(0, 12, 0, 12);
}

#pragma Public Method

- (void)setupWithMessage:(LYSessionMessageModel *)message {
    self.layoutType = LYSessionCellLayoutTypeAuto;
}

/**
 * cell高度
 */
- (CGFloat)cellHeightForCellWidth:(CGFloat)cellWidth model:(LYSessionMessageModel *)model {
    return 44;
}

@end
