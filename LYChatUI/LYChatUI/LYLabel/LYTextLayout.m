//
//  LYTextLayout.m
//  LYChatUI
//
//  Created by luoyuan on 2021/1/22.
//

#import "LYTextLayout.h"
#import "LYLabel.h"

NSString *const LYTextHighlightAttributeName = @"LYTextHighlight";
const CGSize LYTextContainerMaxSize = (CGSize) {0x100000, 0x100000};

static inline BOOL LYTextIsLinebreakChar(unichar c) {
    switch (c) {
        case 0x000D:
        case 0x2028:
        case 0x000A:
        case 0x2029:
            return YES;
        default:
            return NO;
    }
}

static inline UIEdgeInsets LYTextUIEdgeInsetsInvert(UIEdgeInsets insets) {
    return UIEdgeInsetsMake(-insets.top, -insets.left, -insets.bottom, -insets.right);
}

static inline BOOL LYTextIsLinebreakString(NSString * _Nullable str) {
    if (str.length > 2 || str.length == 0) return NO;
    if (str.length == 1) {
        unichar c = [str characterAtIndex:0];
        return LYTextIsLinebreakChar(c);
    } else {
        return ([str characterAtIndex:0] == '\r') && ([str characterAtIndex:1] == '\n');
    }
}

@interface LYTextLayout ()

@property (nonatomic, readwrite) NSAttributedString *text;
@property (nonatomic, readwrite) NSRange range;
@property (nonatomic, readwrite) CTFramesetterRef framesetterRef;
@property (nonatomic, readwrite) CTFrameRef frameRef;
@property (nonatomic, readwrite) NSArray<LYTextLine *> *lines;
@property (nonatomic, readwrite) LYTextLine *truncatedLine;
@property (nonatomic, readwrite) NSUInteger rowCount;
@property (nonatomic, readwrite) NSRange visibleRange;
@property (nonatomic, readwrite) CGRect textBoundingRect;
@property (nonatomic, readwrite) CGSize textBoundingSize;

@end

@implementation LYTextLayout

#pragma mark - Setter

- (void)setFrameRef:(CTFrameRef)frameRef {
    if (_frameRef != frameRef) {
        if (frameRef) CFRetain(frameRef);
        if (_frameRef) CFRelease(_frameRef);
        _frameRef = frameRef;
    }
}

- (void)setFramesetterRef:(CTFramesetterRef)framesetterRef {
    if (_framesetterRef != framesetterRef) {
        if (framesetterRef) CFRetain(framesetterRef);
        if (_framesetterRef) CFRelease(_framesetterRef);
        _framesetterRef = framesetterRef;
    }
}

- (void)setHighlightRanges:(NSArray<NSValue *> * _Nonnull)highlightRanges {
    _highlightRanges = highlightRanges;
}

#pragma mark - Init

- (instancetype)_init {
    self = [super init];
    return self;
}

+ (nullable LYTextLayout *)layoutWithLabel:(LYLabel *)label text:(NSAttributedString *)text {
    return [LYTextLayout layoutWithLabel:label text:text range:NSMakeRange(0, text.length) bounds:label.bounds];
}

+ (nullable LYTextLayout *)layoutWithLabel:(LYLabel *)label text:(NSAttributedString *)text bounds:(CGRect)bounds {
    return [LYTextLayout layoutWithLabel:label text:text range:NSMakeRange(0, text.length) bounds:bounds];
}

+ (nullable LYTextLayout *)layoutWithLabel:(LYLabel *)label text:(NSAttributedString *)text range:(NSRange)range bounds:(CGRect)bounds {
    if (!label) return nil;
    if (!text) return nil;
    if (range.location + range.length > text.length) return nil;
    
    LYTextLayout *layout = [[LYTextLayout alloc] _init];
    layout.text = text;
    layout.range = range;
    
    NSMutableArray<LYTextLine *> *lines = nil;
    CFArrayRef cfLines = nil;
    NSUInteger lineCount = 0;
    CGPoint *lineOrigins = NULL;

    NSAttributedString *truncationToken = nil;
    LYTextLine *truncatedLine = nil;
    
    CGRect rect = bounds;
    rect = UIEdgeInsetsInsetRect(rect, label.textContentInsets);
    CGRect cgPathBox = {0};
    rect = CGRectStandardize(rect);
    cgPathBox = rect;
    rect = CGRectApplyAffineTransform(rect, CGAffineTransformMakeScale(1, -1));
    CGPathRef path = CGPathCreateWithRect(rect, NULL);
//    if (!path) goto fail;
    
    CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString((CFTypeRef)text);
//    if (!framesetterRef) goto fail;
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(0, [text length]), path, NULL);
    if (!frameRef) goto fail;
    
    lines = [NSMutableArray array];
    cfLines = CTFrameGetLines(frameRef);
    lineCount = CFArrayGetCount(cfLines);
    if (lineCount > 0) {
        lineOrigins = malloc(lineCount * sizeof(CGPoint));
        if (lineOrigins == NULL) goto fail;
        CTFrameGetLineOrigins(frameRef, CFRangeMake(0, lineCount), lineOrigins);
    }
    
    CGRect textBoundingRect = CGRectZero;
    CGSize textBoundingSize = CGSizeZero;
    NSInteger rowIdx = -1;
    NSUInteger rowCount = 0;
    CGRect lastRect = CGRectMake(0, -FLT_MAX, 0, 0);
    CGPoint lastPosition = CGPointMake(0, -FLT_MAX);
    
    NSUInteger lineCurrentIdx = 0;
    
    NSUInteger maximumNumberOfRows = label.numberOfLines;
    
    for (NSUInteger i = 0; i < lineCount; i++) {
        CTLineRef ctLine = CFArrayGetValueAtIndex(cfLines, i);
        CFArrayRef ctRuns = CTLineGetGlyphRuns(ctLine);
        if (!ctRuns || CFArrayGetCount(ctRuns) == 0) continue;
        
        // CoreText coordinate system
        CGPoint ctLineOrigin = lineOrigins[i];
        
        // UIKit coordinate system
        CGPoint position;
        position.x = cgPathBox.origin.x + ctLineOrigin.x;
        position.y = cgPathBox.size.height + cgPathBox.origin.y - ctLineOrigin.y;
        
        LYTextLine *line = [LYTextLine lineWithCTLine:ctLine position:position];
        CGRect rect = line.bounds;
        
        rowIdx++;
        lastRect = rect;
        lastPosition = position;
        
        line.index = lineCurrentIdx;
        line.row = rowIdx;
        [lines addObject:line];
        rowCount = rowIdx + 1;
        lineCurrentIdx ++;
        
        if (i == 0) {
            textBoundingRect = rect;
        } else {
            if (maximumNumberOfRows == 0 || rowIdx < maximumNumberOfRows) {
                textBoundingRect = CGRectUnion(textBoundingRect, rect);
            }
        }
    }
    
    textBoundingSize = textBoundingRect.size;
    
    BOOL needTruncation = false;
    
    if (rowCount > 0) {
        if (maximumNumberOfRows > 0 && rowCount > maximumNumberOfRows) {
            needTruncation = YES;
            rowCount = maximumNumberOfRows;
            do {
                LYTextLine *line = lines.lastObject;
                if (!line) break;
                if (line.row < rowCount) break;
                [lines removeLastObject];
            } while (true);
        }
        
        LYTextLine *lastLine = lines.lastObject;
        if (!needTruncation && lastLine.range.location + lastLine.range.length < text.length) {
            needTruncation = YES;
        }
        
        NSInteger lastRowIdx = -1;
        CGFloat lastTop = 0;
        CGFloat lastBottom = 0;
        for (NSUInteger i = 0, max = lines.count; i < max; i++) {
            LYTextLine *line = lines[i];
            CGRect rect = line.bounds;
            if ((NSInteger)line.row != lastRowIdx) {
                if (lastRowIdx >= 0) {
                    lines[lastRowIdx].edge = (LYTextLineEdge) { .top = lastTop, .bottom = lastBottom };
                }
                lastRowIdx = line.row;
                
                lastTop = rect.origin.y;
                lastBottom = lastTop + rect.size.height;
            } else { //同一行，样式不同的情况
                lastTop = MIN(lastTop, rect.origin.y);
                lastBottom = MAX(lastBottom, rect.origin.y + rect.size.height);
            }
        }
        lines[lastRowIdx].edge = (LYTextLineEdge) { .top = lastTop, .bottom = lastBottom };
        
        for (NSUInteger i = 0; i < rowCount - 1; i++) {
            LYTextLine *line0 = lines[i];
            LYTextLine *line1 = lines[i + 1];
            CGFloat v = (line0.edge.bottom + line1.edge.top) / 2;
            line0.edge = (LYTextLineEdge) { .top = line0.edge.top, .bottom = v };
            line1.edge = (LYTextLineEdge) { .top = v, .bottom = line1.edge.bottom };
        }
        
    }
    
    { // calculate bounding size
        CGRect rect = textBoundingRect;

        rect = UIEdgeInsetsInsetRect(rect, LYTextUIEdgeInsetsInvert(label.textContentInsets));
        
        rect = CGRectStandardize(rect);
        CGSize size = rect.size;
   
        size.width += rect.origin.x;
        
        size.height += rect.origin.y;
        if (size.width < 0) size.width = 0;
        if (size.height < 0) size.height = 0;
        size.width = ceil(size.width);
        size.height = ceil(size.height);
        textBoundingSize = size;
    }
    
    CFRange cfVisibleRange = CTFrameGetVisibleStringRange(frameRef);
    NSRange visibleRange = NSMakeRange(cfVisibleRange.location, cfVisibleRange.length);
    
    if (needTruncation) {
        LYTextLine *lastLine = lines.lastObject;
        NSRange lastRange = lastLine.range;
        visibleRange.length = lastRange.location + lastRange.length - visibleRange.location;
        
        // create truncated line
        if (label.truncationType != LYTextTruncationTypeNone) {
            CTLineRef truncationTokenLine = NULL;
            if (label.truncationToken) {
                truncationToken = label.truncationToken;
                truncationTokenLine = CTLineCreateWithAttributedString((CFAttributedStringRef)truncationToken);
            } else {
                CFArrayRef runs = CTLineGetGlyphRuns(lastLine.lineRef);
                NSUInteger runCount = CFArrayGetCount(runs);
                NSMutableDictionary *attrs = nil;
                if (runCount > 0) {
                    CTRunRef run = CFArrayGetValueAtIndex(runs, runCount - 1);
                    attrs = (id)CTRunGetAttributes(run);
                    attrs = attrs ? attrs.mutableCopy : [NSMutableArray new];
                    [attrs removeObjectsForKeys:[NSMutableAttributedString ly_allDiscontinuousAttributeKeys]];
                    CTFontRef font = (__bridge CFTypeRef)attrs[(id)kCTFontAttributeName];
                    CGFloat fontSize = font ? CTFontGetSize(font) : 12.0;
                    UIFont *uiFont = [UIFont systemFontOfSize:fontSize * 0.9];
                    if (uiFont) {
                        NSString *fontName = uiFont.fontName;
                        if ([fontName isEqualToString:@".SFUI-Regular"]) {
                            fontName = @"TimesNewRomanPSMT";
                        }
                        font = CTFontCreateWithName((__bridge CFStringRef)fontName, uiFont.pointSize, NULL);
                    } else {
                        font = NULL;
                    }
                    if (font) {
                        attrs[(id)kCTFontAttributeName] = (__bridge id)(font);
                        uiFont = nil;
                        CFRelease(font);
                    }
                    CGColorRef color = (__bridge CGColorRef)(attrs[(id)kCTForegroundColorAttributeName]);
                    if (color && CFGetTypeID(color) == CGColorGetTypeID() && CGColorGetAlpha(color) == 0) {
                        // ignore clear color
                        [attrs removeObjectForKey:(id)kCTForegroundColorAttributeName];
                    }
                    if (!attrs) attrs = [NSMutableDictionary new];
                }
                truncationToken = [[NSAttributedString alloc] initWithString:LYTextTruncationToken attributes:attrs];
                truncationTokenLine = CTLineCreateWithAttributedString((CFAttributedStringRef)truncationToken);
            }
            if (truncationTokenLine) {
                CTLineTruncationType type = kCTLineTruncationEnd;
                if (label.truncationType == LYTextTruncationTypeStart) {
                    type = kCTLineTruncationStart;
                } else if (label.truncationType == LYTextTruncationTypeMiddle) {
                    type = kCTLineTruncationMiddle;
                }
                NSMutableAttributedString *lastLineText = [text attributedSubstringFromRange:lastLine.range].mutableCopy;
                [lastLineText appendAttributedString:truncationToken];
                CTLineRef ctLastLineExtend = CTLineCreateWithAttributedString((CFAttributedStringRef)lastLineText);
                if (ctLastLineExtend) {
                    CGFloat truncatedWidth = CGRectGetWidth(lastLine.bounds);
                    CGRect cgPathRect = CGRectZero;
                    if (CGPathIsRect(path, &cgPathRect)) {
                        truncatedWidth = cgPathRect.size.width;
                    }
                    CTLineRef ctTruncatedLine = CTLineCreateTruncatedLine(ctLastLineExtend, truncatedWidth, type, truncationTokenLine);
                    CFRelease(ctLastLineExtend);
                    if (ctTruncatedLine) {
                        truncatedLine = [LYTextLine lineWithCTLine:ctTruncatedLine position:lastLine.position];
                        truncatedLine.index = lastLine.index;
                        truncatedLine.row = lastLine.row;
                        CFRelease(ctTruncatedLine);
                    }
                }
                CFRelease(truncationTokenLine);
            }
        }
    }
    
    if (visibleRange.length > 0) {
        NSMutableArray<NSValue *> *highlightRanges = [NSMutableArray array];
        [layout.text enumerateAttributesInRange:visibleRange options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
            if (attrs[LYTextHighlightAttributeName]) {
                [highlightRanges addObject:[NSValue valueWithRange:range]];
            }
        }];
        layout.highlightRanges = highlightRanges;
    }
    
    layout.framesetterRef = framesetterRef;
    layout.frameRef = frameRef;
    layout.lines = lines;
    layout.truncatedLine = truncatedLine;
    layout.rowCount = rowCount;
    layout.visibleRange = visibleRange;
    layout.textBoundingRect = textBoundingRect;
    layout.textBoundingSize = textBoundingSize;
    CFRelease(path);
    CFRelease(framesetterRef);
    CFRelease(frameRef);
    if (lineOrigins) free(lineOrigins);
    return layout;
    
fail:
    if (path) CFRelease(path);
    if (framesetterRef) CFRelease(framesetterRef);
    if (frameRef) CFRelease(frameRef);
    
    return nil;
}

+ (CGSize)sizeThatFits:(CGSize)fitsSize text:(NSAttributedString *)text textContentInsets:(UIEdgeInsets)textContentInsets {
    if (!text.length) return CGSizeZero;
    CGSize size = CGSizeMake(fitsSize.width, fitsSize.height);
    if (size.width <= 0) size.width = LYTextContainerMaxSize.width;
    size.height = LYTextContainerMaxSize.height;
        
    NSMutableArray<LYTextLine *> *lines = nil;
    CFArrayRef cfLines = nil;
    NSUInteger lineCount = 0;
    CGPoint *lineOrigins = NULL;
    
    CGRect rect = {CGPointZero, size};
    rect = UIEdgeInsetsInsetRect(rect, textContentInsets);
    CGRect cgPathBox = {0};
    rect = CGRectStandardize(rect);
    cgPathBox = rect;
    rect = CGRectApplyAffineTransform(rect, CGAffineTransformMakeScale(1, -1));
    CGPathRef path = CGPathCreateWithRect(rect, NULL);
//    if (!path) goto fail;
    
    CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString((CFTypeRef)text);
//    if (!framesetterRef) goto fail;
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(0, [text length]), path, NULL);
    if (!frameRef) goto fail;
    
    lines = [NSMutableArray array];
    cfLines = CTFrameGetLines(frameRef);
    lineCount = CFArrayGetCount(cfLines);
    if (lineCount > 0) {
        lineOrigins = malloc(lineCount * sizeof(CGPoint));
        if (lineOrigins == NULL) goto fail;
        CTFrameGetLineOrigins(frameRef, CFRangeMake(0, lineCount), lineOrigins);
    }
    
    CGRect textBoundingRect = CGRectZero;
    CGSize textBoundingSize = CGSizeZero;
    NSInteger rowIdx = -1;
    NSUInteger rowCount = 0;
    CGRect lastRect = CGRectMake(0, -FLT_MAX, 0, 0);
    CGPoint lastPosition = CGPointMake(0, -FLT_MAX);
    
    NSUInteger lineCurrentIdx = 0;
    
    for (NSUInteger i = 0; i < lineCount; i++) {
        CTLineRef ctLine = CFArrayGetValueAtIndex(cfLines, i);
        CFArrayRef ctRuns = CTLineGetGlyphRuns(ctLine);
        if (!ctRuns || CFArrayGetCount(ctRuns) == 0) continue;
        
        // CoreText coordinate system
        CGPoint ctLineOrigin = lineOrigins[i];
        
        // UIKit coordinate system
        CGPoint position;
        position.x = cgPathBox.origin.x + ctLineOrigin.x;
        position.y = cgPathBox.size.height + cgPathBox.origin.y - ctLineOrigin.y;
        
        LYTextLine *line = [LYTextLine lineWithCTLine:ctLine position:position];
        CGRect rect = line.bounds;
        
        rowIdx++;
        lastRect = rect;
        lastPosition = position;
        
        line.index = lineCurrentIdx;
        line.row = rowIdx;
        [lines addObject:line];
        rowCount = rowIdx + 1;
        lineCurrentIdx ++;
        
        if (i == 0) {
            textBoundingRect = rect;
        } else {
            textBoundingRect = CGRectUnion(textBoundingRect, rect);
//            if (textBoundingRect.size.width < size.width) {
//                textBoundingRect.size.width = size.width;
//            }
        }
    }
    
    textBoundingSize = textBoundingRect.size;
        
    if (rowCount > 0) {
        NSInteger lastRowIdx = -1;
        CGFloat lastTop = 0;
        CGFloat lastBottom = 0;
        for (NSUInteger i = 0, max = lines.count; i < max; i++) {
            LYTextLine *line = lines[i];
            CGRect rect = line.bounds;
            if ((NSInteger)line.row != lastRowIdx) {
                if (lastRowIdx >= 0) {
                    lines[lastRowIdx].edge = (LYTextLineEdge) { .top = lastTop, .bottom = lastBottom };
                }
                lastRowIdx = line.row;
                
                lastTop = rect.origin.y;
                lastBottom = lastTop + rect.size.height;
            } else { //同一行，样式不同的情况
                lastTop = MIN(lastTop, rect.origin.y);
                lastBottom = MAX(lastBottom, rect.origin.y + rect.size.height);
            }
        }
        lines[lastRowIdx].edge = (LYTextLineEdge) { .top = lastTop, .bottom = lastBottom };
        
        for (NSUInteger i = 0; i < rowCount - 1; i++) {
            LYTextLine *line0 = lines[i];
            LYTextLine *line1 = lines[i + 1];
            CGFloat v = (line0.edge.bottom + line1.edge.top) / 2;
            line0.edge = (LYTextLineEdge) { .top = line0.edge.top, .bottom = v };
            line1.edge = (LYTextLineEdge) { .top = v, .bottom = line1.edge.bottom };
        }
        
    }
    
    { // calculate bounding size
        CGRect rect = textBoundingRect;

        rect = UIEdgeInsetsInsetRect(rect, LYTextUIEdgeInsetsInvert(textContentInsets));
        
        rect = CGRectStandardize(rect);
        CGSize size = rect.size;
   
        size.width += rect.origin.x;
        
        size.height += rect.origin.y;
        if (size.width < 0) size.width = 0;
        if (size.height < 0) size.height = 0;
        size.width = ceil(size.width);
        size.height = ceil(size.height);
        textBoundingSize = size;
    }
        
    CFRelease(path);
    CFRelease(framesetterRef);
    CFRelease(frameRef);
    if (lineOrigins) free(lineOrigins);
    return textBoundingSize;
    
fail:
    if (path) CFRelease(path);
    if (framesetterRef) CFRelease(framesetterRef);
    if (frameRef) CFRelease(frameRef);
    
    return CGSizeZero;
}

#pragma mark - Public Method

- (NSArray<LYTextSelectionRect *> *)selectionRectsForRange:(LYTextRange *)textRange {
    NSRange range = [textRange asRange];
    NSMutableArray<LYTextSelectionRect *> *rects = [NSMutableArray array];
    if (range.location + range.length <= 0) return rects;
    if (range.location < _range.location) return rects;
    if (range.location + range.length > _range.location + _range.length) return rects;
    
    NSUInteger startLocation = range.location;
    NSUInteger endLocation = range.location + range.length;
    
    NSUInteger startLineIndex = [self lineIndexForTextPosition:textRange.start];
    NSUInteger endLineIndex = [self lineIndexForTextPosition:textRange.end];
    if (startLineIndex == NSNotFound || endLineIndex == NSNotFound) return rects;

    LYTextLine *startLine = _lines[startLineIndex];
    LYTextLine *endLine = _lines[endLineIndex];
    CGFloat startOffset = [self offsetForTextPosition:startLocation lineIndex:startLineIndex];
    CGFloat endOffset = [self offsetForTextPosition:endLocation lineIndex:endLineIndex];
    if (startOffset == CGFLOAT_MAX || endOffset == CGFLOAT_MAX) return rects;
    
    LYTextSelectionRect *startRect = [LYTextSelectionRect new];
    startRect.containsStart = true;
    startRect.rect = CGRectMake(startOffset, startLine.bounds.origin.y, 0, startLine.bounds.size.height);
    [rects addObject:startRect];
    
    LYTextSelectionRect *endRect = [LYTextSelectionRect new];
    endRect.containsEnd = true;
    endRect.rect = CGRectMake(endOffset, endLine.bounds.origin.y, 0, endLine.bounds.size.height);
    [rects addObject:endRect];
    
    if (startLine.row == endLine.row) {
        LYTextSelectionRect *rect = [LYTextSelectionRect new];
        rect.rect = CGRectMake(startOffset, startLine.bounds.origin.y, endOffset - startOffset, MAX(startLine.bounds.size.height, endLine.bounds.size.height));
        [rects addObject:rect];
        return rects;
    }
    
    LYTextSelectionRect *topRect = [LYTextSelectionRect new];
    topRect.rect = CGRectMake(startOffset, startLine.edge.top, _textBoundingRect.size.width - startOffset + _textBoundingRect.origin.x, startLine.edge.bottom - startLine.edge.top);
    [rects addObject:topRect];
    
    LYTextSelectionRect *bottomRect = [LYTextSelectionRect new];
    CGFloat left = endLine.bounds.origin.x;
    bottomRect.rect = CGRectMake(left, endLine.edge.top, endOffset - left, endLine.edge.bottom - endLine.edge.top);
    [rects addObject:bottomRect];
    
    if (endLineIndex - startLineIndex >= 2) {
        CGRect r = CGRectMake(_textBoundingRect.origin.x, CGRectGetMaxY(topRect.rect), _textBoundingRect.size.width, bottomRect.rect.origin.y - CGRectGetMaxY(topRect.rect));
        LYTextSelectionRect *rect = [LYTextSelectionRect new];
        rect.rect = r;
        [rects addObject:rect];
    }
    
    return rects;
}


- (CGFloat)offsetForTextPosition:(NSUInteger)position lineIndex:(NSUInteger)lineIndex {
    if (lineIndex >= _lines.count) return CGFLOAT_MAX;
    LYTextLine *line = _lines[lineIndex];
    NSRange range = line.range;
    if (position < range.location || position > range.location + range.length) return CGFLOAT_MAX;
    
    CGFloat offset = CTLineGetOffsetForStringIndex(line.lineRef, position, NULL);
    return (offset + line.position.x);
}

- (LYTextPosition *)closestPositionToPoint:(CGPoint)point {
    point.x += 0.00001234;
    NSUInteger lineIndex = [self closestLineIndexForPoint:point];
    if (lineIndex == NSNotFound) return nil;
    NSUInteger position = [self textPositionForPoint:point lineIndex:lineIndex];
    if (position == NSNotFound) return nil;
    
    if (position <= _visibleRange.location) {
        return [LYTextPosition positionWithOffset:_visibleRange.location affinity:LYTextAffinityForward];
    } else if (position >= _visibleRange.location + _visibleRange.length) {
        return [LYTextPosition positionWithOffset:_visibleRange.location + _visibleRange.length affinity:LYTextAffinityBackward];
    }
    
    LYTextLine *line = _lines[lineIndex];
    
    // empty line
    if (line.range.length == 0) {
        BOOL behind = (_lines.count > 1 && lineIndex == _lines.count - 1);  //end line
        return [LYTextPosition positionWithOffset:line.range.location affinity:behind ? LYTextAffinityBackward : LYTextAffinityForward];
    }
    
    // detect weather the line is a linebreak token
    if (line.range.length <= 2) {
        NSString *str = [_text.string substringWithRange:line.range];
        if (LYTextIsLinebreakString(str)) { // an empty line ("\r", "\n", "\r\n")
            return [LYTextPosition positionWithOffset:line.range.location];
        }
    }
    
    LYTextAffinity finalAffinity = LYTextAffinityForward;
    BOOL finalAffinityDetected = NO;
    
//    // above whole text frame
//    if (lineIndex == 0 && (point.y < CGRectGetMinY(line.bounds))) {
//        position = 0;
//        finalAffinity = LYTextAffinityForward;
//        finalAffinityDetected = YES;
//    }
//    // below whole text frame
//    if (lineIndex == _lines.count - 1 && (point.y > CGRectGetMaxY(line.bounds))) {
//        position = line.range.location + line.range.length;
//        finalAffinity = LYTextAffinityBackward;
//        finalAffinityDetected = YES;
//    }
    
    // There must be at least one non-linebreak char,
    // ignore the linebreak characters at line end if exists.
    if (position >= line.range.location + line.range.length - 1) {
        if (position > line.range.location) {
            unichar c1 = [_text.string characterAtIndex:position - 1];
            if (LYTextIsLinebreakChar(c1)) {
                position--;
                if (position > line.range.location) {
                    unichar c0 = [_text.string characterAtIndex:position - 1];
                    if (LYTextIsLinebreakChar(c0)) {
                        position--;
                    }
                }
            }
        }
    }
    
    if (position == line.range.location) {
        return [LYTextPosition positionWithOffset:position];
    }
    if (position == line.range.location + line.range.length) {
        LYTextPosition *pos = [LYTextPosition positionWithOffset:position affinity:LYTextAffinityBackward];
        pos.isCurrentLineLastPosition = true;
        return pos;
    }
    
    if (!finalAffinityDetected) {
        CGFloat ofs = [self offsetForTextPosition:position lineIndex:lineIndex];
        if (ofs != CGFLOAT_MAX) {
            BOOL RTL = [self _isRightToLeftInLine:line atPoint:point];
            if (position >= line.range.location + line.range.length) {
                finalAffinity = RTL ? LYTextAffinityForward : LYTextAffinityBackward;
            } else if (position <= line.range.location) {
                finalAffinity = RTL ? LYTextAffinityBackward : LYTextAffinityForward;
            } else {
                finalAffinity = (ofs < point.x && !RTL) ? LYTextAffinityForward : LYTextAffinityBackward;
            }
        }
    }
    
    return [LYTextPosition positionWithOffset:position affinity:finalAffinity];
}

- (NSUInteger)textPositionForPoint:(CGPoint)point lineIndex:(NSUInteger)lineIndex {
    if (lineIndex >= _lines.count) return NSNotFound;
    LYTextLine *line = _lines[lineIndex];
    point.x -= line.position.x;
    point.y = 0;
    CFIndex idx = CTLineGetStringIndexForPosition(line.lineRef, point);
    if (idx == kCFNotFound) return NSNotFound;
    return idx;
}

- (NSUInteger)lineIndexForTextPosition:(LYTextPosition *)textPosition {
    NSInteger location = textPosition.offset;
    if (location < _range.location || location > _range.location + _range.length) return NSNotFound;
    if (_lines.count == 0) return NSNotFound;
    NSUInteger lineIndex = NSNotFound;
    NSUInteger startIndex = 0, endIndex = _lines.count - 1, midIndex = 0;
    
    NSRange firstRange = _lines.firstObject.range;
    NSRange lastRange = _lines.lastObject.range;
    
    if (location < firstRange.location + firstRange.length) {
        return startIndex;
    }

    if (location > lastRange.location) {
        return endIndex;
    }
    
    if (textPosition.affinity == LYTextAffinityBackward) {
        while (startIndex <= endIndex) {
            midIndex = (startIndex + endIndex) / 2;
            LYTextLine *line = _lines[midIndex];
            NSRange range = line.range;
            if (range.location < location && location <= range.location + range.length) {
                lineIndex = midIndex;
                break;
            }
            if (location <= range.location) {
                if (midIndex == 0) break;
                endIndex = midIndex - 1;
            } else {
                startIndex = midIndex + 1;
            }
        }
    } else {
        while (startIndex <= endIndex) {
            midIndex = (startIndex + endIndex) / 2;
            LYTextLine *line = _lines[midIndex];
            NSRange range = line.range;
            if (range.location <= location && location < range.location + range.length) {
                lineIndex = midIndex;
                break;
            }
            if (location < range.location) {
                if (midIndex == 0) break;
                endIndex = midIndex - 1;
            } else {
                startIndex = midIndex + 1;
            }
        }
    }
    
    
    
    return lineIndex;
}

- (NSUInteger)closestLineIndexForPoint:(CGPoint)point {
    if (_lines.count == 0 || _rowCount == 0) return NSNotFound;
    LYTextLine *firstLine = _lines.firstObject;
    LYTextLine *lastLine = _lines.lastObject;
    NSUInteger lineIndex = NSNotFound;
    if (_lines.count == 1) {
        lineIndex = 0;
    }
    else if (point.y <= firstLine.edge.bottom) {
        lineIndex = 0;
    } else if (point.y >= lastLine.edge.top) {
        lineIndex = _lines.count - 1;
    }
    else {
        lineIndex = [self rowIndexForPoint:point];
    }
    return lineIndex;
}

- (NSUInteger)rowIndexForPoint:(CGPoint)point {
    if (_lines.count == 0 || _rowCount == 0) return NSNotFound;
    NSUInteger rowIdx = NSNotFound;
    NSUInteger startIndex = 0, endIndex = _rowCount - 1, midIndex = 0;
    
    while (startIndex <= endIndex) {
        midIndex = (startIndex + endIndex) / 2;
        LYTextLineEdge edge = _lines[midIndex].edge;
        if (edge.top <= point.y && point.y <= edge.bottom) {
          rowIdx = midIndex;
          break;
        }
        if (point.y < edge.top) {
            if (midIndex == 0) break;
            endIndex = midIndex - 1;
        } else {
            startIndex = midIndex + 1;
        }
    }
    
    return rowIdx;
}

- (BOOL)_isRightToLeftInLine:(LYTextLine *)line atPoint:(CGPoint)point {
    if (!line) return NO;
    // get write direction
    BOOL RTL = NO;
    CFArrayRef runs = CTLineGetGlyphRuns(line.lineRef);
    for (NSUInteger r = 0, max = CFArrayGetCount(runs); r < max; r++) {
        CTRunRef run = CFArrayGetValueAtIndex(runs, r);
        CGPoint glyphPosition;
        CTRunGetPositions(run, CFRangeMake(0, 1), &glyphPosition);
        CGFloat runX = glyphPosition.x;
        runX += line.position.x;
        CGFloat runWidth = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), NULL, NULL, NULL);
        if (runX <= point.x && point.x <= runX + runWidth) {
            if (CTRunGetStatus(run) & kCTRunStatusRightToLeft) RTL = YES;
            break;
        }
    }
    return RTL;
}


#pragma mark - Dealloc

- (void)dealloc {
    if (_frameRef) CFRelease(_frameRef);
    if (_framesetterRef) CFRelease(_framesetterRef);
}

@end
