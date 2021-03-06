//
//  WatchingSiteDetailsViewController.m
//  LOM
//
//  Created by Andrianavonison Ranto Tiaray on 01/01/2016.
//  Copyright © 2016 Kerty KAMARY. All rights reserved.
//

#import "WatchingSiteDetailsViewController.h"
#import "Tools.h"

@interface WatchingSiteDetailsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UITextView *txtText;

@end

@implementation WatchingSiteDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.lblTitle.text = self.lemursWatchingSites._title;
    self.txtText.text = self.lemursWatchingSites._body;
    
    
    //self.navigationItem.titleView = nil;
    //self.navigationItem.title = self.lemursWatchingSites._title;
    //[self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor whiteColor] }];

}

-(void)viewWillAppear:(BOOL)animated{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.txtText scrollRangeToVisible:NSMakeRange(0, 0)];
    });

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if( [[segue identifier] isEqualToString:@"showSiteMap"]){
        WatchingSiteMap* vc = (WatchingSiteMap*)[segue destinationViewController];
        if(vc != nil){
            vc.delegate = self;
            AppDelegate* appDelegate = [Tools getAppDelegate];
            appDelegate.appDelegateTemporarySite = self.lemursWatchingSites;
        }
    }
}


- (IBAction)btnBack_Touch:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)dismissSiteMapViewController{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

