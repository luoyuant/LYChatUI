//
//  LYTextSelectionView.h
//  LYChatUI
//
//  Created by luoyuan on 2021/1/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#ifndef LYTEXT_SWAP // swap two value
#define LYTEXT_SWAP(_a_, _b_)  do { __typeof__(_a_) _tmp_ = (_a_); (_a_) = (_b_); (_b_) = _tmp_; } while (0)
#endif

typedef NS_ENUM(NSInteger, LYSelectionGrabberType) {
    LYSelectionGrabberTypeNone = 0,
    LYSelectionGrabberTypeStart = 1,
    LYSelectionGrabberTypeEnd = 2,
};

/**
 * 位置亲和
 * 示例：第一行末尾跟第二行开头位置实际上是一致的，需要根据此区分
 */
typedef NS_ENUM(NSInteger, LYTextAffinity) {
    LYTextAffinityForward  = 0,
    LYTextAffinityBackward = 1,
};


@interface LYTextPosition : NSObject

@property (nonatomic, readonly) NSInteger offset;
@property (nonatomic, readonly) LYTextAffinity affinity;

@property (nonatomic, assign) BOOL isCurrentLineLastPosition;

+ (instancetype)positionWithOffset:(NSInteger)offset;
+ (instancetype)positionWithOffset:(NSInteger)offset affinity:(LYTextAffinity) affinity;

- (NSComparisonResult)compare:(LYTextPosition *)otherPosition;

@end

@interface LYTextRange : NSObject <NSCopying>

@property (nonatomic, readonly) LYTextPosition *start;
@property (nonatomic, readonly) LYTextPosition *end;
@property (nonatomic, readonly) NSUInteger length;
@property (nonatomic, readonly, getter=isEmpty) BOOL empty;

+ (instancetype)rangeWithRange:(NSRange)range;
+ (instancetype)rangeWithRange:(NSRange)range affinity:(LYTextAffinity)affinity;
+ (instancetype)rangeWithStart:(LYTextPosition *)start end:(LYTextPosition *)end;

- (NSRange)asRange;

@end


@interface LYTextSelectionRect : NSObject

@property (nonatomic, readwrite) CGRect rect;
@property (nonatomic, readwrite) BOOL containsStart;
@property (nonatomic, readwrite) BOOL containsEnd;

@end

@interface LYSelectionGrabber : UIView

@property (nonatomic, readonly) UIView *dot;
@property (nullable, nonatomic, strong) UIColor *color;
@property (nonatomic, assign) LYSelectionGrabberType type;

@end

@interface LYTextSelectionView : UIView

@property (nonatomic, weak) UIView *hostView;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) CGFloat colorAlpha;
@property (nullable, nonatomic, copy) NSArray<LYTextSelectionRect *> *selectionRects;
@property (nonatomic, readonly) LYSelectionGrabber *startGrabber;
@property (nonatomic, readonly) LYSelectionGrabber *endGrabber;

- (LYSelectionGrabberType)getTypeGrabberContainsPoint:(CGPoint)point;

@end

NS_ASSUME_NONNULL_END
