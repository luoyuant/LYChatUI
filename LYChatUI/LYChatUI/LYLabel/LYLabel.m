//
//  LYLabel.m
//  LYChatUI
//
//  Created by luoyuan on 2021/1/19.
//

#import "LYLabel.h"
#import "LYLabelLayer.h"
#import "LYTextWeakProxy.h"
#import <CoreText/CTFramesetter.h>
#import <CoreText/CTStringAttributes.h>
#import "LYTextMagnifier.h"

@interface LYLabel () <LYLabelLayerDelegate>
{
    struct {
        BOOL layoutNeedUpdate;
        BOOL selecting;
        NSInteger trackingGrabber;
        BOOL showingMagnifier;
        BOOL showingHighlight;
        BOOL showingMenu;
    } _state;
}
@property (nonatomic, strong) NSMutableAttributedString *innerText;
@property (nonatomic, strong) LYTextLayout *innerLayout;
@property (nonatomic, strong) LYTextLayout *innerNeedsLayout;

@property (nonatomic, assign) CGPoint touchBeganPoint;
@property (nonatomic, strong) NSTimer *longPressTimer;


/**
 * 放大镜
 */
@property (nonatomic, strong) LYTextMagnifier *magnifier;

@property (nonatomic, strong) LYTextHighlight *highlight;
@property (nonatomic, strong) LYTextLayout *highlightLayout;

@end

@implementation LYLabel

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        [self _initLabel];
        self.frame = frame;
    }
    return self;
}

- (void)_initLabel {
    self.layer.contentsScale = [UIScreen mainScreen].scale;
    self.contentMode = UIViewContentModeRedraw;
    
    _font = [self _defaultFont];
    _textColor = [self _defaultTextColor];
    _textAlignment = NSTextAlignmentNatural;
    _lineBreakMode = NSLineBreakByTruncatingTail;
    _truncationType = LYTextTruncationTypeEnd;
    _numberOfLines = 1;
    
    _innerText = [NSMutableAttributedString new];
        
    _selectionView = [LYTextSelectionView new];
    _selectionView.userInteractionEnabled = NO;
    _selectionView.hostView = self;
    _selectionView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0];
    [self addSubview:_selectionView];
    
}

#pragma mark - Override

- (void)setFrame:(CGRect)frame {
    CGSize oldSize = self.bounds.size;
    [super setFrame:frame];
    CGSize newSize = self.bounds.size;
    if (!CGSizeEqualToSize(oldSize, newSize)) {
        _state.layoutNeedUpdate = YES;
        [self.layer setNeedsDisplay];
    }
}

- (void)setBounds:(CGRect)bounds {
    CGSize oldSize = self.bounds.size;
    [super setBounds:bounds];
    CGSize newSize = self.bounds.size;
    if (!CGSizeEqualToSize(oldSize, newSize)) {
        _state.layoutNeedUpdate = YES;
        [self.layer setNeedsDisplay];
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    if (!_innerNeedsLayout) {
        [self _updateIfNeeded];
    }
    return _innerNeedsLayout.textBoundingSize;
}

- (void)sizeToFit {
    CGRect oldFrame = self.frame;
    [super sizeToFit];
    
    CGRect frame = self.frame;
    
    if (!CGRectEqualToRect(oldFrame, frame)) {
        _state.layoutNeedUpdate = false;
        _innerLayout = _innerNeedsLayout;
        [self.layer setNeedsDisplay];
    }
    
}

#pragma mark - Private Method

- (void)_updateIfNeeded {
    if (_state.layoutNeedUpdate) {
        _state.layoutNeedUpdate = NO;
        [self _updateLayout];
    }
}

- (void)_setLayoutNeedUpdate {
    _state.layoutNeedUpdate = true;
    [self _clearInnerLayout];
}

- (void)_updateLayout {
    self.innerLayout = [LYTextLayout layoutWithLabel:self text:self.innerText];
    
    if (self.innerLayout.visibleRange.length == self.innerText.length) {
        self.innerNeedsLayout = self.innerLayout;
    } else {
        CGRect bounds = self.bounds;
        if (bounds.size.width <= 0) {
            bounds.size.width = LYTextContainerMaxSize.width;
        }
        bounds.size.height = LYTextContainerMaxSize.height;
        self.innerNeedsLayout = [LYTextLayout layoutWithLabel:self text:self.innerText bounds:bounds];
        if (self.innerNeedsLayout.visibleRange.length != self.innerText.length) {
            bounds.size.width = LYTextContainerMaxSize.width;
            self.innerNeedsLayout = [LYTextLayout layoutWithLabel:self text:self.innerText bounds:bounds];
        }
    }
    [self.layer setNeedsDisplay];
}

- (void)_clearInnerLayout {
    if (!_innerLayout) return;
    LYTextLayout *layout = _innerLayout;
    _innerLayout = nil;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [layout text];
    });
}

#pragma mark - layerClass

+ (Class)layerClass {
    return LYLabelLayer.class;
}

#pragma mark - Setter

- (void)setText:(NSString *)text {
    if (_text == text || [_text isEqualToString:text]) return;
    _text = text.copy;
    BOOL updateAttributes = _innerText.length == 0 && text.length > 0;
    [_innerText replaceCharactersInRange:NSMakeRange(0, _innerText.length) withString:text ? text : @""];
    [self ly_removeAllAttributesInRange:NSMakeRange(0, _innerText.length)];
    if (updateAttributes) {
        NSRange range = NSMakeRange(0, _innerText.length);
        [self ly_setFont:_font range:range];
        [self ly_setTextColor:_textColor range:range];
        [self ly_setTextAlignment:_textAlignment range:range];
    }
    [self _setLayoutNeedUpdate];
    [self _endTouch];
    [self invalidateIntrinsicContentSize];
}

- (void)setFont:(UIFont *)font {
    if (!font) {
        font = [self _defaultFont];
    }
    if (_font == font || [_font isEqual:font]) return;
    _font = font;
    [self ly_setFont:_font range:NSMakeRange(0, _innerText.length)];
    
    if (_innerText.length) {
        [self _setLayoutNeedUpdate];
        [self _endTouch];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)setTextColor:(UIColor *)textColor {
    if (!textColor) {
        textColor = [self _defaultTextColor];
    }
    if (_textColor == textColor || [_textColor isEqual:textColor]) return;
    _textColor = textColor;
    [self ly_setTextColor:_textColor range:NSMakeRange(0, _innerText.length)];
    
    if (_innerText.length) {
        [self _setLayoutNeedUpdate];
        [self _endTouch];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode {
    if (_lineBreakMode == lineBreakMode) return;
    _lineBreakMode = lineBreakMode;
    // allow multi-line break
    switch (lineBreakMode) {
        case NSLineBreakByWordWrapping:
        case NSLineBreakByCharWrapping:
        case NSLineBreakByClipping: {
            _truncationType = LYTextTruncationTypeNone;
        }
            break;
        case NSLineBreakByTruncatingHead: {
            _truncationType = LYTextTruncationTypeStart;
        }
            break;
        case NSLineBreakByTruncatingTail: {
            _truncationType = LYTextTruncationTypeEnd;
        }
            break;
        case NSLineBreakByTruncatingMiddle: {
            _truncationType = LYTextTruncationTypeMiddle;
        }
            break;
        default:
            break;
    }
    if (_innerText.length) {
        [self _setLayoutNeedUpdate];
        [self _endTouch];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)setTruncationToken:(NSAttributedString *)truncationToken {
    if (_truncationToken == truncationToken || [_truncationToken isEqual:truncationToken]) return;
    _truncationToken = truncationToken.copy;
    if (_innerText.length) {
        [self _setLayoutNeedUpdate];
        [self _endTouch];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    if (_textAlignment == textAlignment) return;
    _textAlignment = textAlignment;
    [self ly_setTextAlignment:_textAlignment range:NSMakeRange(0, _innerText.length)];
    
    if (_innerText.length) {
        [self _setLayoutNeedUpdate];
        [self _endTouch];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)setNumberOfLines:(NSInteger)numberOfLines {
    if (_numberOfLines == numberOfLines) return;
    _numberOfLines = numberOfLines;
    if (_innerText.length) {
        [self _setLayoutNeedUpdate];
        [self _endTouch];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    _attributedText = attributedText;
    if (attributedText.length > 0) {
        _innerText = attributedText.mutableCopy;
    } else {
        _innerText = [NSMutableAttributedString new];
    }
    
    [self _setLayoutNeedUpdate];
    [self _endTouch];
    [self invalidateIntrinsicContentSize];
}

- (void)setTextContentInsets:(UIEdgeInsets)textContentInsets {
    if (UIEdgeInsetsEqualToEdgeInsets(_textContentInsets, textContentInsets)) return;
    _textContentInsets = textContentInsets;
    
    if (_innerText.length) {
        [self _setLayoutNeedUpdate];
        [self _endTouch];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)setSelectable:(BOOL)selectable {
    if (_selectable == selectable) return;
    _selectable = selectable;
}

- (void)setSelectedTextRange:(LYTextRange *)selectedTextRange {
    [self _updateSelectedRange:selectedTextRange];
}

- (void)setMagnifierSize:(CGSize)magnifierSize {
    _magnifierSize = magnifierSize;
    if (_magnifier) {
        CGRect rect = {_magnifier.frame.origin, _magnifierSize};
        _magnifier.frame = rect;
    }
}

#pragma mark - Getter

- (UIFont *)_defaultFont {
    return [UIFont systemFontOfSize:17];
}

- (UIColor *)_defaultTextColor {
    UIColor *textColor;
    if (@available(iOS 13.0, *)) {
        textColor = [UIColor labelColor];
    } else {
        textColor = [UIColor blackColor];
    }
    return textColor;
}

- (LYTextMagnifier *)magnifier {
    if (!_magnifier) {
        CGSize size = _magnifierSize;
        if (size.width <= 0) {
            size.width = 128;
        }
        if (size.height <= 0) {
            size.height = 46;
        }
        CGRect rect = {CGPointZero, size};
        _magnifier = [[LYTextMagnifier alloc] initWithFrame:rect];
    }
    return _magnifier;
}

#pragma mark - Attributes

- (void)ly_setFont:(UIFont *)font range:(NSRange)range {
    [self ly_setAttribute:NSFontAttributeName value:font range:range];
}

- (void)ly_setTextColor:(UIColor *)textColor range:(NSRange)range {
    [self ly_setAttribute:(id)kCTForegroundColorAttributeName value:textColor range:range];
    [self ly_setAttribute:NSForegroundColorAttributeName value:textColor range:range];
}

- (void)ly_setTextAlignment:(NSTextAlignment)textAlignment range:(NSRange)range {
    [_innerText enumerateAttribute:NSParagraphStyleAttributeName
         inRange:range
         options:kNilOptions
      usingBlock: ^(NSParagraphStyle *value, NSRange subRange, BOOL *stop) {
          NSMutableParagraphStyle *style = nil;
          if (value) {
              if ([value isKindOfClass:[NSMutableParagraphStyle class]]) {
                  style = (id)value;
              } else {
                  style = value.mutableCopy;
              }
          } else {
              style = [NSParagraphStyle defaultParagraphStyle].mutableCopy;
          }
        style.alignment = textAlignment;
        [self ly_setAttribute:NSParagraphStyleAttributeName value:style range:subRange];
    }];
}

- (void)ly_setAttribute:(NSString *)name value:(id)value range:(NSRange)range {
    if (!name || [NSNull isEqual:name]) return;
    if (value && ![NSNull isEqual:value]) {
        [_innerText addAttribute:name value:value range:range];
    } else {
        [_innerText removeAttribute:name range:range];
    }
}

- (void)ly_removeAllAttributesInRange:(NSRange)range {
    NSArray *keys = [self ly_attributeKeys];
    for (NSString *key in keys) {
        [_innerText removeAttribute:key range:range];
    }
}

- (NSArray *)ly_attributeKeys {
    static NSArray *keys;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keys = @[(id)kCTSuperscriptAttributeName,
                 (id)kCTRunDelegateAttributeName,
                 (id)kCTRubyAnnotationAttributeName,
                 NSAttachmentAttributeName
        ];
    });
    return keys;
}

#pragma mark - LYLabelLayerDelegate

- (NSAttributedString *)textForDisplay {
    return _innerText;
}

- (LYTextLayout *)layoutForDisplay {
    if (_state.layoutNeedUpdate || !_innerLayout) {
        [self _updateLayout];
    }
    return _state.showingHighlight && _highlightLayout ? _highlightLayout : _innerLayout;
}

- (void)didEndDisplay {
    _state.layoutNeedUpdate = false;
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.selectable) {
        [super touchesBegan:touches withEvent:event];
        return;
    }
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    if (touch.tapCount > 1) {
        [self endTextSelecting];
    }

    _touchBeganPoint = point;
    
    //select
    {
        if (self.selectable) {
            _state.selecting = true;
            _state.trackingGrabber = LYSelectionGrabberTypeNone;
            [self _startLongPressTimer];
            LYSelectionGrabberType type = [_selectionView getTypeGrabberContainsPoint:point];
            if (type != LYSelectionGrabberTypeNone) {
                _state.trackingGrabber = type;
                if (self.selectionDelegate && [self.selectionDelegate respondsToSelector:@selector(labelDidBeginTrackingGrabber:)]) {
                    [self.selectionDelegate labelDidBeginTrackingGrabber:self];
                }
            }
        }
    }
    
    //highlight
    {
        if (_innerLayout.highlightRanges.count > 0 && _selectedTextRange.length == 0) {
            LYTextPosition *pos = [_innerLayout closestPositionToPoint:point];
            NSRange highlightRange = {0};
            for (NSValue *value in _innerLayout.highlightRanges) {
                NSRange range = [value rangeValue];
                if (NSLocationInRange(pos.offset, range) || (pos.offset == range.location + range.length && pos.affinity == LYTextAffinityBackward)) {
                    highlightRange = range;
                    break;
                }
            }
            
            if (highlightRange.length > 0) {
                NSRange textRange = {0};
                _highlight = [_innerText attribute:LYTextHighlightAttributeName
                                                           atIndex:highlightRange.location
                                             longestEffectiveRange:&textRange
                                                           inRange:NSMakeRange(0, _innerText.length)];
                if (_highlight) {
                    _highlight.range = highlightRange;
                    [self _showHighlightAnimated:false];
                }
            }
            
        }
    }
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.selectable) {
        [super touchesMoved:touches withEvent:event];
        return;
    }
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    
    if (_state.selecting && _state.trackingGrabber) {
        if (!CGRectContainsPoint(self.bounds, point)) {
            return;
        }
        LYTextPosition *pos = [_innerLayout closestPositionToPoint:point];
        if (pos) {
            LYTextRange *newRange;
            
            if (_state.trackingGrabber == LYSelectionGrabberTypeStart) {
                if (pos.offset == _selectedTextRange.end.offset) {
                    pos = [LYTextPosition positionWithOffset:pos.offset - 1 affinity:pos.affinity];
                } else if (pos.offset > _selectedTextRange.end.offset) {
                    _state.trackingGrabber = LYSelectionGrabberTypeEnd;
                } else if (pos.isCurrentLineLastPosition) {
                    pos = [LYTextPosition positionWithOffset:pos.offset - 1 affinity:pos.affinity];
                }
                newRange = [LYTextRange rangeWithStart:pos end:_selectedTextRange.end];
            } else if (_state.trackingGrabber == LYSelectionGrabberTypeEnd) {
                if (pos.offset == _selectedTextRange.start.offset) {
                    pos = [LYTextPosition positionWithOffset:pos.offset + 1 affinity:pos.affinity];
                } else if (pos.offset < _selectedTextRange.start.offset) {
                    _state.trackingGrabber = LYSelectionGrabberTypeStart;
                }
                newRange = [LYTextRange rangeWithStart:_selectedTextRange.start end:pos];
            }
            [self _updateSelectedRange:newRange];
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.selectable) {
        [super touchesEnded:touches withEvent:event];
    }
    [self _endSelectingTouch];
    [self _endTouchTracking];
    
    if (_highlight) {
        [self _removeHighlightAnimated:false];
    }
    
    if (_selectedTextRange.length > 0) {
        [self _showMenu];
    } else {
        [self _hideMenu];
    }
    
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.selectable) {
        [super touchesCancelled:touches withEvent:event];
    }
    [self _endSelectingTouch];
    [self _endTouchTracking];
    [self _removeHighlightAnimated:YES];
}

#pragma mark - Touches Private Methods

- (void)_startLongPressTimer {
    [_longPressTimer invalidate];
    _longPressTimer = [NSTimer timerWithTimeInterval:0.5
                                              target:[LYTextWeakProxy proxyWithTarget:self]
                                            selector:@selector(_selectDidLongPress)
                                            userInfo:nil
                                             repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_longPressTimer forMode:NSRunLoopCommonModes];
}

- (void)_endLongPressTimer {
    [_longPressTimer invalidate];
    _longPressTimer = nil;
}

- (void)_selectDidLongPress {
    [self _endLongPressTimer];
    
    if (_state.trackingGrabber) {
        [self _updateMagnifier];
        return;
    }
    
    BOOL shouldBeginSelecting = true;
    if (self.selectionDelegate && [self.selectionDelegate respondsToSelector:@selector(labelShouldBeginSelecting:)]) {
        shouldBeginSelecting = [self.selectionDelegate labelShouldBeginSelecting:self];
    }
    
    if (!shouldBeginSelecting) {
        return;
    }
    
    if (self.selectionDelegate && [self.selectionDelegate respondsToSelector:@selector(labelDidBeginSelecting:)]) {
        [self.selectionDelegate labelDidBeginSelecting:self];
    }
    
    NSRange range = {0};
    if (_selectedTextRange.length > 0) {
        LYTextPosition *pos = [_innerLayout closestPositionToPoint:_touchBeganPoint];
        NSUInteger loc = pos.offset;
        NSUInteger len = 2;
        NSUInteger textLen = _innerText.length;
        if (loc + len > textLen) {
            loc = textLen - len;
        }
        range = NSMakeRange(loc, len);
    } else {
        range = NSMakeRange(0, _innerText.length);
    }
    
    [self _updateSelectedRange:[LYTextRange rangeWithRange:range]];
    
}

- (void)_showHighlightAnimated:(BOOL)animated {
    if (!_highlight) return;
    if (!_highlightLayout) {
        NSMutableAttributedString *hiText = _innerText.mutableCopy;
        NSDictionary *newAttrs = _highlight.attributes;
        [newAttrs enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {
            [hiText ly_setAttribute:key value:value range:_highlight.range];
        }];
        _highlightLayout = [LYTextLayout layoutWithLabel:self text:hiText];
        if (!_highlightLayout) _highlight = nil;
    }
    
    if (_highlightLayout && !_state.showingHighlight) {
        _state.showingHighlight = YES;
        [self.layer setNeedsDisplay];
    }
}

- (void)_hideHighlightAnimated:(BOOL)animated {
    if (_state.showingHighlight) {
        _state.showingHighlight = NO;
        [self.layer setNeedsDisplay];
    }
}

- (void)_removeHighlightAnimated:(BOOL)animated {
    [self _hideHighlightAnimated:animated];
    _highlight = nil;
    _highlightLayout = nil;
}

- (void)_endSelectingTouch {
    if (_state.selecting) {
        _state.selecting = false;
        [self _endLongPressTimer];
    }
}

- (void)_updateSelectedRange:(LYTextRange *)range {
    if ([_selectedTextRange isEqual:range]) {
        return;
    }
    
    //取消选择
    if (range.length == 0) {
        BOOL shouldEndSelecting = true;
        if (self.selectionDelegate && [self.selectionDelegate respondsToSelector:@selector(labelShouldEndSelecting:)]) {
            shouldEndSelecting = [self.selectionDelegate labelShouldEndSelecting:self];
        }
        
        if (!shouldEndSelecting) {
            return;
        }
    }
    
    _selectedTextRange = range;
    [self _updateSelectionView];
    
    if (self.selectionDelegate && [self.selectionDelegate respondsToSelector:@selector(labelDidChangeSelection:)]) {
        [self.selectionDelegate labelDidChangeSelection:self];
    }
    
    if (range.length == 0) {
        if (self.selectionDelegate && [self.selectionDelegate respondsToSelector:@selector(labelDidEndSelecting:)]) {
            [self.selectionDelegate labelDidEndSelecting:self];
        }
    }
    
}

- (void)_updateSelectionView {
    _selectionView.frame = self.bounds;
    
    NSArray<LYTextSelectionRect *> *rects = [_innerLayout selectionRectsForRange:_selectedTextRange];
    _selectionView.selectionRects = rects;
    
    [self _updateMagnifier];
}

- (void)_updateMagnifier {
    if (_state.trackingGrabber == LYSelectionGrabberTypeNone) {
        return;
    }
    
    LYTextSelectionRect *rect;
    if (_state.trackingGrabber == LYSelectionGrabberTypeStart) {
        rect = _selectionView.selectionRects.firstObject;
    } else {
        if (_selectionView.selectionRects.count > 1) {
            rect = _selectionView.selectionRects[1];
        }
    }
    if (!rect) {
        return;
    }

    CGPoint point = rect.rect.origin;
    CGPoint center = [self convertPoint:point toView:self.window];
    if (!_state.showingMagnifier) {
        _state.showingMagnifier = true;
        self.magnifier.captureFadeAnimation = true;
        [self.magnifier showMagnifierOnWindow:self.window point:center];
    } else {
        [self.magnifier moveMagnifierToPoint:center];
    }
    
    CGSize snapshotSize = self.magnifier.snapshotSize;
    UIGraphicsBeginImageContextWithOptions(snapshotSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!context) return;
    
    CGFloat offset = 5;
    CGContextTranslateCTM(context, -center.x + snapshotSize.width / 2, -center.y + offset);
    
    [self.window.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.magnifier.snapshot = image;
    
}

- (void)_hideMagnifier {
    _state.showingMagnifier = false;
    [self.magnifier hideMagnifier];
}

- (void)_endTouch {
    [self _endLongPressTimer];
    [self _removeHighlightAnimated:YES];
}

- (void)_endTouchTracking {
    if (_state.trackingGrabber == LYSelectionGrabberTypeNone) {
        return;
    }
    _state.trackingGrabber = LYSelectionGrabberTypeNone;
    [self _hideMagnifier];
    if (self.selectionDelegate && [self.selectionDelegate respondsToSelector:@selector(labelDidEndTrackingGrabber:)]) {
        [self.selectionDelegate labelDidEndTrackingGrabber:self];
    }
}

- (void)_showMenu {
    if (_selectionView.selectionRects.count < 3) {
        return;
    }
    LYTextSelectionRect *sRect = _selectionView.selectionRects[2];
    CGRect rect = sRect.rect;
    if (self.selectionDelegate && [self.selectionDelegate respondsToSelector:@selector(labelShouldShowMenu:selectionView:selectedRange:selectionRect:)]) {
        BOOL showingMenu = [self.selectionDelegate labelShouldShowMenu:self selectionView:self.selectionView selectedRange:_selectedTextRange selectionRect:rect];
        _state.showingMenu = showingMenu;
    }
}

- (void)_hideMenu {
    if (self.selectionDelegate && [self.selectionDelegate respondsToSelector:@selector(labelShouldHideMenu:selectedRange:)]) {
        BOOL hideMenu = [self.selectionDelegate labelShouldHideMenu:self selectedRange:_selectedTextRange];
        _state.showingMenu = !hideMenu;
    }
}

#pragma mark - Public Method

- (void)selectAllText {
    [self _updateSelectedRange:[LYTextRange rangeWithRange:NSMakeRange(0, _innerText.length)]];
}

- (void)endTextSelecting {
    self.selectedTextRange = [LYTextRange rangeWithRange:NSMakeRange(0, 0)];
}

#pragma mark - Dealloc

- (void)dealloc {
    [self _hideMagnifier];
}

@end
