//
//  LYSessionViewController.m
//  LYChatUI
//
//  Created by luoyuan on 2020/12/31.
//

#import "LYSessionViewController.h"
#import "LYChatConfig.h"
#import "LYChatConst.h"
#import "LYSessionTextContentView.h"

@interface LYSessionViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, assign) CGRect selectedTextMenuTargetRect;

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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        LYSessionTextContentView *selectingTextContentView = [self selectingTextContentView];
        if (selectingTextContentView) {
            [self showSelectTextMenuFromView:selectingTextContentView.contentLabel.selectionView rect:_selectedTextMenuTargetRect];
        }
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    LYSessionTextContentView *selectingTextContentView = [self selectingTextContentView];
    if (selectingTextContentView) {
        [self showSelectTextMenuFromView:selectingTextContentView.contentLabel.selectionView rect:_selectedTextMenuTargetRect];
    }
}

#pragma mark - LYSessionCellDelegate

- (void)avatarImageView:(UIImageView *)avatarImageView imageForMessage:(LYSessionMessageModel *)message {
    avatarImageView.image = message.message.user.avatarImage;
}

#pragma mark - LYLabelSelectionDelegate

- (void)labelDidBeginSelecting:(LYLabel *)label {
    CGPoint p = [label convertPoint:label.frame.origin toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    LYSessionContentView *contentView;
    if (indexPath) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass:[LYSessionCell class]]) {
            LYSessionCell *sessionCell = (LYSessionCell *)cell;
            contentView = sessionCell.sessionContentView;
        }
    }
    LYSessionTextContentView *selectingTextContentView = [self selectingTextContentView];
    if (selectingTextContentView && selectingTextContentView != contentView) {
        [selectingTextContentView.contentLabel endTextSelecting];
    }
}

- (void)labelDidBeginTrackingGrabber:(LYLabel *)label {
    self.tableView.panGestureRecognizer.enabled = false;
}

- (void)labelDidEndTrackingGrabber:(LYLabel *)label {
    self.tableView.panGestureRecognizer.enabled = true;
}

- (BOOL)labelShouldShowMenu:(LYLabel *)label selectionView:(nonnull LYTextSelectionView *)selectionView selectedRange:(nonnull LYTextRange *)selectedRange selectionRect:(CGRect)selectionRect {
    [self hideSelectTextMenu];
    LYSessionTextContentView *selectingTextContentView = [self selectingTextContentView];
    [self showSelectTextMenuFromView:selectingTextContentView.contentLabel.selectionView rect:selectionRect];
    return true;
}

- (BOOL)labelShouldHideMenu:(LYLabel *)label selectedRange:(LYTextRange *)selectedRange {
    [self hideSelectTextMenu];
    return true;
}

#pragma Mark - SelectionView Action

- (LYSessionTextContentView *)selectingTextContentView {
    LYSessionTextContentView *resultView;
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        if ([cell isKindOfClass:[LYSessionCell class]]) {
            LYSessionContentView *contentView = ((LYSessionCell *)cell).sessionContentView;
            if ([contentView isKindOfClass:[LYSessionTextContentView class]]) {
                LYSessionTextContentView *textContentView = (LYSessionTextContentView *)contentView;
                if (textContentView.contentLabel.selectedTextRange.length > 0) {
                    resultView = textContentView;
                    break;
                }
            }
        }
    }
    return resultView;
}

- (void)endTextSelecting {
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        if ([cell isKindOfClass:[LYSessionCell class]]) {
            LYSessionContentView *contentView = ((LYSessionCell *)cell).sessionContentView;
            if ([contentView isKindOfClass:[LYSessionTextContentView class]]) {
                LYSessionTextContentView *textContentView = (LYSessionTextContentView *)contentView;
                if (textContentView.contentLabel.selectedTextRange.length > 0) {
                    [textContentView.contentLabel endTextSelecting];
                }
            }
        }
    }
}

#pragma mark - UIMenuController

- (BOOL)canBecomeFirstResponder {
    return true;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(lyTextCopy:)) {
        return true;
    }
    LYSessionTextContentView *contentView = [self selectingTextContentView];
    LYLabel *lb = contentView.contentLabel;
    NSUInteger textlen = lb.attributedText ? lb.attributedText.length : lb.text.length;
    BOOL isSelectedAll = lb.selectedTextRange.length == textlen;
    if (action == @selector(lyTextSelectAll:) && !isSelectedAll) {
        return true;
    }
    return false;
}

- (void)lyTextCopy:(id)sender {
    LYSessionTextContentView *contentView = [self selectingTextContentView];
    LYLabel *lb = contentView.contentLabel;
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
    LYSessionTextContentView *contentView = [self selectingTextContentView];
    LYLabel *lb = contentView.contentLabel;
    [lb selectAllText];
//    [self hideSelectTextMenu];
//    [self showSelectTextMenuFromView:_selectingTextView.contentLabel.selectionView rect:self.selectedTextMenuTargetRect];
}

- (void)showSelectTextMenuFromView:(UIView *)targetView rect:(CGRect)targetRect {
    UIMenuController *menu = self.selectedTextMenuController;
    
    if (!menu.menuVisible) {
        _selectedTextMenuTargetRect = targetRect;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            if (@available(iOS 13.0, *)) {
                [menu showMenuFromView:targetView rect:targetRect];
            } else {
                [menu setTargetRect:targetRect inView:targetView];
                [menu update];
                [menu setMenuVisible:YES animated:YES];
            }
        });
    }
}

- (void)hideSelectTextMenu {
    if (self.selectedTextMenuController.menuVisible) {
        if (@available(iOS 13.0, *)) {
            [self.selectedTextMenuController hideMenu];
        } else {
            [self.selectedTextMenuController setMenuVisible:NO animated:YES];
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint point = [touch locationInView:gestureRecognizer.view];
    [self endTextSelectingForPoint:point inView:gestureRecognizer.view];
    return true;
}

#pragma mark - Action

- (void)onTapTableView:(UIGestureRecognizer *)tapGestureRecognizer {
    [self.view endEditing:true];
    
    CGPoint point = [tapGestureRecognizer locationInView:tapGestureRecognizer.view];
    [self endTextSelectingForPoint:point inView:tapGestureRecognizer.view];
}

- (void)endTextSelectingForPoint:(CGPoint)point inView:(UIView *)view {
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    LYSessionContentView *contentView;
    if (indexPath) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass:[LYSessionCell class]]) {
            LYSessionCell *sessionCell = (LYSessionCell *)cell;
            contentView = sessionCell.sessionContentView;
        }
    }
    LYSessionTextContentView *selectingTextContentView = [self selectingTextContentView];
    if (contentView != selectingTextContentView) {
        [self endTextSelecting];
    } else {
        if (selectingTextContentView) {
            CGPoint p = [view convertPoint:point toView:selectingTextContentView];
            if (!CGRectContainsPoint(selectingTextContentView.bounds, p)) {
                [self endTextSelecting];
            }
        }
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
