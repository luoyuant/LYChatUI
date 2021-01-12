//
//  LYSessionTimestampCell.m
//  LYChatUI
//
//  Created by luoyuan on 2021/1/8.
//

#import "LYSessionTimestampCell.h"
#import "LYChatConfig.h"
#import "LYSessionTimestampCellLayout.h"

@implementation LYSessionTimestampCell

#pragma mark - Setter

- (void)setModel:(LYSessionTimestampMessage *)model {
    BOOL shouldUpdate = _model != model;
    _model = model;
    if (shouldUpdate) {
        [self refresh];
        [self setNeedsLayout];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Init

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _timestampLabel = [UILabel new];
        _timestampLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_timestampLabel];
        
    }
    return self;
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if ([_model.layout isKindOfClass:[LYSessionTimestampCellLayout class]]) {
        CGSize size = self.contentView.bounds.size;
        LYSessionTimestampCellLayout *layout = (LYSessionTimestampCellLayout *)_model.layout;
        UIEdgeInsets margin = layout.contentMargin;
        [_timestampLabel sizeToFit];
        
        _timestampLabel.frame = CGRectMake(margin.left, 0, size.width - margin.left - margin.right, size.height);
        
    }
    
}

#pragma mark - Public Method

/**
 * 数据刷新
 */
- (void)refresh {
    _timestampLabel.text = _model.timestampText;
    
    _timestampLabel.font = _model.config.fontConfig.timestampFont;
    _timestampLabel.textColor = _model.config.colorConfig.timestampTextColor;
}

@end
