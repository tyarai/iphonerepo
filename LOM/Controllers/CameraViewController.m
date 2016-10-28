//
//  CameraViewController.m
//  LOM
//
//  Created by Ranto Andrianavonison on 08/10/2016.
//  Copyright © 2016 Kerty KAMARY. All rights reserved.
//

#import "CameraViewController.h"
#import "Constants.h"
#import "PhotoCollectionViewCell.h"
#import "SightingsInfoViewController.h"
#import "SightingDataTableViewController.h"
#import "Tools.h"
#import "Sightings.h"
#import "AppDelegate.h"
#import "User.h"
#import "UserConnectedResult.h"
#import "UIImage+Resize.h"


#define FILE_EXT @".jpeg"

@interface CameraViewController ()

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.imageView.backgroundColor = nil;
    self.takePhotoButton.tintColor = ORANGE_COLOR;
    self.cancelButton.tintColor = ORANGE_COLOR;
    self.saveSightingButton.tintColor = ORANGE_COLOR;
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)takePhoto:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (IBAction)cancelPhoto:(id)sender {
    [self.delegate dismissCameraViewController];
}

#pragma UIImagePickerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage * image = info[UIImagePickerControllerOriginalImage];
    
    self.imageView.image = image;
    self.photoFileName = [self saveImageToFile:image];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(UIImage*) resizeImage:(UIImage*) image scaledSize:(CGSize) newSize{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(UIImage *)resizeImage:(UIImage *)image newWidth:(float)maxWidth newHeight:(float)maxHeight
{
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    //float maxHeight = 300.0;
    //float maxWidth = 400.0;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = maxWidth/maxHeight;
    float compressionQuality = 0.75;//50 percent compression
    
    if (actualHeight > maxHeight || actualWidth > maxWidth)
    {
        if(imgRatio < maxRatio)
        {
            //adjust width according to maxHeight
            imgRatio = maxHeight / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = maxHeight;
        }
        else if(imgRatio > maxRatio)
        {
            //adjust height according to maxWidth
            imgRatio = maxWidth / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = maxWidth;
        }
        else
        {
            actualHeight = maxHeight;
            actualWidth = maxWidth;
        }
    }
    
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    NSData *imageData = UIImageJPEGRepresentation(img, compressionQuality);
    UIGraphicsEndImageContext();
    
    return [UIImage imageWithData:imageData];
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(NSString*) saveImageToFile:(UIImage*) image{
    if(image){
        //UIImage *resizedImage = [self resizeImage:image newWidth:1024 newHeight:724];
        //UIImage * resizedImage = [image  resizedImage:CGSizeMake(1024, 768) interpolationQuality:1];
        
        //UIImage * resizedImage = [image scaledImageToSize:CGSizeMake(1024, 1024)];
        
        UIImage * resizedImage = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit                                                                     bounds:CGSizeMake(IMAGE_RESIZED_WIDTH , IMAGE_RESIZED_HEIGHT)
                                               interpolationQuality:1];
        
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * title = self.currentSpecies._title;
        title = [title stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        NSString * fileName = [NSString stringWithFormat: @"%ld_%@", appDelegate._uid, title];
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"_yyyy-MM-dd_HH_mm_ss"];
        NSString * date = [dateFormatter stringFromDate:[NSDate date]];
        fileName = [fileName stringByAppendingString:date];
        fileName = [fileName stringByAppendingString:FILE_EXT];
        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
        
       [UIImageJPEGRepresentation(resizedImage, 1.0)writeToFile:filePath atomically:YES];
        
        //return filePath;
        return fileName;
         
        
           }
    return nil;
}

#pragma SightingInfoViewControllerDelegate

- (IBAction)saveSightingTapped:(id)sender {
    
}

-(void)cancel{
    //[popoverController dismissPopoverAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}




-(void)saveSightingInfo:(NSInteger)observation placeName:(NSString *)placeName date:(NSDate*)date comments:(NSString *)comments{
    
    NSString * sessionName = [appDelegate _sessionName];
    NSString * sessionID   = [appDelegate _sessid];
    NSString * token       = [appDelegate _currentToken];
    NSInteger uid          = [appDelegate _uid];
    
    /*[appData CheckSession:sessionName sessionID:sessionID viewController:self completeBlock:^(id json, JSONModelError *err) {
        BOOL stillConnected = YES;
        
        
        UserConnectedResult* sessionCheckResult = nil;
        if (err)
        {
            [Tools showError:err onViewController:self];
        }
        else
        {
            NSError* error;
            NSDictionary* tmpDict = (NSDictionary*) json;
            sessionCheckResult = [[UserConnectedResult alloc] initWithDictionary:tmpDict error:&error];
            
            if (error){
                NSLog(@"Error parse : %@", error.debugDescription);
            }else{
                if(sessionCheckResult.user != nil){
                    if (sessionCheckResult.user.uid == 0){
                        stillConnected = NO;
                    }
                    
                }
            }
            
        }
     */
        //--- Only save when below are true ---//
        if(![Tools isNullOrEmptyString:sessionID] && ![Tools isNullOrEmptyString:sessionName] &&
           ![Tools isNullOrEmptyString:token] &&  uid != 0){
            
            NSInteger _uid = [appDelegate _uid];
            
            if(observation && placeName && comments && date ){
                NSUUID *uuid = [NSUUID UUID];
                NSString * _uuid        = [uuid UUIDString];
                NSInteger   _speciesNid = self.currentSpecies._species_id;
                NSString *_speciesName  = self.currentSpecies._title;
                NSInteger   _nid        = 0;
                NSInteger  _count       = observation;
                NSString *_placeName    = placeName;
                NSString *_placeLatitude = @"";
                NSString *_placeLongitude= @"";
                NSString *_photoName     = self.photoFileName;
                NSString *_title         = comments;
                double _date             = [date timeIntervalSince1970];
                double  _created         = [[NSDate date] timeIntervalSince1970];
                double  _modified        = [[NSDate date] timeIntervalSince1970];
                
                Sightings * newSightings = [Sightings new];
                newSightings._uuid          = _uuid;
                newSightings._speciesName   = _speciesName;
                newSightings._speciesNid    = _speciesNid;
                newSightings._nid           = _nid;
                newSightings._uid           = _uid;
                newSightings._speciesCount  = _count;
                newSightings._placeName     = _placeName;
                newSightings._placeLatitude = _placeLatitude;
                newSightings._placeLongitude= _placeLongitude;
                newSightings._photoFileNames= _photoName;
                newSightings._title         = _title;
                newSightings._date          = _date;
                newSightings._createdTime   = _created;
                newSightings._modifiedTime  = _modified;
                newSightings._isLocal       = (int)YES; //From iPhone = YES
                newSightings._isSynced      = (int)NO; // Not yet synced with server
                
                [newSightings save];
                //[self dismissViewControllerAnimated:YES completion:nil];
            }
            //[self.delegate dismissCameraViewController];
            
        }else{
            
            [Tools showSimpleAlertWithTitle:NSLocalizedString(@"authentication_issue", @"") andMessage:NSLocalizedString(@"session_expired", @"")];
            
        }
    //}];

    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.delegate dismissCameraViewController];
    
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"showSightingData"] ){
        SightingDataTableViewController * vc = (SightingDataTableViewController*)[segue destinationViewController];
        vc.delegate = self;
        vc.species = self.currentSpecies;
    }
}



@end
