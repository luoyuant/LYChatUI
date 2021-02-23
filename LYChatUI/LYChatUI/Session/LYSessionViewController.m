//
//  LYSessionViewController.m
//  LYChatUI
//
//  Created by luoyuan on 2020/12/31.
//

#import "LYSessionViewController.h"
#import "LYChatConfig.h"
#import "LYChatConst.h"

@interface LYSessionViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, weak) LYSessionCell *selectingTextCell;
@property (nonatomic, weak) LYLabel *selectingLabel;

@end

@implementation LYSessionViewController

#pragma mark - Getter

- (UIMenuController *)selectedTextMenuController {
    if (!_selectedTextMenuController) {
        _selectedTextMenuController = [UIMenuController new];
        _selectedTextMenuController.menuItems = @[[[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(lyTextCopy:)], [[UIMenuItem alloc] initWithTitle:@"全选" action:@selector(lyTextSelectAll:)]];
    }
    return _selectedTextMenuController;
}

- (LYLabel *)selectingLabel {
    return _selectingTextCell.sessionContentView.contentLabel;
}

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
    
    self.view.backgroundColor = self.sessionManager.config.colorConfig.sessionBackgroundColor;
    
    NSAssert(_session, @"会话对象为NULL");
    
    [self setupTableView];
    
    [self.sessionManager setup:self];
    self.sessionManager.tableConfig.delegate = self;
    
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
    tapGestureRecognizer.delegate = self;
    [tapGestureRecognizer addTarget:self action:@selector(onTapTableView:)];
    [self.tableView addGestureRecognizer:tapGestureRecognizer];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    [self.view addSubview:self.tableView];
}

#pragma mark - LYSessionTableConfigDelegate

- (void)didScrollToTop:(UIScrollView *)scrollView {
//    [self.sessionManager.tableConfig.refreshControl beginRefreshing];
//    [self getData];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.selectingTextCell && self.selectingTextCell.sessionContentView.contentLabel.selectedTextRange.length > 0) {
        if (!self.selectedTextMenuController.menuVisible) {
            [self.selectedTextMenuController setMenuVisible:YES animated:YES];
        }
    }
}

#pragma mark - LYSessionCellDelegate

- (void)avatarImageView:(UIImageView *)avatarImageView imageForMessage:(LYSessionMessage *)message {
    avatarImageView.image = message.user.avatarImage;
}

#pragma mark - LYLabelSelectionDelegate

- (void)labelDidBeginSelecting:(LYLabel *)label {
    CGPoint p = [label convertPoint:label.frame.origin toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    if (indexPath) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass:[LYSessionCell class]]) {
            if (_selectingTextCell != cell) {
                [_selectingTextCell.sessionContentView.contentLabel endTextSelecting];
            }
            _selectingTextCell = (LYSessionCell *)cell;
        }
    }
}

- (void)labelDidBeginTrackingGrabber:(LYLabel *)label {
    self.tableView.panGestureRecognizer.enabled = false;
}

- (void)labelDidEndTrackingGrabber:(LYLabel *)label {
    self.tableView.panGestureRecognizer.enabled = true;
}

- (BOOL)labelShouldShowMenu:(LYLabel *)label selectionView:(nonnull LYTextSelectionView *)selectionView selectedRange:(nonnull LYTextRange *)selectedRange selectionRect:(CGRect)selectionRect {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIMenuController *menu = self.selectedTextMenuController;
        [menu setTargetRect:CGRectStandardize(selectionRect) inView:selectionView];
        [menu update];
        if (!menu.menuVisible) {
            [menu setMenuVisible:YES animated:YES];
        }
    });
    return true;
}

- (BOOL)labelShouldHideMenu:(LYLabel *)label selectedRange:(LYTextRange *)selectedRange {
    UIMenuController *menu = self.selectedTextMenuController;
    [menu setMenuVisible:NO animated:YES];
    return true;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(lyTextCopy:)) {
        return true;
    }
    LYLabel *lb = self.selectingLabel;
    NSUInteger textlen = lb.attributedText ? lb.attributedText.length : lb.text.length;
    BOOL isSelectedAll = lb.selectedTextRange.length == textlen;
    if (action == @selector(lyTextSelectAll:) && !isSelectedAll) {
        return true;
    }
    return false;
}

- (void)lyTextCopy:(id)sender {
    LYLabel *lb = _selectingTextCell.sessionContentView.contentLabel;
    NSRange range = lb.selectedTextRange.asRange;
    if (range.location == NSNotFound || range.length == NSNotFound) return;
    NSString *text;
    if (lb.attributedText) {
        text = [lb.attributedText attributedSubstringFromRange:range].string;
    } else {
        text = [lb.text substringWithRange:range];
    }
    [UIPasteboard generalPasteboard].string = text;
    [self endTextSelecting];
}

- (void)lyTextSelectAll:(id)sender {
    [self.selectingLabel selectAllText];
}

#pragma mark - UIMenuController

- (BOOL)canBecomeFirstResponder {
    return true;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint point = [touch locationInView:gestureRecognizer.view];
    [self endTextSelectingForPoint:point];
    return true;
}

#pragma mark - Action

- (void)onTapTableView:(UIGestureRecognizer *)tapGestureRecognizer {
    [self.view endEditing:true];
    
    CGPoint point = [tapGestureRecognizer locationInView:tapGestureRecognizer.view];
    [self endTextSelectingForPoint:point];
}

- (void)endTextSelectingForPoint:(CGPoint)point {
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    UITableViewCell *cell;
    if (indexPath) {
        cell = [self.tableView cellForRowAtIndexPath:indexPath];
    }
    if (cell != _selectingTextCell) {
        [self endTextSelecting];
    }
}

- (void)endTextSelecting {
    if (_selectingTextCell) {
        [_selectingTextCell.sessionContentView.contentLabel endTextSelecting];
        _selectingTextCell = nil;
    }
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
