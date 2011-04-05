//
//  EffectsTableViewController.m
//  ABCPhotoEffects
//
//  Created by forrest on 11-1-30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EffectsTableViewController.h"
#import "EffectCatagory.h"
#import "PreviewViewController.h"

@implementation EffectsTableViewController

@synthesize effectsArray = _effectsArray;
@synthesize colorEffects = _colorEffects;
@synthesize delegate;

#pragma mark -
#pragma mark Initialization



- (void)dealloc {
	[_effectsArray release];
    [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization.
    }
    return self;
}



#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
   

	self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
	self.view.backgroundColor = [UIColor clearColor];
	
}

- (NSMutableArray*) effectsArray
{
	if (_effectsArray == nil ) {
		_effectsArray = [[NSMutableArray alloc] init];
		[self loadFilters:@"Color Effects" fromPlist:@"color" toArray:_effectsArray];
		[self loadFilters:@"Funny Effects" fromPlist:@"funny" toArray:_effectsArray];
		[self loadFilters:@"Artist Effects" fromPlist:@"art" toArray:_effectsArray];
		[self loadFilters:@"In App Purchase" fromPlist:@"purchase" toArray:_effectsArray];

	}
	return _effectsArray;
}

- (void) loadFilters:(NSString*) categoryName fromPlist:(NSString*) fileName toArray:(NSMutableArray*) effects 
{
	EffectCatagory	*category = [[EffectCatagory alloc] init];
	category.categoryName = categoryName;
	
	NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
	NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:path];
	category.filtersArray = array;
	[array release];	
	
	[effects addObject:category];
	[category release];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [self.effectsArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	EffectCatagory	*category = (EffectCatagory*)[self.effectsArray objectAtIndex:section];
	return [category.filtersArray count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section    // fixed font style. use custom view (UILabel) if you want something different
{
	EffectCatagory	*category = (EffectCatagory*)[self.effectsArray objectAtIndex:section];
	return [category categoryName];	
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	EffectCatagory *effectKind = (EffectCatagory*)[self.effectsArray objectAtIndex:indexPath.section];
	NSArray *effects = effectKind.filtersArray;
	id effect = [effects objectAtIndex:indexPath.row];
	if (effect) {
		cell.textLabel.text = [effect valueForKey:@"name"];
		cell.textLabel.textColor = [UIColor blueColor];
		UIImage* previewImg = [UIImage imageNamed:[effect valueForKey:@"preview"]];//[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[[effect valueForKey:@"name"]] ofType:@"png"];
		
		//cell.imageView.frame = CGRectMake(30, 30, 128, 128);
		cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
		cell.imageView.bounds = CGRectMake(0, 0, 128, 128);
		cell.imageView.autoresizingMask =  ( UIViewAutoresizingFlexibleWidth || UIViewAutoresizingFlexibleHeight );
		cell.imageView.image =previewImg;
		cell.detailTextLabel.text = [effect valueForKey:@"detail"];
		cell.detailTextLabel.textColor = [UIColor lightGrayColor];
		cell.backgroundColor = [UIColor clearColor];
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
	
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath;
{
	if ([delegate respondsToSelector:@selector(flipback:)]) {
		[delegate performSelector:@selector(flipback:) withObject:(indexPath.section*100 + indexPath.row)];
	}
	
}

#pragma mark 
#pragma mark FlipbackDelegate
- (void) returnback:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


@end

