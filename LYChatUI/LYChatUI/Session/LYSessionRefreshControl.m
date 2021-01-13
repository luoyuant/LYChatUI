//
//  LYSessionRefreshControl.m
//  LYChatUI
//
//  Created by luoyuan on 2021/1/7.
//

#import "LYSessionRefreshControl.h"
#import <objc/runtime.h>

@interface LYSessionRefreshControl ()

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, assign) BOOL isRefreshing;

@property (nonatomic, weak) UIScrollView *scrollView;

@property (nonatomic, assign) UIEdgeInsets scrollViewOriginalInset;

@end

@implementation LYSessionRefreshControl

#pragma mark - Getter

- (BOOL)refreshing {
    return _isRefreshing;
}

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.hidden = true;
    
    _contentView = [UIView new];
    [self addSubview:_contentView];
    
    _indicatorView = [[UIActivityIndicatorView alloc] init];
    _indicatorView.hidesWhenStopped = true;
    [_contentView addSubview:_indicatorView];
    
    _titleLabel = [UILabel new];
    _titleLabel.font = [UIFont systemFontOfSize:14];
    [_contentView addSubview:_titleLabel];
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = CGRectMake(0, -self.scrollView.contentInset.top, _scrollView.bounds.size.width, 44);
    self.frame = frame;
    
    CGSize size = frame.size;
    
    [_indicatorView sizeToFit];
    [_titleLabel sizeToFit];
    
    CGSize indicatorViewSize = _indicatorView.bounds.size;
    CGSize titleLabelSize = _titleLabel.bounds.size;
    CGFloat height = MAX(indicatorViewSize.height, titleLabelSize.height);
    _indicatorView.frame = CGRectMake(0, (height - indicatorViewSize.height) / 2, indicatorViewSize.width, indicatorViewSize.height);
    
    CGFloat titleLabelMaxWidth = size.width - indicatorViewSize.width - 10 - 24;
    if (titleLabelSize.width > titleLabelMaxWidth) {
        titleLabelSize.width = titleLabelMaxWidth;
    }
    _titleLabel.frame = CGRectMake(CGRectGetMaxX(_indicatorView.frame) + 10, (height - titleLabelSize.height) / 2, titleLabelSize.width, titleLabelSize.height);
    
    _contentView.frame = CGRectMake(0, 0, CGRectGetMaxX(_titleLabel.frame), height);
    _contentView.center = CGPointMake(size.width / 2, size.height / 2);
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    if (newSuperview && ![newSuperview isKindOfClass:[UIScrollView class]]) return;
    
    if (newSuperview) {
        _scrollView = (UIScrollView *)newSuperview;
        _scrollView.alwaysBounceVertical = YES;
        
        if (@available(iOS 11.0, *)) {
            _scrollViewOriginalInset = _scrollView.adjustedContentInset;
        } else {
            _scrollViewOriginalInset = _scrollView.contentInset;
        }
    }
    
}

#pragma mark - Public Method

- (void)beginRefreshing {
    if (self.isRefreshing) {
        return;
    }
    self.isRefreshing = true;
    self.hidden = false;
    [self.indicatorView startAnimating];
    [UIView animateWithDuration:0.3 animations:^{
        CGFloat topOffset = self.scrollViewOriginalInset.top + self.bounds.size.height;
        UIEdgeInsets insets = self.scrollView.contentInset;
        insets.top = topOffset;
        if (@available(iOS 11.0, *)) {
            insets.top -= (self.scrollView.adjustedContentInset.top - self.scrollView.contentInset.top);
        }
        self.scrollView.contentInset = insets;
        [self setNeedsLayout];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)endRefreshing {
    if (!self.isRefreshing) {
        return;
    }
    [UIView performWithoutAnimation:^{
        self.scrollView.contentInset = self.scrollViewOriginalInset;
        self.isRefreshing = false;
        self.hidden = true;
        [self.indicatorView stopAnimating];
    }];
}


@end



@implementation UIScrollView (LYChat)

- (void)setLyChatRefreshControl:(LYSessionRefreshControl *)lyChatRefreshControl {
    if (self) {
        [self insertSubview:lyChatRefreshControl atIndex:0];
    }
    objc_setAssociatedObject(self, @selector(lyChatRefreshControl), lyChatRefreshControl, OBJC_ASSOCIATION_RETAIN);
}

- (LYSessionRefreshControl *)lyChatRefreshControl {
    return objc_getAssociatedObject(self, _cmd);;
}

@end
