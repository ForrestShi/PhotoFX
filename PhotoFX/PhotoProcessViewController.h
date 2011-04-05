#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import <AudioToolbox/AudioToolbox.h>
#import "MagickWand.h"
#import "LabeledActivityIndicatorView.h"

typedef	enum{
	Sepia = 0 ,
	Negate,
	Solarize,

	Swirl = 100,
	Implode,

	OilPaint=200,
	Charcoal,
	Sketch,
	Spread,
	Blur,
	Emboss,
	Vignette,
	Shade,
	Flip,
	UpgradePro = 300
}EffectType;

//com.dfa.pencilme
static EffectType appType = Charcoal;


@protocol FlipbackDelegate

- (void) flipback:(EffectType)type;
- (void) returnback:(id)sender;

@end


@interface PhotoProcessViewController : UIViewController <UIActionSheetDelegate, 
                                                    UIScrollViewDelegate,
                                                    UIImagePickerControllerDelegate,
                                                    UIPopoverControllerDelegate,
                                                    UINavigationControllerDelegate,
                                                    FlipbackDelegate> {
	UIImageView *_imageView;
	UIScrollView *_scrollView;
	UISlider* _slider1;
	UISlider* _slider2;
	BOOL	needSlider1;
	BOOL	needSlider2;
	
	LabeledActivityIndicatorView* _activity;
	SystemSoundID alertSoundID;
	
	UIImagePickerController * _picker;
	UIPopoverController* _popover;
	UIToolbar *_toolbar;
	
	CGImageRef _beforeImage;
	EffectType currentType;
	
	ADBannerView *banner;
    BOOL    tapFlag;

}

- (IBAction)loadImage:(id)sender;
- (IBAction)shareImage:(id)sender;
- (IBAction)pickupEffect:(id)sender;

@property (nonatomic, retain) LabeledActivityIndicatorView* activity;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UISlider* slider1;
@property (nonatomic, retain) UISlider* slider2;
@property (nonatomic, assign) EffectType currentType;

@property (nonatomic, retain) UIPopoverController* popover;
@property (nonatomic, retain) UIImagePickerController *picker;

@property (nonatomic, retain) UIToolbar *toolbar;

@property (nonatomic, assign) CGImageRef beforeImage;
@property(nonatomic, retain)  ADBannerView *banner;
@property(nonatomic,assign) BOOL    tapFlag;



@end