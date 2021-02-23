//
//  LYTextLayout.h
//  LYChatUI
//
//  Created by luoyuan on 2021/1/22.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import "LYTextLine.h"
#import "LYTextSelectionView.h"

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN NSString * const LYTextHighlightAttributeName;
extern const CGSize LYTextContainerMaxSize;

@class LYLabel;

@interface LYTextLayout : NSObject

@property (nonatomic, strong, readonly) NSAttributedString *text;
@property (nonatomic, readonly) CTFramesetterRef framesetterRef;
@property (nonatomic, readonly) CTFrameRef frameRef;
@property (nonatomic, strong, readonly) NSArray<LYTextLine *> *lines;
@property (nullable, nonatomic, strong, readonly) LYTextLine *truncatedLine;
@property (nonatomic, readonly) NSUInteger rowCount;
@property (nonatomic, readonly) NSRange visibleRange;
@property (nonatomic, readonly) CGRect textBoundingRect;
@property (nonatomic, readonly) CGSize textBoundingSize;
@property (nonatomic, readonly) NSArray<NSValue *> *highlightRanges;

+ (nullable LYTextLayout *)layoutWithLabel:(LYLabel *)label text:(NSAttributedString *)text;

+ (nullable LYTextLayout *)layoutWithLabel:(LYLabel *)label text:(NSAttributedString *)text bounds:(CGRect)bounds;

+ (nullable LYTextLayout *)layoutWithLabel:(LYLabel *)label text:(NSAttributedString *)text range:(NSRange)range bounds:(CGRect)bounds;

+ (CGSize)sizeThatFits:(CGSize)size text:(NSAttributedString *)text textContentInsets:(UIEdgeInsets)textContentInsets;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

- (NSArray<LYTextSelectionRect *> *)selectionRectsForRange:(LYTextRange *)range;

- (LYTextPosition * _Nullable)closestPositionToPoint:(CGPoint)point;

- (NSUInteger)textPositionForPoint:(CGPoint)point lineIndex:(NSUInteger)lineIndex;

- (NSUInteger)closestLineIndexForPoint:(CGPoint)point;

@end

NS_ASSUME_NONNULL_END
