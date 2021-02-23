//
//  LYTextSelectionView.m
//  LYChatUI
//
//  Created by luoyuan on 2021/1/26.
//

#import "LYTextSelectionView.h"

static inline CGFloat LYTextCGPointGetDistanceToPoint(CGPoint p1, CGPoint p2) {
    return sqrt((p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y) * (p1.y - p2.y));
}

static inline CGPoint LYTextCGRectGetCenter(CGRect rect) {
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}


@implementation LYTextPosition

+ (instancetype)positionWithOffset:(NSInteger)offset {
    return [self positionWithOffset:offset affinity:LYTextAffinityForward];
}

+ (instancetype)positionWithOffset:(NSInteger)offset affinity:(LYTextAffinity) affinity {
    LYTextPosition *p = [LYTextPosition new];
    p->_offset = offset;
    p->_affinity = affinity;
    return p;
}

- (BOOL)isEqual:(LYTextPosition *)object {
    if (!object) return NO;
    return _offset == object.offset && _affinity == object.affinity;
}

- (NSComparisonResult)compare:(LYTextPosition *)otherPosition {
    if (!otherPosition) return NSOrderedAscending;
    if (_offset < otherPosition.offset) return NSOrderedAscending;
    if (_offset > otherPosition.offset) return NSOrderedDescending;
    if (_affinity == LYTextAffinityBackward && otherPosition.affinity == LYTextAffinityForward) return NSOrderedAscending;
    if (_affinity == LYTextAffinityForward && otherPosition.affinity == LYTextAffinityBackward) return NSOrderedDescending;
    return NSOrderedSame;
}


@end


@implementation LYTextRange {
    LYTextPosition *_start;
    LYTextPosition *_end;
}

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    _start = [LYTextPosition positionWithOffset:0];
    _end = [LYTextPosition positionWithOffset:0];
    return self;
}

- (LYTextPosition *)start {
    return _start;
}

- (LYTextPosition *)end {
    return _end;
}

- (NSUInteger)length {
    return _end.offset - _start.offset;
}

- (BOOL)isEmpty {
    return _start.offset == _end.offset;
}

+ (instancetype)rangeWithRange:(NSRange)range {
    return [LYTextRange rangeWithRange:range affinity:LYTextAffinityForward];
}

+ (instancetype)rangeWithRange:(NSRange)range affinity:(LYTextAffinity)affinity {
    LYTextPosition *start = [LYTextPosition positionWithOffset:range.location affinity:affinity];
    LYTextPosition *end = [LYTextPosition positionWithOffset:range.location + range.length affinity:affinity];
    return [self rangeWithStart:start end:end];
}

+ (instancetype)rangeWithStart:(LYTextPosition *)start end:(LYTextPosition *)end {
    if (!start || !end) return nil;
    if ([start compare:end] == NSOrderedDescending) {
        LYTEXT_SWAP(start, end);
    }
    LYTextRange *range = [LYTextRange new];
    range->_start = start;
    range->_end = end;
    return range;
}

- (BOOL)isEqual:(LYTextRange *)object {
    if (!object) return NO;
    return [_start isEqual:object.start] && [_end isEqual:object.end];
}

- (NSRange)asRange {
    return NSMakeRange(_start.offset, _end.offset - _start.offset);
}

- (instancetype)copyWithZone:(NSZone *)zone {
    return [self.class rangeWithStart:_start end:_end];
}

@end


@implementation LYTextSelectionRect



@end



@interface LYSelectionGrabber ()

@end

@implementation LYSelectionGrabber

#pragma mark - Setter

- (void)setColor:(UIColor *)color {
    _color = color;
    self.backgroundColor = color;
    _dot.backgroundColor = color;
}

- (void)setType:(LYSelectionGrabberType)type {
    if (_type != type) {
        _type = type;
        [self setNeedsLayout];
    }
}

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _dot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        _dot.userInteractionEnabled = false;
        [self addSubview:_dot];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat height = MIN(_dot.bounds.size.width, _dot.bounds.size.height);
    _dot.layer.cornerRadius = height / 2;
    
    CGRect frame = _dot.frame;
    CGFloat ofs = 0.5;
    if (_type == LYSelectionGrabberTypeStart) {
        frame.origin.y = -frame.size.height + ofs;
        frame.origin.x = (self.bounds.size.width - frame.size.width) / 2;
    } else {
        frame.origin.y = self.bounds.size.height - ofs;
        frame.origin.x = (self.bounds.size.width - frame.size.width) / 2;
    }
    _dot.frame = frame;
}

- (CGRect)touchRect {
    CGRect frame = self.frame;
    CGFloat touchExtend = 14;
    CGFloat dotExtend = 4;
    CGRect rect = CGRectInset(frame, -touchExtend, -touchExtend);
    UIEdgeInsets insets = {0};
    if (_type == LYSelectionGrabberTypeStart) {
        insets.top = -dotExtend;
    } else {
        insets.bottom = -dotExtend;
    }
    rect = UIEdgeInsetsInsetRect(rect, insets);
    return rect;
}


@end



@interface LYTextSelectionView ()

@property (nonatomic, strong) NSMutableArray<UIView *> *markViews;

@property (nonatomic, strong) LYSelectionGrabber *aGrabber;
@property (nonatomic, strong) LYSelectionGrabber *bGrabber;

@end

@implementation LYTextSelectionView

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        self.clipsToBounds = NO;
        
        _markViews = [NSMutableArray array];
        _color = [UIColor colorWithRed:69 / 255.0 green:111 / 255.0 blue:238 / 255.0 alpha:1];
        _colorAlpha = 0.2;
        
        _aGrabber = [LYSelectionGrabber new];
        _aGrabber.type = LYSelectionGrabberTypeStart;
        _aGrabber.hidden = YES;
        _aGrabber.color = _color;
        
        _bGrabber = [LYSelectionGrabber new];
        _bGrabber.type = LYSelectionGrabberTypeEnd;
        _bGrabber.hidden = YES;
        _bGrabber.color = _color;
        
        [self addSubview:_aGrabber];
        [self addSubview:_bGrabber];
    }
    return self;
}

#pragma mark - Setter

- (void)setColor:(UIColor *)color {
    _color = color;
    self.aGrabber.color = color;
    self.bGrabber.color = color;
    [self.markViews enumerateObjectsUsingBlock: ^(UIView *v, NSUInteger idx, BOOL *stop) {
        v.backgroundColor = color;
    }];
}

- (void)setSelectionRects:(NSArray<LYTextSelectionRect *> *)selectionRects {
    _selectionRects = selectionRects.copy;
    
    [self.markViews enumerateObjectsUsingBlock: ^(UIView *v, NSUInteger idx, BOOL *stop) {
        [v removeFromSuperview];
    }];
    [self.markViews removeAllObjects];
    self.aGrabber.hidden = YES;
    self.bGrabber.hidden = YES;
    
    [selectionRects enumerateObjectsUsingBlock:^(LYTextSelectionRect * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGRect rect = obj.rect;
        rect = CGRectStandardize(rect);
        if (obj.containsStart || obj.containsEnd) {
            CGFloat lineWidth = 2;
            if (rect.size.width == 0) {
                rect.size.width = lineWidth;
                rect.origin.x -= lineWidth * 0.5;
            }
            if (rect.origin.x < 0) {
                rect.origin.x = 0;
            } else if (rect.origin.x + rect.size.width > self.bounds.size.width) {
                rect.origin.x = self.bounds.size.width - rect.size.width;
            }
            
            if (obj.containsStart) {
                self.aGrabber.hidden = false;
                self.aGrabber.frame = rect;
                self.aGrabber.type = LYSelectionGrabberTypeStart;
            } else {
                self.bGrabber.hidden = false;
                self.bGrabber.frame = rect;
                self.bGrabber.type = LYSelectionGrabberTypeEnd;
            }
            
        } else {
            if (rect.size.width > 0 && rect.size.height > 0) {
                UIView *mark = [[UIView alloc] initWithFrame:rect];
                mark.backgroundColor = _color;
                mark.alpha = self.colorAlpha;
                [self insertSubview:mark atIndex:0];
                [self.markViews addObject:mark];
            }
        }
    }];
    
}

#pragma mark - Getter

- (LYSelectionGrabber *)startGrabber {
    return _aGrabber.type == LYSelectionGrabberTypeStart ? _aGrabber : _bGrabber;
}

- (LYSelectionGrabber *)endGrabber {
    return _aGrabber.type == LYSelectionGrabberTypeEnd ? _aGrabber : _bGrabber;
}

#pragma mark - Public Method

- (LYSelectionGrabberType)getTypeGrabberContainsPoint:(CGPoint)point {
    if ([self isStartGrabberContainsPoint:point]) {
        return LYSelectionGrabberTypeStart;
    }
    if ([self isEndGrabberContainsPoint:point]) {
        return LYSelectionGrabberTypeEnd;
    }
    return LYSelectionGrabberTypeNone;
}

#pragma mark - Private Method

- (BOOL)isStartGrabberContainsPoint:(CGPoint)point {
    if (self.startGrabber.hidden) return NO;
    CGRect startRect = [self.startGrabber touchRect];
    CGRect endRect = [self.endGrabber touchRect];
    if (CGRectIntersectsRect(startRect, endRect)) {
        CGFloat distStart = LYTextCGPointGetDistanceToPoint(point, LYTextCGRectGetCenter(startRect));
        CGFloat distEnd = LYTextCGPointGetDistanceToPoint(point, LYTextCGRectGetCenter(endRect));
        if (distEnd <= distStart) return NO;
    }
    return CGRectContainsPoint(startRect, point);
}

- (BOOL)isEndGrabberContainsPoint:(CGPoint)point {
    if (self.endGrabber.hidden) return NO;
    CGRect startRect = [self.startGrabber touchRect];
    CGRect endRect = [self.endGrabber touchRect];
    if (CGRectIntersectsRect(startRect, endRect)) {
        CGFloat distStart = LYTextCGPointGetDistanceToPoint(point, LYTextCGRectGetCenter(startRect));
        CGFloat distEnd = LYTextCGPointGetDistanceToPoint(point, LYTextCGRectGetCenter(endRect));
        if (distEnd > distStart) return NO;
    }
    return CGRectContainsPoint(endRect, point);
}

@end
