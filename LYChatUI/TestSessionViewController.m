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
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"刷新" style:UIBarButtonItemStylePlain target:self action:@selector(refresh)];
    
    [self getData];
    
    
}

- (void)refresh {
    [self getData];
}

#pragma mark - Get data

- (void)getData {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage *avatarImage = [UIImage imageNamed:@"avatar"];

        NSTimeInterval timestamp = 1619985025000;

        NSMutableArray *messageArray = [NSMutableArray array];

//        for (NSInteger i = 0; i < 10; i++) {
//            LYSessionMessageModel *model = [LYSessionMessageModel new];
//            LYChatMessage *message = [LYChatMessage new];
//            message.session = self.session;
//            message.user = [LYChatUserModel userWithUserId:@"hl123" nickname:@"神尾观铃" avatarImage:avatarImage];
//            message.text = @"庭院深深深几许？杨柳堆烟，帘幕无重数，玉勒雕鞍游冶处，楼高不见章台路";
//            model.config = self.sessionManager.config;
//            model.timestamp = timestamp;
//            model.message = message;
//            [messageArray addObject:model];
//
//            timestamp += 50 * 1000;
//
//            LYSessionMessageModel *bModel = [LYSessionMessageModel new];
//            message = [LYChatMessage new];
//            message.user = [LYChatUserModel userWithUserId:@"hl456" nickname:@"国崎往人" avatarImage:avatarImage];
//            message.text = @"庭院深深深几许？杨柳堆烟，帘幕无重数，玉勒雕鞍游冶处，楼高不见章台路。";
//            message.session = self.session;
//            bModel.config = self.sessionManager.config;
//            bModel.timestamp = timestamp;
//            bModel.message = message;
//            [messageArray addObject:bModel];
//            timestamp += 50 * 1000;
//        }

        LYSessionMessageModel *model = [LYSessionMessageModel new];
        LYChatMessage *message = [LYChatMessage new];
        message.session = self.session;
        message.user = [LYChatUserModel userWithUserId:@"hl123" nickname:@"神尾观铃" avatarImage:avatarImage];
        message.text = @"Test";
        model.config = self.sessionManager.config;
        model.timestamp = timestamp;
        model.message = message;
        [messageArray addObject:model];
        timestamp += 50 * 1000;
        
        model = [LYSessionMessageModel new];
        message = [LYChatMessage new];
        message.session = self.session;
        message.user = [LYChatUserModel userWithUserId:@"hl456" nickname:@"国崎往人" avatarImage:avatarImage];
        message.text = @"well";
        model.config = self.sessionManager.config;
        model.timestamp = timestamp;
        model.message = message;
        [messageArray addObject:model];
        timestamp += 50 * 1000;
        
        model = [LYSessionMessageModel new];
        message = [LYChatMessage new];
        message.session = self.session;
        message.user = [LYChatUserModel userWithUserId:@"hl123" nickname:@"神尾观铃" avatarImage:avatarImage];
        message.text = @"Good";
        model.config = self.sessionManager.config;
        model.timestamp = timestamp;
        model.message = message;
        [messageArray addObject:model];
        timestamp += 50 * 1000;
        
        model = [LYSessionMessageModel new];
        message = [LYChatMessage new];
        message.session = self.session;
        message.user = [LYChatUserModel userWithUserId:@"hl456" nickname:@"国崎往人" avatarImage:avatarImage];
        message.text = @"庭院深深深几许？";
        model.config = self.sessionManager.config;
        model.timestamp = timestamp;
        model.message = message;
        [messageArray addObject:model];
        timestamp += 50 * 1000;
        
        model = [LYSessionMessageModel new];
        message = [LYChatMessage new];
        message.session = self.session;
        message.user = [LYChatUserModel userWithUserId:@"hl456" nickname:@"国崎往人" avatarImage:avatarImage];
        message.text = @"杨柳堆烟";
        model.config = self.sessionManager.config;
        model.timestamp = timestamp;
        model.message = message;
        [messageArray addObject:model];
        timestamp += 50 * 1000;
        
        model = [LYSessionMessageModel new];
        message = [LYChatMessage new];
        message.session = self.session;
        message.user = [LYChatUserModel userWithUserId:@"hl123" nickname:@"神尾观铃" avatarImage:avatarImage];
        message.text = @"The first time";
        model.config = self.sessionManager.config;
        model.timestamp = timestamp;
        model.message = message;
        [messageArray addObject:model];
        timestamp += 50 * 1000;
        
        model = [LYSessionMessageModel new];
        message = [LYChatMessage new];
        message.session = self.session;
        message.user = [LYChatUserModel userWithUserId:@"hl456" nickname:@"国崎往人" avatarImage:avatarImage];
        message.text = @"帘幕无重数";
        model.config = self.sessionManager.config;
        model.timestamp = timestamp;
        model.message = message;
        [messageArray addObject:model];
        timestamp += 5 * 1000;
        
        model = [LYSessionMessageModel new];
        message = [LYChatMessage new];
        message.session = self.session;
        message.user = [LYChatUserModel userWithUserId:@"hl456" nickname:@"国崎往人" avatarImage:avatarImage];
        message.text = @"雨横风狂三月暮";
        model.config = self.sessionManager.config;
        model.timestamp = timestamp;
        model.message = message;
        [messageArray addObject:model];
        timestamp += 5 * 1000;
        
        model = [LYSessionMessageModel new];
        message = [LYChatMessage new];
        message.session = self.session;
        message.user = [LYChatUserModel userWithUserId:@"hl456" nickname:@"国崎往人" avatarImage:avatarImage];
        message.text = @"楼高不见章台路";
        model.config = self.sessionManager.config;
        model.timestamp = timestamp;
        model.message = message;
        [messageArray addObject:model];
        timestamp += 5 * 1000;
        
        model = [LYSessionMessageModel new];
        message = [LYChatMessage new];
        message.session = self.session;
        message.user = [LYChatUserModel userWithUserId:@"hl456" nickname:@"国崎往人" avatarImage:avatarImage];
        message.text = @"泪眼问花花不语";
        model.config = self.sessionManager.config;
        model.timestamp = timestamp;
        model.message = message;
        [messageArray addObject:model];
        timestamp += 5 * 1000;
        
        model = [LYSessionMessageModel new];
        message = [LYChatMessage new];
        message.session = self.session;
        message.user = [LYChatUserModel userWithUserId:@"hl456" nickname:@"国崎往人" avatarImage:avatarImage];
        message.text = @"门掩黄昏";
        model.config = self.sessionManager.config;
        model.timestamp = timestamp;
        model.message = message;
        [messageArray addObject:model];
        timestamp += 5 * 1000;
        
        model = [LYSessionMessageModel new];
        message = [LYChatMessage new];
        message.session = self.session;
        message.user = [LYChatUserModel userWithUserId:@"hl456" nickname:@"国崎往人" avatarImage:avatarImage];
        message.text = @"无计留春住";
        model.config = self.sessionManager.config;
        model.timestamp = timestamp;
        model.message = message;
        [messageArray addObject:model];
        timestamp += 5 * 1000;
        
        model = [LYSessionMessageModel new];
        message = [LYChatMessage new];
        message.session = self.session;
        message.user = [LYChatUserModel userWithUserId:@"hl456" nickname:@"国崎往人" avatarImage:avatarImage];
        message.text = @"泪眼问花花不语";
        model.config = self.sessionManager.config;
        model.timestamp = timestamp;
        model.message = message;
        [messageArray addObject:model];
        timestamp += 5 * 1000;
        
        model = [LYSessionMessageModel new];
        message = [LYChatMessage new];
        message.session = self.session;
        message.user = [LYChatUserModel userWithUserId:@"hl456" nickname:@"国崎往人" avatarImage:avatarImage];
        message.text = @"乱红飞过秋千去";
        model.config = self.sessionManager.config;
        model.timestamp = timestamp;
        model.message = message;
        [messageArray addObject:model];
        timestamp += 50 * 1000;
        
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
