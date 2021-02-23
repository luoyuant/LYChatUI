//
//  LYTextLine.m
//  LYChatUI
//
//  Created by luoyuan on 2021/1/20.
//

#import "LYTextLine.h"

@interface LYTextLine ()

@property (nonatomic) CGFloat firstGlyphPositionX;

@end

@implementation LYTextLine

+ (instancetype)lineWithCTLine:(CTLineRef)lineRef position:(CGPoint)position {
    if (!lineRef) return nil;
    LYTextLine *line = [self new];
    line->_position = position;
    [line setLineRef:lineRef];
    return line;
}

- (void)setLineRef:(CTLineRef _Nonnull)lineRef {
    if (_lineRef != lineRef) {
        if (lineRef) CFRetain(lineRef);
        if (_lineRef) CFRelease(_lineRef);
        _lineRef = lineRef;
        if (_lineRef) {
            _lineWidth = CTLineGetTypographicBounds(_lineRef, &_ascent, &_descent, &_leading);
            CFRange range = CTLineGetStringRange(_lineRef);
            _range = NSMakeRange(range.location, range.length);
            if (CTLineGetGlyphCount(_lineRef) > 0) {
                CFArrayRef runs = CTLineGetGlyphRuns(_lineRef);
                CTRunRef run = CFArrayGetValueAtIndex(runs, 0);
                CGPoint pos;
                CTRunGetPositions(run, CFRangeMake(0, 1), &pos);
                _firstGlyphPositionX = pos.x;
            } else {
                _firstGlyphPositionX = 0;
            }
            _trailingWhitespaceWidth = CTLineGetTrailingWhitespaceWidth(_lineRef);
        } else {
            _lineWidth = _ascent = _descent = _leading = _firstGlyphPositionX = _trailingWhitespaceWidth = 0;
            _range = NSMakeRange(0, 0);
        }
        [self reloadBounds];
    }
}

- (void)reloadBounds {
    _bounds = CGRectMake(_position.x, _position.y - _ascent, _lineWidth, _ascent + _descent);
    _bounds.origin.x += _firstGlyphPositionX;
}

#pragma mark - Dealloc

- (void)dealloc {
    if (_lineRef) CFRelease(_lineRef);
}

@end
