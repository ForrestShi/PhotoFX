    //
//  PreviewViewController.m
//  PhotoEffects
//
//  Created by forrest on 11-2-23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PreviewViewController.h"


@implementation PreviewViewController
@synthesize delegate;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
		NSLog(@"%s",__FUNCTION__);
		self.view.backgroundColor = [UIColor redColor];
    }
    return self;
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	UIButton *doneItem = [[UIButton alloc] initWithFrame:CGRectMake(200, 30, 80, 60)];
	doneItem.backgroundColor = [UIColor blueColor];
	[doneItem addTarget:self action:@selector(actionDone:) forControlEvents:UIControlEventTouchUpInside];

	[self.view addSubview:doneItem];
	[doneItem release];
}

-(void) actionDone:(id)sender
{
	NSLog(@"done");
	[delegate returnback:sender];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
