//
//  LYTextMagnifier.h
//  LYChatUI
//
//  Created by luoyuan on 2021/1/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LYTextMagnifierMaskView : UIView



@end

@interface LYTextMagnifier : UIView

@property (nonatomic, readonly) CGSize snapshotSize; 
@property (nonatomic, readonly) CGSize contentSize;

@property (nonatomic, assign) BOOL captureFadeAnimation;
@property (nullable, nonatomic, strong) UIImage *snapshot;

/**
 * 显示放大镜
 * @param point x = grabber.center.x, y = 点击位置
 */
- (void)showMagnifierOnWindow:(UIWindow *)window point:(CGPoint)point;

- (void)moveMagnifierToPoint:(CGPoint)point;

- (void)hideMagnifier;

@end

NS_ASSUME_NONNULL_END
