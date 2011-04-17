//
//  ImageManager.m
//  PhotoFX
//
//  Created by forrest on 11-4-17.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ImageManager.h"

static ImageManager* instance = nil;

@implementation ImageManager
@synthesize image=image_;

+ (id) sharedManager{
    @synchronized(self){
        if (instance == nil) {
            instance = [[ImageManager alloc] init];
        }
    }
    return instance;
}

- (void) setImage:(UIImage *)image{
    NSLog(@"image %@", image);
    
    if (image_ == image || image == nil) {
        return;
    }
    
    [image_ release];
    image_ = [image retain];
}
@end
