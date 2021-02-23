//
//  TestViewController.m
//  LYChatUI
//
//  Created by luoyuan on 2021/1/20.
//

#import "TestViewController.h"
#import "LYLabel.h"
#import "LYTextMagnifier.h"

@interface TestViewController ()

@property (nonatomic, strong) LYLabel *lb;

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //https://www.jianshu.com/p/1c3d0936bba6
    //https://cloud.tencent.com/developer/article/1403845
    _lb = [[LYLabel alloc] initWithFrame:CGRectMake(50, 50, 200, 0)];
    _lb.text = @"庭院深深深几许？杨柳堆烟，帘幕无重数，玉勒雕鞍游冶处，楼高不见章台路。";
    _lb.numberOfLines = 0;
//    _lb.selectable = false;
//    _lb.backgroundColor = [UIColor grayColor];
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:@"庭院深深深几许？杨柳堆烟，帘幕无重数，玉勒雕鞍游冶处，楼高不见章台路。" attributes:@{NSForegroundColorAttributeName : [UIColor redColor], NSFontAttributeName : [UIFont systemFontOfSize:17]}];
    
    LYTextHighlight *highlight = [LYTextHighlight highlightWithTextColor:[UIColor greenColor]];
    [attStr addAttributes:@{LYTextHighlightAttributeName : highlight} range:NSMakeRange(0, 5)];
//    _lb.attributedText = attStr;
    _lb.textContentInsets = UIEdgeInsetsMake(8, 4, 8, 4);
//    lb.backgroundColor = [UIColor redColor];
//    lb.textAlignment = NSTextAlignmentRight;
    [_lb sizeToFit];
    [self.view addSubview:_lb];
        
    
    UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(48, 300, 128, 0)];
    lb.text = @"庭院深深深几许？杨柳堆烟，帘幕无重数，玉勒雕鞍游冶处，楼高不见章台路。";
    lb.backgroundColor = [UIColor grayColor];
    lb.userInteractionEnabled = true;
    [self.view addSubview:lb];
    [lb sizeToFit];
    
    self.view.userInteractionEnabled = true;
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)]];
    
}

- (void)tapAction {
//    [_lb endSelectingText];
}

- (void)dealloc {
    NSLog(@"销毁测试");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
