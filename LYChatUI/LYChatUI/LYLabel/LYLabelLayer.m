//
//  LYLabelLayer.m
//  LYChatUI
//
//  Created by luoyuan on 2021/1/19.
//

#import "LYLabelLayer.h"
#import <CoreText/CTFramesetter.h>
#import <CoreText/CTRun.h>

@interface LYLabelLayer ()

@end

@implementation LYLabelLayer

- (instancetype)init {
    self = [super init];
    static CGFloat scale;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        scale = [UIScreen mainScreen].scale;
    });
    self.contentsScale = scale;
    return self;
}

- (void)display {
    
    [self _display];
    
}

- (void)_display {
    __strong id<LYLabelLayerDelegate> delegate = (id)self.delegate;
    
    NSAttributedString *attributedString = [delegate textForDisplay];
    if (!attributedString || [NSNull isEqual:attributedString]) {
        return;
    }
    
    LYTextLayout *layout = [delegate layoutForDisplay];
    if (!layout) {
        return;
    }
    
    CGSize size = self.bounds.size;
    BOOL opaque = self.opaque;
    CGFloat scale = self.contentsScale;
    UIGraphicsBeginImageContextWithOptions(size, opaque, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self _drawBackgroundColorWithLayout:layout context:context size:size];
    [self _drawTextWithLayout:layout context:context size:size];

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.contents = (__bridge id)(image.CGImage);

    [delegate didEndDisplay];
        
}

- (void)_drawTextWithLayout:(LYTextLayout *)layout context:(CGContextRef)context size:(CGSize)size {
    CGContextSaveGState(context);
    {
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextTranslateCTM(context, 0, size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        NSArray<LYTextLine *> *lines = layout.lines;
        for (NSUInteger i = 0; i < lines.count; i++) {
            LYTextLine *line = lines[i];
            if (layout.truncatedLine && layout.truncatedLine.index == line.index) {
                line = layout.truncatedLine;
            }
            CFArrayRef runs = CTLineGetGlyphRuns(line.lineRef);
            NSUInteger runsCount = CFArrayGetCount(runs);
            CGFloat posX = line.position.x;
            CGFloat posY = size.height - line.position.y;
            CGContextSetTextPosition(context, posX, posY);
            for (NSUInteger j = 0; j < runsCount; j++) {
                CTRunRef run = CFArrayGetValueAtIndex(runs, j);
                CTRunDraw(run, context, CFRangeMake(0, 0));
            }
        }
    }
    CGContextSaveGState(context);
}

- (void)_drawBackgroundColorWithLayout:(LYTextLayout *)layout context:(CGContextRef)context size:(CGSize)size {
    CGContextSaveGState(context);
    {
        if (!self.backgroundColor || CGColorGetAlpha(self.backgroundColor) < 1) {
            CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
            CGContextAddRect(context, CGRectMake(0, 0, size.width, size.height));
            CGContextFillPath(context);
        }
        if (self.backgroundColor) {
            CGContextSetFillColorWithColor(context, self.backgroundColor);
            CGContextAddRect(context, CGRectMake(0, 0, size.width, size.height));
            CGContextFillPath(context);
        }
    }
    CGContextRestoreGState(context);
}

- (void)ly_display:(NSAttributedString *)attributedString {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, self.contentsScale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (self.opaque && context) {
        CGSize size = self.bounds.size;
        size.width *= self.contentsScale;
        size.height *= self.contentsScale;
        CGContextSaveGState(context);
        {
            if (!self.backgroundColor || CGColorGetAlpha(self.backgroundColor) < 1) {
                CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
                CGContextAddRect(context, CGRectMake(0, 0, size.width, size.height));
                CGContextFillPath(context);
            }
            if (self.backgroundColor) {
                CGContextSetFillColorWithColor(context, self.backgroundColor);
                CGContextAddRect(context, CGRectMake(0, 0, size.width, size.height));
                CGContextFillPath(context);
            }
        }
        CGContextRestoreGState(context);
    }

    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);

    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [attributedString length]), path, NULL);
    CFArrayRef ctLines = CTFrameGetLines(frame);
    NSUInteger lineCount = CFArrayGetCount(ctLines);
    CGPoint *lineOrigins = NULL;
    if (lineCount > 0) {
        lineOrigins = malloc(lineCount * sizeof(CGPoint));
        if (lineOrigins != NULL) {
            CTFrameGetLineOrigins(frame, CFRangeMake(0, lineCount), lineOrigins);
        }
    }

    for (NSUInteger i = 0; i < lineCount; i++) {
        CTLineRef ctLine = CFArrayGetValueAtIndex(ctLines, i);
        CFArrayRef ctRuns = CTLineGetGlyphRuns(ctLine);
        if (!ctRuns || CFArrayGetCount(ctRuns) == 0) continue;
        
        CGPoint ctLineOrigin = lineOrigins[i];

        CGContextSetTextPosition(context, ctLineOrigin.x, ctLineOrigin.y);

        for (NSUInteger r = 0, rMax = CFArrayGetCount(ctRuns); r < rMax; r++) {
            CTRunRef run = CFArrayGetValueAtIndex(ctRuns, r);
            CTRunDraw(run, context, CFRangeMake(0, 0));
        }
        
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.contents = (__bridge id)(image.CGImage);
    
    CFRelease(frame);
    CFRelease(path);
    CFRelease(framesetter);
    if (lineOrigins) free(lineOrigins);
}

@end
