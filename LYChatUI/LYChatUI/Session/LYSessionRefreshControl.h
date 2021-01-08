//
//  LYSessionRefreshControl.h
//  LYChatUI
//
//  Created by luoyuan on 2021/1/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LYSessionRefreshControl : UIControl

@property (nonatomic, strong, readonly) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong, readonly) UILabel *titleLabel;

@property (nonatomic, readonly) BOOL refreshing;

- (void)beginRefreshing;

- (void)endRefreshing;

@end


@interface UIScrollView (LYChat)

@property (nonatomic, strong) LYSessionRefreshControl *lyChatRefreshControl;

@end

NS_ASSUME_NONNULL_END
