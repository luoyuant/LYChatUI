//
//  LYSessionViewController.m
//  LYChatUI
//
//  Created by luoyuan on 2020/12/31.
//

#import "LYSessionViewController.h"
#import "LYChatGlobalConfig.h"
#import "LYChatConst.h"

@interface LYSessionViewController ()



@end

@implementation LYSessionViewController

#pragma mark - Getter

- (LYSessionManager *)sessionManager {
    if (!_sessionManager) {
        _sessionManager = [LYSessionManager new];
    }
    return _sessionManager;
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [LYChatGlobalConfig shared].colorConfig.sessionBackgroundColor;
    
    NSAssert(_session, @"会话对象为NULL");
    
    [self setupTableView];
    
    [self.sessionManager setup:self];
        
    [self.sessionManager.dataSource getLocalData];
    
}

#pragma mark - Init

/**
 * tableView设置
 */
- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.contentInset = UIEdgeInsetsMake(9, 0, 6, 0);
    self.tableView.tableFooterView = [UIView new];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [tapGestureRecognizer addTarget:self action:@selector(onTapTableView:)];
    [self.tableView addGestureRecognizer:tapGestureRecognizer];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    [self.view addSubview:self.tableView];
}

#pragma mark - Action

- (void)onTapTableView:(UITapGestureRecognizer *)tapGestureRecognizer {
    [self.view endEditing:true];
}

#pragma mark - Dealloc

- (void)dealloc {
    LYDLog(@"销毁");
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
