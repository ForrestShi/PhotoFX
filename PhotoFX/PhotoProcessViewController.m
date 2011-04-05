
#import "PhotoProcessViewController.h"
#import "MyUIBox.h"
#import "MyImageKit.h"
#import "SHK.h"

#import "EffectsTableViewController.h"
#import "MKStoreManager.h"
#import "MyDebug.h"

static NSString* message = @"Check out this awesome app http://itunes.apple.com/us/app/advanced-photo-effects/id417958436?mt=8 ";
static NSString* title = @"Advanced Photo Effects for iPhone and iPad";
static NSString* kIAPProUpgrade = @"com.dfa.photoeffects.pro";
static NSString* defaultFile = @"chinese-girl";

#define TOOLBAR_HEIGHT_PAD 60 
#define TOOLBAR_HEIGHT 45

#define SLIDER_MAX 100
#define SLIDER_MIN 0
#define SLIDER_DEFAULT 60

#define SCALE 6
#define PHOTO_WIDTH 32*SCALE
#define PHOTO_HEIGHT 48*SCALE
#define PHOTO_REAL_WIDTH 32*4
#define PHOTO_REAL_HEIGHT 48*4

#define ThrowWandException(wand) { \
char * description; \
ExceptionType severity; \
\
description = MagickGetException(wand,&severity); \
(void) fprintf(stderr, "%s %s %lu %s\n", GetMagickModule(), description); \
description = (char *) MagickRelinquishMemory(description); \
exit(-1); \
}

CGImageRef createStandardImage(CGImageRef image) {
	const size_t width = PHOTO_REAL_WIDTH ;
	const size_t height = PHOTO_REAL_WIDTH * CGImageGetHeight(image)/CGImageGetWidth(image);
	
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	CGContextRef ctx = CGBitmapContextCreate(NULL, width, height, 8, 4*width, space,
											 kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedFirst);
	CGColorSpaceRelease(space);
	CGContextDrawImage(ctx, CGRectMake(0, 0, width, height), image);
	CGImageRef dstImage = CGBitmapContextCreateImage(ctx);
	CGContextRelease(ctx);
	return dstImage;
}

@interface PhotoProcessViewController (ADBannerViewDelegate) <ADBannerViewDelegate>

@end


@implementation PhotoProcessViewController

@synthesize imageView = _imageView;
@synthesize scrollView = _scrollView;
@synthesize slider1 = _slider1 ;
@synthesize slider2 = _slider2;
@synthesize toolbar = _toolbar;
@synthesize picker = _picker;
@synthesize popover = _popover;
@synthesize activity = _activity;
@synthesize beforeImage = _beforeImage;
@synthesize currentType;
@synthesize banner;
@synthesize tapFlag;

- (void)dealloc {
	AudioServicesDisposeSystemSoundID(alertSoundID);
	
	if (_beforeImage) {
		CGImageRelease(_beforeImage);
		_beforeImage = nil;
	}
	
	[_imageView release];
	[_scrollView release];
	[_activity  release];
	[_slider1 release];
	[_slider2 release];
	[_toolbar release];
	[_picker release];
	[_popover release];
	[super dealloc];
}


#pragma mark 
#pragma mark ImageMagick



- (void) setCurrentType:(EffectType)newType
{
	currentType = newType;
	needSlider1 = YES;
	needSlider2 = NO;
}

- (NSString*) effectName:(EffectType)effectType
{
	NSString* name = nil;
	switch (effectType) {
		case Sepia:
			name = @"Sepia";
			break;
		case OilPaint:
			name = @"Oil Painting";
			break;
		case Negate:
			name = @"Negate";
			break;
		case Charcoal:
			name = @"Charcoal";
			break;
		case Solarize:
			name = @"Solarize";
			break;
		case Sketch:
			name = @"Sketch";
			break;
		case Spread:
			name = @"Spread";
			break;
		case Swirl:
			name = @"Swirl";
			break;
		case Blur:
			name = @"Blur";
			break;
		case Implode:
			name = @"Implode";
			break;
		case Emboss:
			name = @"Emboss";
			break;
		case Vignette:
			name = @"Vignette";
			break;
		case Shade:
			name = @"Shade";
			break;
		case Flip:
			name = @"Flip";
			break;
		default:
			name=@"No Effect";
			break;
	}
	return name;
}

-(MagickBooleanType) filterOilPainting:(MagickWand*)magick_wand{
	MagickBooleanType status;
	
	float ratio1 = self.slider1.value/20;
	status = MagickOilPaintImage(magick_wand,ratio1);  //2
	status = MagickRadialBlurImage(magick_wand,1);  // 1
	return status;
}

-(MagickBooleanType) filterSepiaTone:(MagickWand*)magick_wand{
	float ratio1 = self.slider1.value*1.5 + 80;
	return MagickSepiaToneImage(magick_wand,
								ratio1 );
}

-(MagickBooleanType) filterSketch:(MagickWand*)magick_wand{	
	float ratio1 = self.slider1.value/20;
	//MagickSeparateImageChannel(magick_wand, GreenChannel);
	return MagickSketchImage( magick_wand,ratio1,0,0.5);
}

-(MagickBooleanType) filterSpread:(MagickWand*)magick_wand{
	float ratio = self.slider1.value*0.3; // (0, 10.0)
	return MagickSpreadImage(magick_wand,ratio /*const double radius*/);
}

-(MagickBooleanType) filterWave:(MagickWand*)magick_wand{
	float ratio1 = self.slider1.value*0.1; // (0, 10.0)
	return MagickWaveImage(magick_wand,ratio1,160);
}

-(MagickBooleanType) filterRadialBlur:(MagickWand*)magick_wand{
	float ratio = self.slider1.value*0.2; // (0, 20.0)
	return MagickRadialBlurImage(magick_wand,ratio /*const double radius*/);
}

-(MagickBooleanType) filterNegate:(MagickWand*)magick_wand{
	float ratio = self.slider1.value;
	if (ratio < SLIDER_MAX/4) {
		return MagickNegateImage(magick_wand,FALSE);
	}else if (ratio < SLIDER_MAX/2 && ratio >= SLIDER_MAX/4) {
		MagickSeparateImageChannel(magick_wand,RedChannel);
		return MagickNegateImage(magick_wand,TRUE);
	}else if (ratio < SLIDER_MAX*3/4 && ratio >= SLIDER_MAX/2) {
		MagickSeparateImageChannel(magick_wand,BlueChannel);
		return MagickNegateImage(magick_wand,TRUE);
	}else {
		MagickSeparateImageChannel(magick_wand,GreenChannel);
		return MagickNegateImage(magick_wand,TRUE);
	}
}

-(MagickBooleanType) filterSolarize:(MagickWand*)magick_wand{
	float ratio = self.slider1.value*2.55; // (0, 255)
	return MagickSolarizeImage(magick_wand,ratio /*const double radius*/);
}
// long time 
-(MagickBooleanType) filterCharcoal:(MagickWand*)magick_wand{
	float ratio1 = self.slider1.value*0.025; // (0, 5.0)
	float ratio2 = self.slider2.value*0.05;
	return MagickCharcoalImage(magick_wand,ratio1,ratio2 );
}

-(MagickBooleanType) filterImplode:(MagickWand*)magick_wand{
	float ratio1 = (self.slider1.value - 70 ) *0.01; 
	return MagickImplodeImage(magick_wand,ratio1);
}

-(MagickBooleanType) filterEmboss:(MagickWand*)magick_wand{
	float ratio1 = self.slider1.value * 0.2 ; 
	return MagickEmbossImage(magick_wand,ratio1,1);
}

-(MagickBooleanType) filterVignette:(MagickWand*)magick_wand{
	float ratio1 = self.slider1.value * 2.55 ; 
	return MagickVignetteImage(magick_wand, ratio1, 255 - ratio1 , 5,5);
}

-(MagickBooleanType) filterShade:(MagickWand*)magick_wand{
	float ratio1 = self.slider1.value * 2.0 ; 
	return MagickShadeImage(magick_wand, MagickTrue, ratio1 , ratio1/6 );	
}

-(MagickBooleanType) filterFlip:(MagickWand*)magick_wand{
	float ratio = self.slider1.value;
	if (ratio < SLIDER_MAX/2) {
		return MagickFlipImage(magick_wand);	
	}else {
		return MagickFlopImage(magick_wand);
	}
}

-(MagickBooleanType) filterFrame:(MagickWand*)magick_wand{
	//return MagickEqualizeImage(magick_wand);
	float ratio = self.slider1.value;
	return MagickOrderedPosterizeImage(magick_wand, "h8x8o");
}

- (MagickBooleanType)posterizeImageWithCompression:(MagickWand*)magick_wand {
	
	//	NSData * dataObject = UIImagePNGRepresentation([UIImage imageWithCGImage:self.beforeImage]);//UIImageJPEGRepresentation([imageViewButton imageForState:UIControlStateNormal], 90);
	//	MagickBooleanType status;
	//	status = MagickReadImageBlob(magick_wand, [dataObject bytes], [dataObject length]);
	//	if (status == MagickFalse) {
	//		ThrowWandException(magick_wand);
	//	}
	MagickSetFormat(magick_wand, "tif");
	MagickSetImageDepth(magick_wand, 8);
	// posterize the image, this filter uses a configuration file, that means that everything in IM should be working great
	MagickBooleanType status = MagickOrderedPosterizeImageChannel(magick_wand, RedChannel, "o3x3,6");
	if (status == MagickFalse) {
		ThrowWandException(magick_wand);
	}
	return status;	//	
	//	size_t my_size;
	//	unsigned char * my_image = MagickGetImageBlob(magick_wand, &my_size);
	//	NSData * data = [[NSData alloc] initWithBytes:my_image length:my_size];
	//	free(my_image);
	//	magick_wand = DestroyMagickWand(magick_wand);
	//
	//	UIImage * image = [[UIImage alloc] initWithData:data];
	//	[data release];
	//	
	//	[imageViewButton setImage:image forState:UIControlStateNormal];
	//	[image release];
}



// multithread version

- (void) doFiltering:(id)cgImage {
	
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	CGImageRef srcCGImage = (CGImageRef)cgImage;
	
	const unsigned long width = CGImageGetWidth(srcCGImage);
	const unsigned long height = CGImageGetHeight(srcCGImage);
	// could use the image directly if it has 8/16 bits per component,
	// otherwise the image must be converted into something more common (such as images with 5-bits per component)
	// here we’ll be simple and always convert
	const char *map = "ARGB"; // hard coded
	const StorageType inputStorage = CharPixel;
	CGImageRef standardized = createStandardImage(srcCGImage);
	NSData *srcData1 = (NSData *) CGDataProviderCopyData(CGImageGetDataProvider(standardized));
	CGImageRelease(standardized);
	const void *bytes = [srcData1 bytes];
	const size_t length = [srcData1 length];
	MagickWandGenesis();
	MagickWand * magick_wand_local= NewMagickWand();
	MagickBooleanType status = MagickConstituteImage(magick_wand_local, width, height, map, inputStorage, bytes);
	if (status == MagickFalse) {
		ThrowWandException(magick_wand_local);
	}
	
	// effects algorithm here
    
	switch (currentType) {
		case -1:
			//nothing to do
			break;
		case Sepia:
			status = [self filterSepiaTone:magick_wand_local];
			break;
		case OilPaint:
			status = [self filterOilPainting:magick_wand_local];
			break;
		case Negate:
			status = [self filterNegate:magick_wand_local];
			break;
		case Charcoal:
			status = [self filterCharcoal: magick_wand_local];
			break;
		case Solarize:
			status = [self filterSolarize:magick_wand_local];
			break;
		case Sketch:
			status = [self filterSketch:magick_wand_local];
			break;
		case Swirl:
			status = [self filterWave:magick_wand_local];
			break;
		case Spread:
			status = [self filterSpread:magick_wand_local];
			break;
		case Blur:
			status = [self filterRadialBlur:magick_wand_local];
			break;
		case Implode:
			status = [self filterImplode:magick_wand_local];
			break;
		case Emboss:
			status = [self filterEmboss:magick_wand_local];
			break;
		case Vignette:
			status = [self filterVignette:magick_wand_local];
			break;
		case Shade:
			status = [self filterShade:magick_wand_local];
			break;
		case Flip:
			status = [self filterFlip:magick_wand_local];
			break;
		default:
			break;
	}
	
	const int bitmapBytesPerRow = (width * strlen(map));
	const int bitmapByteCount = (bitmapBytesPerRow * height);
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	char *trgt_image = malloc(bitmapByteCount);
	status = MagickExportImagePixels(magick_wand_local, 0, 0, width, height, map, CharPixel, trgt_image);
	if (status == MagickFalse) {
		ThrowWandException(magick_wand_local);
	}
	magick_wand_local = DestroyMagickWand(magick_wand_local);
	MagickWandTerminus();
	CGContextRef context = CGBitmapContextCreate (trgt_image,
												  width,
												  height,
												  8, // bits per component
												  bitmapBytesPerRow,
												  colorSpace,
												  kCGImageAlphaPremultipliedFirst);
	CGColorSpaceRelease(colorSpace);
	CGImageRef cgimage = CGBitmapContextCreateImage(context);
	UIImage *image = [[UIImage alloc] initWithCGImage:cgimage];
	
	NSLog(@"image size %f %f",image.size.width,image.size.height );
	[self.imageView	performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:YES];
	[self performSelectorOnMainThread:@selector(hideProgressIndicator) withObject:nil waitUntilDone:YES];
	
	CGImageRelease(cgimage);
	CGContextRelease(context);
	[srcData1 release];
	free(trgt_image);
	[image release];
	[pool drain];
}


#pragma mark -
#pragma mark Utilities for intarnal use

- (void)showProgressIndicator:(NSString *)text {
	
	self.view.userInteractionEnabled = FALSE;
	self.activity.labelText = text;
	[self.activity show];
}

- (void)hideProgressIndicator {
	self.view.userInteractionEnabled = TRUE;
	[self.activity hide];
	AudioServicesPlaySystemSound(alertSoundID);
}

#pragma mark -
#pragma mark UIViewControllerDelegate

- (void)viewDidLoad {
	[super viewDidLoad];
	
	//background texture
	NSString *file = @"frame2.png";
	int r = arc4random() % 2;
	//NSLog(@"test random %d",r);
	if (r == 1 ) {
		file = @"frame1.png";
	}
	UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:file]];
	backgroundView.frame = self.view.bounds;
	[self.view addSubview:backgroundView];
	[backgroundView release];
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
	NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Tink" ofType:@"aiff"] isDirectory:NO];
	AudioServicesCreateSystemSoundID((CFURLRef)url, &alertSoundID);
	
	
	[self.view addSubview:self.scrollView];
	[self.view addSubview:self.toolbar];
	[self.view addSubview:self.slider1];
    [self.view addSubview:self.slider2];
	
	[self setCurrentType:appType];
	
	if (![MKStoreManager isFeaturePurchased:kIAPProUpgrade]) {
		LogX();
		[self.view addSubview:self.banner];
		[self layoutForCurrentOrientation:NO];
	}
}

- (void) tapAction
{
	[UIView animateWithDuration:.8 animations:^{
        if (tapFlag ) {
            tapFlag = NO;
            _toolbar.alpha = 0.8;
            _slider1.alpha = 0;
            _slider2.alpha = 0;

        }else{
        
            tapFlag = YES;
            _toolbar.alpha = 0;
            _slider1.alpha = 0.8;
            _slider2.alpha = 0.8;
		}
        self.scrollView.zoomScale = 1.0;
	}];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return interfaceOrientation == UIInterfaceOrientationPortrait || 
	interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown;
}

- (void) adjustEffect:(id)sender{
	if(self.imageView.image){
		[self showProgressIndicator:[self effectName:currentType]];
		[self performSelectorInBackground:@selector(doFiltering:) withObject:self.beforeImage];
	}
}
#pragma mark 
#pragma mark UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView    // return a view that will be scaled. if delegate returns nil, nothing happens
{
	return self.imageView;
}

#pragma mark 
#pragma mark property 

- (LabeledActivityIndicatorView*) activity
{
	if (!_activity) {
		_activity = [[LabeledActivityIndicatorView alloc] initWithController:self andText:@"Rendering..."];
	}
	return _activity;
}

- (UIScrollView*) scrollView
{
	if (_scrollView == nil) {
		
		CGRect fullRect = self.view.bounds;
		CGRect photoFrame = CGRectMake((fullRect.size.width - PHOTO_WIDTH)/2, 
									   (fullRect.size.height - PHOTO_HEIGHT - 40)/2, PHOTO_WIDTH, PHOTO_HEIGHT);
		
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad  ) {
			photoFrame = CGRectMake((fullRect.size.width - PHOTO_WIDTH*2)/2, 
									(fullRect.size.height - PHOTO_HEIGHT*2 - 60)/2, PHOTO_WIDTH*2, PHOTO_HEIGHT*2);
		}
		
		_scrollView = [[UIScrollView alloc] initWithFrame:photoFrame];
		_scrollView.contentSize = photoFrame.size; //self.imageView.frame.size; //
		_scrollView.scrollEnabled = YES;
		_scrollView.contentMode = UIViewContentModeScaleAspectFit;
		_scrollView.autoresizingMask =  UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_scrollView.maximumZoomScale = 2.0;
		_scrollView.minimumZoomScale = .5;
		_scrollView.clipsToBounds = YES;
		_scrollView.delegate = self;
		[_scrollView addSubview:self.imageView];
		
		//Tap event 
		UITapGestureRecognizer	*tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
		[_scrollView addGestureRecognizer:tap];
		[tap release];
		
		
	}
	return _scrollView;
}
- (ADBannerView*) banner
{
	if(banner == nil)
    {
        [self createADBannerView];
    }
	return banner;
}
- (UIToolbar*) toolbar 
{
	if (!_toolbar) {
		_toolbar = [[UIToolbar alloc] init ];
		CGRect fullRect = [UIScreen mainScreen].applicationFrame;
		CGRect myBounds = self.view.bounds;
		UIBarButtonItem *loadItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
																				  target:self action:@selector(loadImage:)];
		
		UIBarButtonItem *effectsPickr = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_effect.png"] 
																		 style:UIBarButtonItemStylePlain target:self 
																		action:@selector(pickupEffect:)];
	
		
		
		UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_share.png"] 
																	  style:UIBarButtonItemStylePlain target:self
																				    action:@selector(shareImage:)];
		
		UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
		//_toolbar.items = [NSArray arrayWithObjects:loadItem, spaceItem,effectsPickr,spaceItem, shareItem, nil];
		_toolbar.items = [NSArray arrayWithObjects:loadItem,spaceItem, shareItem, nil];
        
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			_toolbar.frame = CGRectMake(0, CGRectGetMaxY(myBounds) - TOOLBAR_HEIGHT_PAD, fullRect.size.width,  TOOLBAR_HEIGHT_PAD);
			//loadItem.title = @"Load Photo";
//			effectsPickr.title = @"Pickup Effect";
//			shareItem.title = @"Share Photo";
			
		}else {
			_toolbar.frame = CGRectMake(0, CGRectGetMaxY(myBounds) - TOOLBAR_HEIGHT, fullRect.size.width,  TOOLBAR_HEIGHT);
		}
		
		_toolbar.barStyle = UIBarStyleBlackTranslucent;
		_toolbar.alpha = .7f;
		[spaceItem release];
		[shareItem release];
		[effectsPickr release];
	}
	return _toolbar;
}

- (UIPopoverController*) popover
{
	if (!_popover) {
		_popover = [[UIPopoverController alloc] initWithContentViewController:self.picker];
		[_popover setDelegate:self];
	}
	return _popover;
}

- (UIImagePickerController*) picker
{
	if (!_picker) {
		_picker = [[UIImagePickerController alloc] init];
		_picker.delegate = self;
	}
	return _picker;
}

- (void) setBeforeImage:(CGImageRef)newImage
{
	if (newImage == _beforeImage) {
		return;
	}
	CGImageRelease(_beforeImage);
	_beforeImage = CGImageCreateCopy(newImage);
}

- (UIImageView*) imageView
{
	if (!_imageView) {
		UIImage *defaultImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:defaultFile ofType:@"png"]];
		_imageView = [[UIImageView alloc] initWithImage:defaultImage];
		_imageView.frame = CGRectMake(0, 0, PHOTO_WIDTH, PHOTO_HEIGHT);
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			_imageView.frame = CGRectMake(0, 0, PHOTO_WIDTH*2, PHOTO_HEIGHT*2);
		}
		_imageView.contentMode = UIViewContentModeScaleAspectFit;
		CGImageRef standardImage = createStandardImage(_imageView.image.CGImage);
		self.beforeImage = standardImage;
		CGImageRelease(standardImage);
	}
	return _imageView;
}

- (UISlider*) slider1
{
	if (!_slider1) {
		CGRect fullRect = [UIScreen mainScreen].applicationFrame;
		CGRect slider = CGRectMake(fullRect.size.width/10, fullRect.size.height*0.85, fullRect.size.width*0.8, 10);
		_slider1 = [MyUIBox yellowSlider:slider withMax:SLIDER_MAX withMin:SLIDER_MIN withValue:SLIDER_DEFAULT withLabel:@"nil"];
		_slider1.alpha = 0.7;
		[_slider1 addTarget:self action:@selector(adjustEffect:) forControlEvents:UIControlEventValueChanged];
	}
	return _slider1;
}
//simplify , just have 1 slider1 now 
- (UISlider*) slider2
{
	if (!_slider2) {
		CGRect fullRect = [UIScreen mainScreen].applicationFrame;
		CGRect slider = CGRectMake(fullRect.size.width/10, fullRect.size.height*0.85 + 35, fullRect.size.width*0.8, 10);
		_slider2 = [MyUIBox yellowSlider:slider withMax:SLIDER_MAX withMin:SLIDER_MIN withValue:SLIDER_DEFAULT withLabel:@"nil"];
		_slider2.alpha = 0.7;
		[_slider2 addTarget:self action:@selector(adjustEffect:) forControlEvents:UIControlEventValueChanged];
	}
	return _slider2;

}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	UIImagePickerControllerSourceType sourceType;
	if (buttonIndex == 0) {
		sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	} else if(buttonIndex == 1) {
		sourceType = UIImagePickerControllerSourceTypeCamera;
	} else if(buttonIndex == 2) {
		NSString *path = [[NSBundle mainBundle] pathForResource:defaultFile ofType:@"png"];
		self.imageView.image = [UIImage imageWithContentsOfFile:path];
		CGImageRef standardImage = createStandardImage(_imageView.image.CGImage);
		self.beforeImage = standardImage;
		CGImageRelease(standardImage);	} 
	if([UIImagePickerController isSourceTypeAvailable:sourceType]) {
		self.picker.sourceType = sourceType;
		[self presentModalViewController:self.picker animated:YES];
	}
}
#pragma mark -
#pragma mark IBAction

- (void) resetData
{
	currentType = appType;  // take 0 as default effect type  
	[self.slider1 setValue:SLIDER_DEFAULT];
}

- (IBAction)loadImage:(id)sender {
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[self showPhotoLibrary:sender];
	}else {
		UIActionSheet *actionSheet;
		
		actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose Photo"
												  delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
										 otherButtonTitles:@"From Photo Album", @"Capture With Camera",@"Sample Photo", nil];
		actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
		[actionSheet showInView: self.imageView ];
		[actionSheet release];
	}
	[self resetData];
	
}

- (IBAction)shareImage:(id)sender {
	if(self.imageView.image) {
		
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			[self.popover dismissPopoverAnimated:YES];
		}
		
		SHKItem *item = [SHKItem image:self.imageView.image title:title];
		item.text = message;// @"More Applications from us http://DesignForApple.com";
		
		// Get the ShareKit action sheet
		SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
		actionSheet.backgroundColor = [UIColor clearColor];
		// Display the action sheet
		[actionSheet showInView:self.view];
	}
}

- (IBAction) saveImage:(id)sender{
    
}

-(IBAction)pickupEffect:(id)sender{
	EffectsTableViewController	*etvc = [[EffectsTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
	etvc.delegate = self;
	etvc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	[self presentModalViewController:etvc animated:YES];
	[etvc release];
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

-(void) showPhotoLibrary:(id)sender
{	
	if (sender != nil) {
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			[self.popover presentPopoverFromBarButtonItem:sender 
								 permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
			
		}
	}
	
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
	UIImage* selectedImage = [MyImageKit scaleAndRotateImage:[info	objectForKey:@"UIImagePickerControllerOriginalImage"]];
	NSLog(@"selectedImage %f %f ", selectedImage.size.width , selectedImage.size.height);
	
	CGImageRef standardImage = createStandardImage(selectedImage.CGImage);
	self.beforeImage = standardImage;
	CGImageRelease(standardImage);	
	NSLog(@"standardImage size %f %f",CGImageGetWidth(self.beforeImage),CGImageGetHeight(self.beforeImage) );
	
	self.imageView.image =  selectedImage; //[MyImageKit scaleAndRotateImage:selectedImage];
	[[picker parentViewController] dismissModalViewControllerAnimated:YES];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[[picker parentViewController] dismissModalViewControllerAnimated:YES];
}

#pragma mark 
#pragma mark FlipbackDelegate
- (void) flipback:(EffectType)type
{
	[self dismissModalViewControllerAnimated:YES];
	//reset adjustment parameters
	[self.slider1 setValue:SLIDER_DEFAULT];
	//reset image
	self.imageView.image = [UIImage imageWithCGImage: self.beforeImage];
	if (type < UpgradePro) {
		self.currentType = (EffectType) type;
		//process image with selected filter
		[self adjustEffect:nil];
	}else {
		switch (type) {
			case UpgradePro:
				//upgrade to pro
				[self upgradePro];
				break;
			default:
				break;
		}
	}
	
}

- (void) returnback:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void)upgradePro {
	
	if (![MKStoreManager isFeaturePurchased:kIAPProUpgrade ]) {
		LogX();
		[[MKStoreManager sharedManager] buyFeature:kIAPProUpgrade];
	}else {
		LogX();
		UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:@"Upgrade Pro" message:@"You had already bought this item" 
														   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
		[alterView show];
		[alterView release];
	}
	
}


@end

@implementation PhotoProcessViewController (ADBannerViewDelegate)


-(void)createADBannerView
{
    // --- WARNING ---
    // If you are planning on creating banner views at runtime in order to support iOS targets that don't support the iAd framework
    // then you will need to modify this method to do runtime checks for the symbols provided by the iAd framework
    // and you will need to weaklink iAd.framework in your project's target settings.
    // See the iPad Programming Guide, Creating a Universal Application for more information.
    // http://developer.apple.com/iphone/library/documentation/general/conceptual/iPadProgrammingGuide/Introduction/Introduction.html
    // --- WARNING ---
	
    // Depending on our orientation when this method is called, we set our initial content size.
    // If you only support portrait or landscape orientations, then you can remove this check and
    // select either ADBannerContentSizeIdentifierPortrait (if portrait only) or ADBannerContentSizeIdentifierLandscape (if landscape only).
	NSString *contentSize;
	if (&ADBannerContentSizeIdentifierPortrait != nil)
	{
		contentSize = UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? ADBannerContentSizeIdentifierPortrait : ADBannerContentSizeIdentifierLandscape;
	}
	else
	{
		// user the older sizes 
		contentSize = UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? ADBannerContentSizeIdentifier320x50 : ADBannerContentSizeIdentifier480x32;
    }
	
    // Calculate the intial location for the banner.
    // We want this banner to be at the bottom of the view controller, but placed
    // offscreen to ensure that the user won't see the banner until its ready.
    // We'll be informed when we have an ad to show because -bannerViewDidLoadAd: will be called.
    CGRect frame;
    frame.size = [ADBannerView sizeFromBannerContentSizeIdentifier:contentSize];
    frame.origin = CGPointMake(0.0f, CGRectGetMinY(self.view.bounds));
	
    // Now to create and configure the banner view
    ADBannerView *bannerView = [[ADBannerView alloc] initWithFrame:frame];
    // Set the delegate to self, so that we are notified of ad responses.
    bannerView.delegate = self;
    // Set the autoresizing mask so that the banner is pinned to the bottom
    bannerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
    // Since we support all orientations in this view controller, support portrait and landscape content sizes.
    // If you only supported landscape or portrait, you could remove the other from this set.
    
	bannerView.requiredContentSizeIdentifiers = (&ADBannerContentSizeIdentifierPortrait != nil) ?
	[NSSet setWithObjects:ADBannerContentSizeIdentifierPortrait, ADBannerContentSizeIdentifierLandscape, nil] : 
	[NSSet setWithObjects:ADBannerContentSizeIdentifier320x50, ADBannerContentSizeIdentifier480x32, nil];
	
    // At this point the ad banner is now be visible and looking for an ad.
    self.banner = bannerView;
	[bannerView release];
}

-(void)layoutForCurrentOrientation:(BOOL)animated
{
    CGFloat animationDuration = animated ? 0.2f : 0.0f;
    // by default content consumes the entire view area
    CGRect contentFrame = self.view.bounds;
    // the banner still needs to be adjusted further, but this is a reasonable starting point
    // the y value will need to be adjusted by the banner height to get the final position
	CGPoint bannerOrigin = CGPointMake(CGRectGetMinX(contentFrame), CGRectGetMinY(contentFrame));
    CGFloat bannerHeight = 0.0f;
    
    // First, setup the banner's content size and adjustment based on the current orientation
    if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
		banner.currentContentSizeIdentifier = (&ADBannerContentSizeIdentifierLandscape != nil) ? ADBannerContentSizeIdentifierLandscape : ADBannerContentSizeIdentifier480x32;
    else
        banner.currentContentSizeIdentifier = (&ADBannerContentSizeIdentifierPortrait != nil) ? ADBannerContentSizeIdentifierPortrait : ADBannerContentSizeIdentifier320x50; 
    bannerHeight = banner.bounds.size.height; 
	
    // Depending on if the banner has been loaded, we adjust the content frame and banner location
    // to accomodate the ad being on or off screen.
    if(banner.bannerLoaded)
    {
        contentFrame.size.height -= bannerHeight;
		contentFrame.origin.y += bannerHeight;
    }
	UIView* view = self.imageView;
    // And finally animate the changes, running layout for the content view if required.
	[UIView animateWithDuration:animationDuration
					 animations:^{
						 view.frame = contentFrame;
						 [view layoutIfNeeded];
						 banner.frame = CGRectMake(bannerOrigin.x, bannerOrigin.y, banner.frame.size.width, banner.frame.size.height);
					 }];
}


-(void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    [self layoutForCurrentOrientation:YES];
}

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    [self layoutForCurrentOrientation:YES];
}

-(BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    return YES;
}

-(void)bannerViewActionDidFinish:(ADBannerView *)banner
{
}

@end