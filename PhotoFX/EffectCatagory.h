//
//  EffectCatagory.h
//  PhotoEffects
//
//  Created by forrest on 11-2-17.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface EffectCatagory : NSObject {
	NSString	*_categoryName;
	NSArray		*_filtersArray;
}

@property(nonatomic,copy) NSString	*categoryName;
@property(nonatomic,retain) NSArray		*filtersArray;
@end
