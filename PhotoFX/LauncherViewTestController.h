#import <Three20/Three20.h>

@interface LauncherViewTestController : TTViewController <TTLauncherViewDelegate> {
    TTLauncherView* _launcherView;
    UIImage* _originItemImage;
}

@property(nonatomic,retain) UIImage* originItemImage;

@end
