//
//  LYTextLine.h
//  LYChatUI
//
//  Created by luoyuan on 2021/1/20.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

NS_ASSUME_NONNULL_BEGIN

typedef struct {
    CGFloat top;
    CGFloat bottom;
} LYTextLineEdge;

@interface LYTextLine : NSObject

@property (nonatomic) NSUInteger index;
@property (nonatomic) NSUInteger row;

@property (nonatomic, readonly) CTLineRef lineRef;

@property (nonatomic, readonly) NSRange range; 

@property (nonatomic, readonly) CGRect bounds; 

@property (nonatomic)   CGPoint position;
@property (nonatomic, readonly) CGFloat ascent;
@property (nonatomic, readonly) CGFloat descent;
@property (nonatomic, readonly) CGFloat leading;
@property (nonatomic, readonly) CGFloat lineWidth;
@property (nonatomic, readonly) CGFloat trailingWhitespaceWidth;

@property (nonatomic) LYTextLineEdge edge;

+ (instancetype)lineWithCTLine:(CTLineRef)lineRef position:(CGPoint)position;

@end

NS_ASSUME_NONNULL_END
