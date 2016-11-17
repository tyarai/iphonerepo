//
//  SightingDataTableViewController.h
//  LOM
//
//  Created by Ranto Andrianavonison on 10/10/2016.
//  Copyright © 2016 Kerty KAMARY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Species.h"
#import "Publication.h"

@protocol SightingDataTableViewControllerDelegate <NSObject>
@optional
- (void) cancelSightingData;
- (void) saveSightingInfo:(NSInteger) observation placeName:(NSString*) placeName date:(NSDate*) date comments:(NSString*) comments;
@end



@interface SightingDataTableViewController : UITableViewController <UITextViewDelegate,UITextFieldDelegate>

@property (nonatomic, retain) id<SightingDataTableViewControllerDelegate> delegate;
- (IBAction)cancelTapped:(id)sender;
- (IBAction)doneTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *numberObserved;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *doneBUtton;
@property (weak, nonatomic) IBOutlet UIImageView *speciesImage;

@property (weak, nonatomic) IBOutlet UIDatePicker *date;
@property (weak, nonatomic) IBOutlet UITextField *placename;
@property (weak, nonatomic) IBOutlet UITextField *comments;

@property (weak, nonatomic) IBOutlet UILabel *speciesLabel;
@property (strong) Species * species;
@property (strong) Publication * publication;
@property  (strong,nonatomic) id SpeciesDetailsViewController;
@property (strong,nonatomic) UIImage * takenPhoto;


@end
