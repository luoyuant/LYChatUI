//
//  LYLabelLayer.h
//  LYChatUI
//
//  Created by luoyuan on 2021/1/19.
//

#import <UIKit/UIKit.h>
#import "LYTextLayout.h"

NS_ASSUME_NONNULL_BEGIN

@protocol LYLabelLayerDelegate <NSObject, CALayerDelegate>

@required

- (NSAttributedString * _Nonnull)textForDisplay;

- (LYTextLayout * _Nonnull)layoutForDisplay;

- (void)didEndDisplay;

@end

@interface LYLabelLayer : CALayer

@end

NS_ASSUME_NONNULL_END
