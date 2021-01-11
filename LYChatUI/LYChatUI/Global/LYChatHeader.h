//
//  LYChatHeader.h
//  LYChatUI
//
//  Created by luoyuan on 2021/1/8.
//

#ifndef LYChatHeader_h
#define LYChatHeader_h

#ifdef DEBUG
#define LYDLog( s, ... ) printf("class: <%p %s:(%d) > method: %s \n%s\n", self, [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, __PRETTY_FUNCTION__, [[NSString stringWithFormat:(s), ##__VA_ARGS__] UTF8String] )
//#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define LYDLog(...)
#endif

#endif /* LYChatHeader_h */
