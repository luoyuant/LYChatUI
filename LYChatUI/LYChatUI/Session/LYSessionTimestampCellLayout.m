//
//  LYSessionTimestampCellLayout.m
//  LYChatUI
//
//  Created by luoyuan on 2021/1/8.
//

#import "LYSessionTimestampCellLayout.h"
#import "LYSessionTimestampCell.h"

@interface LYSessionTimestampCellLayout ()

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSValue *> *contentSizeJson;

@end

@implementation LYSessionTimestampCellLayout

#pragma mark - Getter

- (NSMutableDictionary<NSNumber *, NSValue *> *)contentSizeJson {
    if (!_contentSizeJson) {
        _contentSizeJson = [NSMutableDictionary dictionary];
    }
    return _contentSizeJson;
}

- (Class)cellClass {
    return [LYSessionTimestampCell class];
}

- (UIEdgeInsets)contentMargin {
    return UIEdgeInsetsMake(0, 12, 0, 12);
}

#pragma Public Method

- (void)setupWithMessage:(LYSessionMessage *)message {
    self.layoutType = LYSessionCellLayoutTypeAuto;
}

/**
 * cell高度
 */
- (CGFloat)cellHeightForCellWidth:(CGFloat)cellWidth model:(LYSessionMessage *)model {
    return 44;
}

@end
