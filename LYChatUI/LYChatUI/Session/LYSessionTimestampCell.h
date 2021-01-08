//
//  LYSessionTimestampCell.h
//  LYChatUI
//
//  Created by luoyuan on 2021/1/8.
//

#import <UIKit/UIKit.h>
#import "LYSessionTimestampMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface LYSessionTimestampCell : UITableViewCell

@property (nonatomic, strong) UILabel *timestampLabel;

/**
 * model
 */
@property (nonatomic, strong) LYSessionTimestampMessage *model;

/**
 * 数据刷新
 */
- (void)refresh;

@end

NS_ASSUME_NONNULL_END
