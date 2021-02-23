//
//  LYTextMagnifier.m
//  LYChatUI
//
//  Created by luoyuan on 2021/1/28.
//

#import "LYTextMagnifier.h"

@interface LYTextMagnifierMaskView ()

@property (nonatomic, assign) CGFloat contentMaskCornerRadius;
@property (nonatomic, assign) CGFloat triangleHeight;

@end

@implementation LYTextMagnifierMaskView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGFloat triangleHeight = _triangleHeight;
    CGFloat cornerRadius = _contentMaskCornerRadius;
    CGSize size = self.bounds.size;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    UIBezierPath *trianglePath = [UIBezierPath bezierPath];
    
    CGFloat padding = triangleHeight;
    
    CGPoint aPoint = CGPointMake(cornerRadius, 0);
    [path moveToPoint:aPoint];

    CGPoint bPoint = CGPointMake(size.width - cornerRadius, 0);
    [path addLineToPoint:bPoint];
    
    if (cornerRadius > 0) {
        [path addArcWithCenter:CGPointMake(bPoint.x, bPoint.y + cornerRadius) radius:cornerRadius startAngle:1.5 * M_PI endAngle:2 * M_PI clockwise:true];
    }
    
    CGPoint cPoint = CGPointMake(size.width, size.height - padding - cornerRadius);
    [path addLineToPoint:cPoint];
    
    if (cornerRadius > 0) {
        [path addArcWithCenter:CGPointMake(cPoint.x - cornerRadius, cPoint.y) radius:cornerRadius startAngle:0 endAngle:0.5 * M_PI clockwise:true];
    }
    
    CGPoint dPoint = CGPointMake(size.width / 2 + triangleHeight, size.height - padding);
    [path addLineToPoint:dPoint];
    [trianglePath moveToPoint:dPoint];
    
    CGPoint ePoint = CGPointMake(size.width / 2, size.height);
    [path addLineToPoint:ePoint];
    [trianglePath addLineToPoint:ePoint];
    
    CGPoint fPoint = CGPointMake(size.width / 2 - triangleHeight, size.height - padding);
    [path addLineToPoint:fPoint];
    [trianglePath addLineToPoint:fPoint];
    
    CGPoint gPoint = CGPointMake(cornerRadius, size.height - padding);
    [path addLineToPoint:gPoint];
        
    if (cornerRadius > 0) {
        [path addArcWithCenter:CGPointMake(gPoint.x, gPoint.y - cornerRadius) radius:cornerRadius startAngle:0.5 * M_PI endAngle:M_PI clockwise:true];
    }
    
    CGPoint hPoint = CGPointMake(0, cornerRadius);
    [path addLineToPoint:hPoint];
    if (cornerRadius > 0) {
        [path addArcWithCenter:CGPointMake(hPoint.x + cornerRadius, hPoint.y) radius:cornerRadius startAngle:M_PI endAngle:1.5 * M_PI clockwise:true];
    }
    
    [path closePath];
    
    CGPathRef boxPath = CGPathCreateWithRect(rect, NULL);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // inner shadow
    CGContextSaveGState(context); {
        CGFloat blurRadius = 25;
        CGSize offset = CGSizeMake(0, 15);
        CGColorRef shadowColor = [UIColor colorWithWhite:0 alpha:0.16].CGColor;
        CGColorRef opaqueShadowColor = CGColorCreateCopyWithAlpha(shadowColor, 1.0);
        CGContextAddPath(context, path.CGPath);
        CGContextClip(context);
        CGContextSetAlpha(context, CGColorGetAlpha(shadowColor));
        CGContextBeginTransparencyLayer(context, NULL); {
            CGContextSetShadowWithColor(context, offset, blurRadius, opaqueShadowColor);
            CGContextSetBlendMode(context, kCGBlendModeSourceOut);
            CGContextSetFillColorWithColor(context, opaqueShadowColor);
            CGContextAddPath(context, path.CGPath);
            CGContextFillPath(context);
        } CGContextEndTransparencyLayer(context);
        CGColorRelease(opaqueShadowColor);
    } CGContextRestoreGState(context);
    
    // outer shadow
    CGContextSaveGState(context); {
        CGContextAddPath(context, boxPath);
        CGContextAddPath(context, path.CGPath);
        CGContextEOClip(context);
        CGColorRef shadowColor = [UIColor colorWithWhite:0 alpha:0.32].CGColor;
        CGContextSetShadowWithColor(context, CGSizeMake(0, 1.5), 3, shadowColor);
        CGContextBeginTransparencyLayer(context, NULL); {
            CGContextAddPath(context, path.CGPath);
            [[UIColor colorWithWhite:0.7 alpha:1.000] setFill];
            CGContextFillPath(context);
        } CGContextEndTransparencyLayer(context);
    } CGContextRestoreGState(context);
    
    // arrow
    CGContextSaveGState(context); {
        CGContextAddPath(context, trianglePath.CGPath);
        [[UIColor colorWithWhite:1 alpha:0.95] set];
        CGContextFillPath(context);
    } CGContextRestoreGState(context);
    
    // stroke
    CGContextSaveGState(context); {
        CGContextAddPath(context, path.CGPath);
        [[UIColor colorWithWhite:0.6 alpha:1] setStroke];
        CGContextSetLineWidth(context, 1);
        CGContextStrokePath(context);
    } CGContextRestoreGState(context);

    CFRelease(boxPath);
    
}


@end


@interface LYTextMagnifier ()

@property (nonatomic, assign) CGFloat contentMaskCornerRadius;
@property (nonatomic, assign) CGFloat triangleHeight;

@property (nonatomic, strong) UIImageView *contentView;
@property (nonatomic, strong) LYTextMagnifierMaskView *magnifierMaskView;

@end

@implementation LYTextMagnifier

#pragma mark - Setter

- (void)setSnapshot:(UIImage *)snapshot {
    _snapshot = snapshot;
    if (_captureFadeAnimation) {
        _captureFadeAnimation = false;
        [_contentView.layer removeAnimationForKey:@"contents"];
        CABasicAnimation *animation = [CABasicAnimation animation];
        animation.duration = 0.1;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        [_contentView.layer addAnimation:animation forKey:@"contents"];
    }
    _contentView.image = snapshot;
}

#pragma mark - Getter

- (CGSize)snapshotSize {
    //提取内容比显示图片小，但比例布标，显示时就起到放大作用
    CGSize size = self.contentSize;
    CGFloat multiple = 1.2;
    size.width = floor((size.width - 2 * 6) / multiple);
    size.height = floor(size.height / multiple);
    return size;
}

- (CGSize)contentSize {
    return _contentView.bounds.size;
}

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0];
        self.layer.masksToBounds = true;
        _contentMaskCornerRadius = 5;
        _triangleHeight = 12;
        
        CGSize size = frame.size;
        _contentView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height - _triangleHeight)];
        _contentView.clipsToBounds = true;
        _contentView.layer.cornerRadius = _contentMaskCornerRadius;
        _contentView.layer.masksToBounds = true;
        [self insertSubview:_contentView atIndex:0];
        
        _magnifierMaskView = [[LYTextMagnifierMaskView alloc] initWithFrame:self.bounds];
        _magnifierMaskView.contentMaskCornerRadius = _contentMaskCornerRadius;
        _magnifierMaskView.triangleHeight = _triangleHeight;
        [self addSubview:_magnifierMaskView];
        
        self.layer.anchorPoint = CGPointMake(0.5, 1.2);
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = self.bounds.size;
    _contentView.frame = CGRectMake(0, 0, size.width, size.height - _triangleHeight);
    
    _magnifierMaskView.frame = self.bounds;
    
}

#pragma mark - Public Method

- (void)showMagnifierOnWindow:(UIWindow *)window point:(CGPoint)point {
    if (!window) {
        return;
    }
    
    [window addSubview:self];
    self.center = point;
    self.alpha = 0;
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)moveMagnifierToPoint:(CGPoint)point {
//    CGPoint center = [self _magnifierCenterForPoint:point];
    self.center = point;
    
//    NSLog(@"%@", NSStringFromCGPoint(center));
}

- (void)hideMagnifier {
    [self removeFromSuperview];
}

#pragma mark - Private Method

- (CGPoint)_magnifierCenterForPoint:(CGPoint)point {
    CGFloat offset = 14;
    CGSize size = self.bounds.size;
    CGPoint center = CGPointMake(point.x, point.y - size.height / 2 - offset);
    return center;
}

@end
