//
//  LYLabel.h
//  LYChatUI
//
//  Created by luoyuan on 2021/1/19.
//

#import <UIKit/UIKit.h>
#import "LYTextLayout.h"
#import "LYTextSelectionView.h"
#import "LYTextAttribute.h"

NS_ASSUME_NONNULL_BEGIN

@protocol LYLabelSelectionDelegate <NSObject>

@optional

- (BOOL)labelShouldBeginSelecting:(LYLabel *)label;
- (BOOL)labelShouldEndSelecting:(LYLabel *)label;

- (void)labelDidBeginSelecting:(LYLabel *)label;
- (void)labelDidEndSelecting:(LYLabel *)label;

- (void)labelDidBeginTrackingGrabber:(LYLabel *)label;
- (void)labelDidEndTrackingGrabber:(LYLabel *)label;

- (void)labelDidChangeSelection:(LYLabel *)label;

- (BOOL)labelShouldShowMenu:(LYLabel *)label selectionView:(LYTextSelectionView *)selectionView selectedRange:(LYTextRange *)selectedRange selectionRect:(CGRect)selectionRect;
- (BOOL)labelShouldHideMenu:(LYLabel *)label selectedRange:(LYTextRange *)selectedRange;

@end

@interface LYLabel : UIView

@property (nullable, nonatomic, copy) NSString *text;

@property (null_resettable, nonatomic, strong) UIFont *font;

@property (null_resettable, nonatomic, strong) UIColor *textColor;

@property (nonatomic) NSLineBreakMode lineBreakMode;

@property (nonatomic, readonly) LYTextTruncationType truncationType;

/**
 The truncation token string used when text is truncated. Default is nil.
 When the value is nil, the label use "…" as default truncation token.
 */
@property (nullable, nonatomic, copy) NSAttributedString *truncationToken;

@property (nonatomic) NSTextAlignment textAlignment;

@property (nonatomic) NSInteger numberOfLines;

@property (nonatomic, assign) UIEdgeInsets textContentInsets;

@property (nullable, nonatomic, copy) NSAttributedString *attributedText;

@property (nonatomic, weak) id<LYLabelSelectionDelegate> selectionDelegate;

@property (nonatomic, getter=isSelectable) BOOL selectable;

@property (nonatomic, strong, readonly) LYTextSelectionView *selectionView;

@property (nonatomic, strong) LYTextRange *selectedTextRange;

/**
 * 放大镜尺寸
 */
@property (nonatomic, assign) CGSize magnifierSize;

- (void)selectAllText;

- (void)endTextSelecting;

@end

NS_ASSUME_NONNULL_END
