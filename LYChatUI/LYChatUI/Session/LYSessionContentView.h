//
//  LYSessionContentView.h
//  LYChatUI
//
//  Created by luoyuan on 2021/1/4.
//

#import <UIKit/UIKit.h>
#import "LYSessionMessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LYSessionContentView : UIView

@property (nonatomic, strong) CAShapeLayer *contentMaskLayer;

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, weak) LYSessionMessageModel *message;

/**
 * 刷新数据
 */
- (void)refresh;

@end

NS_ASSUME_NONNULL_END
