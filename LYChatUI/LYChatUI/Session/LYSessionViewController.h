//
//  LYSessionViewController.h
//  LYChatUI
//
//  Created by luoyuan on 2020/12/31.
//

#import <UIKit/UIKit.h>
#import "LYSession.h"
#import "LYSessionManager.h"
#import "LYSessionCell.h"
#import "LYLabel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LYSessionViewController : UIViewController <LYSessionTableConfigDelegate, LYSessionCellDelegate, LYLabelSelectionDelegate>

/**
 * 会话对象
 */
@property (nonatomic, strong) LYSession *session;

/**
 * 管理器
 */
@property (nonatomic, strong) LYSessionManager *sessionManager;

/**
 * 消息列表tableView
 */
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIMenuController *selectedTextMenuController;

- (void)endTextSelecting;

@end

NS_ASSUME_NONNULL_END
