//
//  ViewController.m
//  LYChatUI
//
//  Created by luoyuan on 2020/12/31.
//

#import "ViewController.h"
#import "LYChatConfig.h"
#import "LYSessionViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.userInteractionEnabled = true;
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)]];
    
    
//    CAShapeLayer *layer = [CAShapeLayer layer];
//    UIBezierPath *path = [UIBezierPath bezierPath];
//    [path moveToPoint:CGPointMake(0, 0)];
//    [path addLineToPoint:CGPointMake(100, 0)];
//    [path addLineToPoint:CGPointMake(100, 100)];
//    [path addLineToPoint:CGPointMake(0, 100)];
//    [path addLineToPoint:CGPointMake(0, 0)];
////    layer.path = path.CGPath;
//    layer.frame = CGRectMake(0, 0, 200, 200);
//    layer.lineWidth = 1;
//    layer.strokeColor = [UIColor redColor].CGColor;
//    layer.fillColor = [UIColor cyanColor].CGColor;
//
//    [self.view.layer addSublayer:layer];
    
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(40, 50, 80, 100)];
//    view.backgroundColor = [UIColor orangeColor];
//    [self.view addSubview:view];
//    
//    CAShapeLayer *layer = [CAShapeLayer createMaskLayerWithView:view];
////    layer.transform = CATransform3DMake;
//    layer.fillColor = [UIColor redColor].CGColor;
//    view.layer.mask = layer;
//    view.layer.cornerRadius = 5;
//    view.layer.masksToBounds = true;
//    
//    layer.frame = CGRectMake(100, 100, 80, 100);
//    
//    [self.view.layer addSublayer:layer];
    
//    layer.position = CGPointMake(100, 200);
    
}

- (void)tapAction {
    [LYChatConfig shared].currentUser = [LYChatUserModel userWithUserId:@"hl456" nickname:@"" avatarImage:nil];
    LYSessionViewController *vc = [LYSessionViewController new];
    vc.session = [LYSession sessionWithSessionId:@"" sessionType:LYSessionTypeGroup];
    vc.session.showNickname = true;
    [self.navigationController pushViewController:vc animated:true];
}

@end


@implementation CAShapeLayer (LYTest)

+ (instancetype)createMaskLayerWithView:(UIView *)view {
    
    CGFloat viewWidth = CGRectGetWidth(view.frame);
    CGFloat viewHeight = CGRectGetHeight(view.frame);
    
    CGFloat rightSpace = 10.;
    CGFloat topSpace = 15.;
    
    CGPoint point1 = CGPointMake(0, 0);
    CGPoint point2 = CGPointMake(viewWidth-rightSpace, 0);
    CGPoint point3 = CGPointMake(viewWidth-rightSpace, topSpace);
    CGPoint point4 = CGPointMake(viewWidth, topSpace);
    CGPoint point5 = CGPointMake(viewWidth-rightSpace, topSpace+10.);
    CGPoint point6 = CGPointMake(viewWidth-rightSpace, viewHeight);
    CGPoint point7 = CGPointMake(0, viewHeight);
    
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:point1];
    [path addLineToPoint:point2];
    [path addLineToPoint:point3];
    [path addLineToPoint:point4];
    [path addLineToPoint:point5];
    [path addLineToPoint:point6];
    [path addLineToPoint:point7];
    [path closePath];
    
//    // Create two transforms, one to mirror across the x axis, and one to
//    // to translate the resulting path back into the desired boundingRect
//    CGAffineTransform mirrorOverXOrigin = CGAffineTransformMakeScale(1.0f, -1.0f);
//    CGAffineTransform translate = CGAffineTransformMakeTranslation(viewWidth, 0);
//
//    // Apply these transforms to the path
//    [path applyTransform:mirrorOverXOrigin];
//    [path applyTransform:translate];
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = path.CGPath;
    
    
    
    return layer;
}


@end
