//
//  ImageManager.h
//  PhotoFX
//
//  Created by forrest on 11-4-17.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ImageManager : NSObject {
    UIImage *image_;
}

@property (nonatomic, retain) UIImage *image;

+ (ImageManager*) sharedManager;

@end
