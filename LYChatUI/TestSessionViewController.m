//
//  TestSessionViewController.m
//  LYChatUI
//
//  Created by luoyuan on 2021/2/22.
//

#import "TestSessionViewController.h"

@interface TestSessionViewController ()

@end

@implementation TestSessionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self getData];
    
}

#pragma mark - Get data

- (void)getData {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage *avatarImage = [UIImage imageNamed:@"avatar"];

        NSTimeInterval timestamp = 1619985025000;

        NSMutableArray *messageArray = [NSMutableArray array];

        for (NSInteger i = 0; i < 1; i++) {
            LYSessionMessage *model = [LYSessionMessage new];
            model.session = self.session;
            model.config = self.sessionManager.config;
            model.timestamp = timestamp;
            model.user = [LYChatUserModel userWithUserId:@"hl123" nickname:@"神尾观铃" avatarImage:avatarImage];
            model.contentText = @"庭院深深深几许？杨柳堆烟，帘幕无重数，玉勒雕鞍游冶处，楼高不见章台路";
            [messageArray addObject:model];

            timestamp += 50 * 1000;

            LYSessionMessage *bModel = [LYSessionMessage new];
            bModel.session = self.session;
            bModel.config = self.sessionManager.config;
            bModel.timestamp = timestamp;
            bModel.user = [LYChatUserModel userWithUserId:@"hl456" nickname:@"国崎往人" avatarImage:avatarImage];
            bModel.contentText = @"庭院深深深几许？杨柳堆烟，帘幕无重数，玉勒雕鞍游冶处，楼高不见章台路。";
            [messageArray addObject:bModel];
            timestamp += 50 * 1000;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.sessionManager.tableConfig.refreshControl endRefreshing];
        });

        if (self.sessionManager.dataSource.dataArray.count > 0) {
            [self.sessionManager.dataSource insertMessages:messageArray checkOrder:true];
        } else {
            [self.sessionManager.dataSource appendMessages:messageArray scrollToBottom:true];
        }
    });
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
