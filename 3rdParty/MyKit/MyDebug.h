//
//  MyDebug.h
//  PhotoEffects
//
//  Created by forrest on 11-2-20.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
#define LogX(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define LogX(...)
#endif

@interface MyDebug : NSObject {

}

@end
