//
//  PreviewViewController.h
//  PhotoEffects
//
//  Created by forrest on 11-2-23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol FlipbackDelegate;


@interface PreviewViewController : UIViewController {
	id<FlipbackDelegate>	delegate;
}

@property(nonatomic,assign) id<FlipbackDelegate>	delegate;
@end
