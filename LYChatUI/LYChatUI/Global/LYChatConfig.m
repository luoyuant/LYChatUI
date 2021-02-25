//
//  LYChatConfig.m
//  LYChatUI
//
//  Created by luoyuan on 2021/1/5.
//

#import "LYChatConfig.h"

@implementation LYChatConfig

+ (instancetype)shared {
    static LYChatConfig *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LYChatConfig alloc] init];
        instance.sessionConfig = [LYSessionConfig new];
    });
    return instance;
}

#pragma mark - Getter

/**
 * 颜色
 */
- (LYChatColorConfig *)colorConfig {
    if (!_colorConfig) {
        _colorConfig = [LYChatColorConfig new];
    }
    return _colorConfig;
}

/**
 * 字体
 */
- (LYChatFontConfig *)fontConfig {
    if (!_fontConfig) {
        _fontConfig = [LYChatFontConfig new];
    }
    return _fontConfig;
}

- (LYSessionConfig *)sessionConfig {
    if (!_sessionConfig) {
        _sessionConfig = [LYSessionConfig new];
    }
    return _sessionConfig;
}

/**
 * 相隔多久显示一条时间戳(精确到毫秒)
 */
- (NSTimeInterval)showTimestampWithTimeInterval {
    if (_showTimestampWithTimeInterval <= 0) {
        _showTimestampWithTimeInterval = 60 * 1000;
    }
    return _showTimestampWithTimeInterval;
}

#pragma mark - Public Method

/**
 * 时间戳 转为显示时间
 */
- (NSString *)sessionTimeTextWithTimestamp:(NSTimeInterval)timestamp {
    if (timestamp <= 0) {
        return nil;
    }
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp / 1000.0];
    return [self sessionTimeTextWithDate:date];
}

/**
 * 时间date 转为显示时间
 */
- (NSString *)sessionTimeTextWithDate:(NSDate *)date {
    if (!date) {
        return nil;
    }
    NSDateFormatter *df = [NSDateFormatter new];
    
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate *today = [[NSDate alloc] init];
    NSDate *yesterday = [today dateByAddingTimeInterval: -secondsPerDay];
    NSDate *twodaysago = [today dateByAddingTimeInterval: -(2 * secondsPerDay)];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    
    NSDateComponents *compDate = [calendar components:unitFlags fromDate:date];
    NSDateComponents *compToday = [calendar components:unitFlags fromDate:today];
    NSDateComponents *compYesterday = [calendar components:unitFlags fromDate:yesterday];
    NSDateComponents *compTwodaysago = [calendar components:unitFlags fromDate:twodaysago];
    
    if (compDate.year == compToday.year && compDate.month == compToday.month && compDate.day == compToday.day) {
        df.dateFormat = @"HH:mm";
    } else if (compDate.year == compYesterday.year && compDate.month == compYesterday.month && compDate.day == compYesterday.day) {
        df.dateFormat = @"昨天 HH:mm";
    } else if (compDate.year == compTwodaysago.year && compDate.month == compTwodaysago.month && compDate.day == compTwodaysago.day) {
        df.dateFormat = @"前天 HH:mm";
    } else if (compDate.year == compToday.year) {
        df.dateFormat = @"MM-dd HH:mm";
    } else {
        df.dateFormat = @"yyyy-MM-dd HH:mm";
    }
    return [df stringFromDate:date];
}

@end
