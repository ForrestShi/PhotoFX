//
//  SelectPhotoViewController.m
//  PhotoFX
//
//  Created by forrest on 11-4-10.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "SelectPhotoViewController.h"
#import "MyImageKit.h"

@implementation SelectPhotoViewController
@synthesize selectedImageButton;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction) photoFromAlbum: (id)sender{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	
	if([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
		picker.sourceType = sourceType;
        picker.delegate = self;
		[self presentModalViewController:picker animated:YES];
	}
}

#pragma mark UIImagePickerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    TTDPRINT(@"pick image from album");
    UIImage* selectedImage = [MyImageKit scaleAndRotateImage:[info	objectForKey:@"UIImagePickerControllerOriginalImage"]];
	NSLog(@"selectedImage %f %f ", selectedImage.size.width , selectedImage.size.height);
    [self performSelectorOnMainThread:@selector(setPreviewImage:) withObject:selectedImage waitUntilDone:YES];

    
    [self dismissModalViewControllerAnimated:YES];    

    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    TTDPRINT(@"cancel picker" );
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark set up preview image button
-(void) setPreviewImage:(UIImage*)image{
    [self.selectedImageButton setImage:image forState:UIControlStateNormal];
}

#pragma mark go to launcher view with selected UIImage 
-(IBAction) startLauncerView: (id)sender{
    
    
}
@end
