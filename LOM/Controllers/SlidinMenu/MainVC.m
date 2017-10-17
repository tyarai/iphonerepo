//
//  MainVC.m
//  LOM
//
//  Created by Andrianavonison Ranto Tiaray on 25/11/2015.
//  Copyright © 2015 Kerty KAMARY. All rights reserved.
//

#import "MainVC.h"
#import "Tools.h"
#import "LoginResult.h"


@interface MainVC ()

@end

static MainVC *sharedMainVC = nil;

@implementation MainVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    sharedMainVC = self;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = NO;
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated{
//[self checkUserSession];
}

-(void)viewWillAppear:(BOOL)animated{
    //[self checkUserSession];
}



-(void) checkUserSession{
    AppDelegate * appDelegate = [Tools getAppDelegate];
    if([Tools isNullOrEmptyString:appDelegate._currentToken]){
        [self showLoginPopup];
    }
    /*else{
        [self performSelector:@selector(presentMain) withObject:nil afterDelay:3.0f];
    }*/
}
-(void) showLoginPopup{
    NSString* indentifier=@"PopupLoginViewController";
    
    loginViewController = (PopupLoginViewController*) [Tools getViewControllerFromStoryBoardWithIdentifier:indentifier];
    loginViewController.delegate = self;
    
    [self presentViewController:loginViewController animated:YES completion:nil];
    
}


- (void) validWithUserName:(NSString*) userName password:(NSString*) password andRememberMe:(BOOL) rememberMe
{
    
    AppData * appData = [AppData getInstance];
    
    [appData loginWithUserName:userName andPassword:password forCompletion:^(id json, JSONModelError *err) {
        
        //[self removeActivityScreen];
        
        AppDelegate * appDelegate = [Tools getAppDelegate];
        
        if (err)
        {
            [Tools showError:err onViewController:loginViewController];
        }
        else
        {
            NSError* error;
            NSDictionary* tmpDict = (NSDictionary*) json;
            LoginResult* loginResult = [[LoginResult alloc] initWithDictionary:tmpDict error:&error];
            
            if (error)
            {
                NSLog(@"Error parse : %@", error.debugDescription);
            }
            else
            {
                if (![Tools isNullOrEmptyString:loginResult.sessid]
                    &&![Tools isNullOrEmptyString:loginResult.session_name]
                    &&![Tools isNullOrEmptyString:loginResult.token]
                    && loginResult.user != nil) {
                    
                    
                    if (rememberMe) {
                        [Tools saveSessId:loginResult.sessid
                              sessionName:loginResult.session_name
                                 andToken:loginResult.token
                                      uid:loginResult.user.uid
                                 userName:userName];
                    }
                    
                    appDelegate._currentToken = loginResult.token;
                    appDelegate._curentUser = loginResult.user;
                    appDelegate._sessid = loginResult.sessid;
                    appDelegate._sessionName = loginResult.session_name;
                    appDelegate._uid    = loginResult.user.uid;
                    
                    [appDelegate syncSettings]; // Asaina mi-load settings avy any @ serveur avy hatrany eto
                    
                    [self dismissViewControllerAnimated:YES completion:nil];
                    
                    
                }
            }
        }
        
    }];
    
}

#pragma mark WYPopoverControllerDelegate
- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller{
    return YES;
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller{
    popoverController.delegate = nil;
    popoverController = nil;
}

#pragma mark LoginPopoverDelegate

- (void) cancel{
    [popoverController dismissPopoverAnimated:YES];
}

- (void) presentMain{
    [self performSegueWithIdentifier:@"presentMain" sender:self];
}


+ (id)sharedMainVC{
    @synchronized(self) {
        if(sharedMainVC == nil)
            sharedMainVC = [[MainVC alloc] init];
    }
    return sharedMainVC;
}



- (void)configureLeftMenuButton:(UIButton *)button{
    button.frame = CGRectMake(0, 0, 32, 32);
    [button setImage:[UIImage imageNamed:@"ico_menu"] forState:UIControlStateNormal];
}


- (CGFloat) leftMenuWidth{
    return (([Tools getScreenWidth] * 2) / 3) + 25;
}


- (BOOL)deepnessForLeftMenu{
    return NO;
}


- (NSIndexPath *)initialIndexPathForLeftMenu
{
    return [NSIndexPath indexPathForRow:5 inSection:0];
}



- (NSString*) segueIdentifierForIndexPathInLeftMenu:(NSIndexPath *)indexPath{
    NSString* identifier;
    
    switch (indexPath.row) {
        case 0:
            identifier = @"";
            break;
        case 1:
            identifier = INTRODUCTION_MENU_SEGUE;
            break;
        case 2:
            identifier = ORIGINOFLEMURS_MENU_SEGUE;
            break;
        case 3:
            identifier = EXTINCT_LEMURS_MENU_SEGUE;
            break;
        case 4:
            identifier = BIOS_MENU_SEGUE;
            break;
        case 5:
            identifier = SPECIES_MENU_SEGUE;
            break;
        case 6:
            identifier = FAMILIES_MENU_SEGUE;
            break;
        case 7 :
            identifier = WATCHING_SITE_MENU_SEGUE;
            break;
        case 8:
            identifier = POSTS_MENU_SEGUE;
            break;
        case 9 :
            identifier = WATCHING_LIST_MENU_SEGUE;
            break;
        case 10:
            identifier = ABOUT_MENU_SEGUE;
            break;
        case 11:
            identifier = SETTINGS_MENU_SEGUE;
            break;
        case 12:
            identifier = APPINSTRUCTIONS_MENU_SEGUE;
            break;
    
        
    }
    
    return identifier;
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
