//
//  SelectPhotoViewController.h
//  PhotoFX
//
//  Created by forrest on 11-4-10.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//


#import "Three20/Three20.h"

@interface SelectPhotoViewController : TTViewController <UIImagePickerControllerDelegate> {
    IBOutlet UIButton   *selectedImageButton;
    UIImage *_image;

}
@property (nonatomic,retain) IBOutlet UIButton   *selectedImageButton;
@property (nonatomic,retain) UIImage *image;

-(IBAction) photoFromAlbum: (id)sender;
-(IBAction) startLauncerView: (id)sender;
@end
