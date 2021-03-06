//
//  LYSessionTextCellLayout.h
//  LYChatUI
//
//  Created by luoyuan on 2021/2/25.
//

#import <Foundation/Foundation.h>
#import "LYSessionCellLayout.h"
#import "LYSessionMessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LYSessionTextCellLayout : LYSessionCellLayout

/**
 * label 边距
 */
@property (nonatomic, assign) UIEdgeInsets contentLabelInsets;

@end

NS_ASSUME_NONNULL_END
