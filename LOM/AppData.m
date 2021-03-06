    //
//  AppData.m
//  LOM
//
//  Created by Andrianavonison Ranto Tiaray on 02/01/2016.
//  Copyright © 2016 Kerty KAMARY. All rights reserved.
//

#import "AppData.h"
#import "Tools.h"
#import "UserConnectedResult.h"
#import "BaseViewController.h"
#import "FileResult.h"
#import "Constants.h"
#import "Species.h"
#import "AppDelegate.h"
#import "Comment.h"
#import "Sightings.h"
#import "LOMJSONHttpClient.h"

@implementation AppData

static AppData* _instance;

+(AppData*)getInstance
{
    @synchronized(self){
        if(!_instance){
            _instance = [[AppData alloc]init];
        }
    }
    return _instance;
}

-(id)init{
    self = [super init];
    if (self){
    }
    return self;
}

- (void) buildPOSTHeader:(NSString*)contentType{
    
    [[JSONHTTPClient requestHeaders] setValue:@"application/json" forKey:@"Accept"];
    [[JSONHTTPClient requestHeaders] setValue:contentType forKey:@"Content-Type"];
    
    NSString* token = [Tools getAppDelegate]._currentToken;
    
    if (![Tools isNullOrEmptyString:token]) {
        [[JSONHTTPClient requestHeaders] setValue:token forKey:@"X-CSRF-Token"];
    }
}

- (void) buildPOSTHeader{
    
    [[JSONHTTPClient requestHeaders] setValue:@"application/json" forKey:@"Accept"];
    [[JSONHTTPClient requestHeaders] setValue:@"application/x-www-form-urlencoded" forKey:@"Content-Type"];
    
    NSString* token = [Tools getAppDelegate]._currentToken;
    
    if (![Tools isNullOrEmptyString:token]) {
        [[JSONHTTPClient requestHeaders] setValue:token forKey:@"X-CSRF-Token"];
    }
}

- (void) buildPOSTHeaderWithContentType:(NSString*)contentTypeValue{
    
    [[JSONHTTPClient requestHeaders] setValue:@"application/json" forKey:@"Accept"];
    [[JSONHTTPClient requestHeaders] setValue:contentTypeValue forKey:@"Content-Type"];
    
    NSString* token = [Tools getAppDelegate]._currentToken;
    
    if (![Tools isNullOrEmptyString:token]) {
        [[JSONHTTPClient requestHeaders] setValue:token forKey:@"X-CSRF-Token"];
    }
}




- (void) buildGETHeader{
    
    [[JSONHTTPClient requestHeaders] setValue:@"application/json" forKey:@"Accept"];
    [[JSONHTTPClient requestHeaders] setValue:@"application/json" forKey:@"Content-Type"];
    
    NSString* token = [Tools getAppDelegate]._currentToken;
    
    if (![Tools isNullOrEmptyString:token]) {
        [[JSONHTTPClient requestHeaders] setValue:token forKey:@"X-CSRF-Token"];
    }
}


- (NSString*) buildBodyForLoginWithUserName:(NSString*) userName andPassword:(NSString*) password{
    return [NSString stringWithFormat:@"username=%@&password=%@",
            userName,
            password];
}



- (NSString*) buildBodyWithUserName:(NSString*) userName {
    return [NSString stringWithFormat:@"username=%@",userName];
}


#pragma mark User

-(void) loginWithUserName:(NSString*)userName andPassword:(NSString*) password forCompletion:(JSONObjectBlock)completeBlock
{
    [self buildPOSTHeader];
    
    NSString* body = [self buildBodyForLoginWithUserName:userName andPassword:password];
    
    NSString* url = [NSString stringWithFormat:@"%@%@", SERVER, LOGIN_ENDPOINT];
    
    [JSONHTTPClient postJSONFromURLWithString:url bodyString:body completion:completeBlock];
}

-(void) registerUserName:(NSString*)userName
                password:(NSString*)password
                mail    :(NSString*)mail
           forCompletion:(JSONObjectBlock)completeBlock
{
    [self buildPOSTHeader];
    
    NSString* body = [NSString stringWithFormat:@"account[name]=%@&account[mail]=%@&account[pass]=%@",userName,mail,password];
    
    NSString* url = [NSString stringWithFormat:@"%@%@", SERVER, REGISTER_ENDPOINT];
    
    [JSONHTTPClient postJSONFromURLWithString:url bodyString:body completion:completeBlock];
}



-(void) logoutUserName:(NSString*)userName forCompletion:(JSONObjectBlock)completeBlock {
    
    if(![Tools isNullOrEmptyString:userName]){
        
        [self buildPOSTHeader];
        NSString * sessionName = [[Tools getAppDelegate] _sessionName];
        NSString * sessionID = [[Tools getAppDelegate] _sessid];
        NSString * cookie = [NSString stringWithFormat:@"%@=%@",sessionName,sessionID];
        
        if( ! [Tools isNullOrEmptyString:sessionName] && ! [Tools isNullOrEmptyString:sessionID] && ! [Tools isNullOrEmptyString:cookie]){
            
            NSString* body = [self buildBodyWithUserName:userName] ;
            [[JSONHTTPClient requestHeaders] setValue:cookie forKey:@"Cookie"];
            NSString* url = [NSString stringWithFormat:@"%@%@", SERVER, LOGOUT_ENDPOINT];
            [JSONHTTPClient postJSONFromURLWithString:url bodyString:body completion:completeBlock];
        }

        
    }
}


-(void) CheckSession:(NSString*)sessionName
           sessionID:(NSString*)sessionID
      viewController:(id) viewController
       completeBlock:(JSONObjectBlock)completeBlock{

   if(viewController != nil){
        BaseViewController* viewC =(BaseViewController*)viewController;
       AppDelegate * appDelegate = [viewC getAppDelegate];
       
       if(appDelegate.showActivity ){
            [viewC showActivityScreen];
       }
    }
    
    [self buildPOSTHeader];
     NSString * cookie = [NSString stringWithFormat:@"%@=%@",sessionName,sessionID];
    
    if( ! [Tools isNullOrEmptyString:sessionName] && ! [Tools isNullOrEmptyString:sessionID] && ! [Tools isNullOrEmptyString:cookie]){
        
        [[JSONHTTPClient requestHeaders] setValue:cookie forKey:@"Cookie"];
        NSString* url = [NSString stringWithFormat:@"%@%@", SERVER, ISCONNECTED_ENDPOINT];
        [JSONHTTPClient postJSONFromURLWithString:url bodyString:nil completion:completeBlock];
    }
}


-(void) CheckSession:(NSString*)sessionName
           sessionID:(NSString*)sessionID
       completeBlock:(JSONObjectBlock)completeBlock{
   
    [self buildPOSTHeader];
    NSString * cookie = [NSString stringWithFormat:@"%@=%@",sessionName,sessionID];
    
    if( ! [Tools isNullOrEmptyString:sessionName] && ! [Tools isNullOrEmptyString:sessionID] && ! [Tools isNullOrEmptyString:cookie]){
        
        [[JSONHTTPClient requestHeaders] setValue:cookie forKey:@"Cookie"];
        NSString* url = [NSString stringWithFormat:@"%@%@", SERVER, ISCONNECTED_ENDPOINT];
        [JSONHTTPClient postJSONFromURLWithString:url bodyString:nil completion:completeBlock];
    }
}

/*
    Manisa izay Sighting an'ilay UID any @ server
 */

-(void) getSightingsCountForUID:(NSInteger)uid
                changedFromDate:(NSString*)from_date
                      sessionID:(NSString*)session_id
                  andCompletion:(JSONObjectBlock)completeBlock
{
    [self buildPOSTHeader];
    
    if (![Tools isNullOrEmptyString:session_id]) {
        
        NSString * sessionName  = [[Tools getAppDelegate] _sessionName];
        NSString * cookie       = [NSString stringWithFormat:@"%@=%@",sessionName,session_id];
        [[JSONHTTPClient requestHeaders] setValue:cookie forKey:@"Cookie"];
        
        NSString * url = nil;
        
        if([Tools isNullOrEmptyString:from_date]){
        
            //---- Raha tsy mbola misy sighting ato @ local (izany hoe vao avy no-resinstaller-na mihitsy ilay app izay vao alatsaka daholo ny sighting rehetra any @server.
            //Raha efa misy en local dia zay SYNCED = FALSE any @ server ihany no halatsaka
            
            NSArray *localSightings = [Sightings getSightingsByUID:uid];
            
            if([localSightings count] == 0){
                url = [NSString stringWithFormat:@"%@%@?uid=%lu", SERVER,COUNT_SIGHTINGS,(unsigned long)uid];
            }else{
                url = [NSString stringWithFormat:@"%@%@?uid=%lu&synced=0", SERVER,COUNT_SIGHTINGS,(unsigned long)uid];
            }
            
        }else{
            NSCharacterSet *allowedCharacters = [NSCharacterSet URLFragmentAllowedCharacterSet];
            NSString *percentEncodedString    = [from_date stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
            /*url = [NSString stringWithFormat:@"%@%@?uid=%lu&from_date=%@", SERVER,COUNT_SIGHTINGS,(unsigned long)uid,percentEncodedString];*/
            url = [NSString stringWithFormat:@"%@%@?uid=%lu&from_date=%@&synced=%d", SERVER,COUNT_SIGHTINGS,(unsigned long)uid,percentEncodedString,0];
        }
        
        [JSONHTTPClient postJSONFromURLWithString:url
                                           params:NULL
                                       completion:completeBlock];
    }
    
}


-(void) paginate:(NSString*)sessionID
           start:(NSString*)start
           count:(NSString*)count
   andCompletion:(JSONObjectBlock)completeBlock{
}


-(void) getSightingsForSessionId:(NSString*) session_id
                       from_date:(NSString*) from_date
                   andCompletion:(JSONObjectBlock)completeBlock{
    
    [self getSightingsForSessionId:session_id
                         from_date:from_date
                             start:nil
                             count:nil
                     andCompletion:completeBlock];
}



-(void) getSightingsForSessionId:(NSString*) session_id
                       from_date:(NSString*) from_date
                           start:(NSString*)start
                           count:(NSString*)count
                          
                   andCompletion:(JSONObjectBlock)completeBlock
{
    [self buildPOSTHeader];
    
    if (![Tools isNullOrEmptyString:session_id]) {
        
        NSString * sessionName  = [[Tools getAppDelegate] _sessionName];
        NSString * cookie       = [NSString stringWithFormat:@"%@=%@",sessionName,session_id];
        [[JSONHTTPClient requestHeaders] setValue:cookie forKey:@"Cookie"];
   
        
        NSString* url                     = nil;
        AppDelegate * appDelegate         = [Tools getAppDelegate];
        NSUInteger uid                    = appDelegate._uid;
        
        //NSString * lastSyncDate = [Tools getStringUserPreferenceWithKey:LAST_SYNC_DATE];
        NSString * lastSyncDate           = from_date;
        
        if([Tools isNullOrEmptyString:lastSyncDate]){
            //--- Rehefa vao mi-sync voalohany dia mila atao synced=FALSE daholo aloha ny any @ server
            
            NSString* _url = [NSString stringWithFormat:@"%@%@?uid=%lu&from_date=&start=%@&count=%@", SERVER,SERVICE_MY_SIGHTINGS,(unsigned long)uid,start,count];
            
            [JSONHTTPClient postJSONFromURLWithString:_url
                                               params:NULL
                                           completion:completeBlock];
        
        }else{
            
            NSCharacterSet *allowedCharacters = [NSCharacterSet URLFragmentAllowedCharacterSet];
            NSString *percentEncodedString    = [lastSyncDate stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
            
            
            url = [NSString stringWithFormat:@"%@%@?uid=%lu&from_date=%@&start=%@&count=%@&synced=%d", SERVER,SERVICE_MY_SIGHTINGS,(unsigned long)uid,percentEncodedString,start,count,0];
            
            
            [JSONHTTPClient postJSONFromURLWithString:url
                                               params:NULL
                                           completion:completeBlock];
            
        }
    }
}


-(void) getMyLemurLifeListForSessionId:(NSString*) session_id andCompletion:(JSONObjectBlock)completeBlock
{
    
    if (![Tools isNullOrEmptyString:session_id]) {
    
        [self buildGETHeader];
        
        NSString * sessionName = [[Tools getAppDelegate] _sessionName];
        NSString * cookie = [NSString stringWithFormat:@"%@=%@",sessionName,session_id];
        [[JSONHTTPClient requestHeaders] setValue:cookie forKey:@"Cookie"];
    
        NSString* url= nil;
        NSString * lastSyncDate = [Tools getStringUserPreferenceWithKey:LAST_SYNC_DATE];

        if([Tools isNullOrEmptyString:lastSyncDate]){
            //----- Alatsaka daholo ny LifeList rehetra raha NULL ity date ity ---///
            url = [NSString stringWithFormat:@"%@%@", SERVER, LIFELIST_ENDPOINT];
            [JSONHTTPClient getJSONFromURLWithString:url completion:completeBlock];
        }else{
            url = [NSString stringWithFormat:@"%@%@", SERVER, LIFELIST_ENDPOINT_MODIFIED_FROM];
            NSDictionary *JSONParam = @{@"changed":lastSyncDate};
            [JSONHTTPClient getJSONFromURLWithString:url params:JSONParam completion:completeBlock];
        }
        
    }
    
    
}

-(void) syncLifeListWithServer:(NSArray<LemurLifeListTable *>*)lifeLists
                   sessionName:(NSString*)sessionName
                     sessionID:(NSString*) sessionID{
    
    if([lifeLists count] > 0){
        
        [self buildPOSTHeader];
        NSString * cookie = [NSString stringWithFormat:@"%@=%@",sessionName,sessionID];
        [[JSONHTTPClient requestHeaders] setValue:cookie forKey:@"Cookie"];
        
        for(LemurLifeListTable * list in lifeLists){
            if(list._isLocal && !list._isSynced){
                NSString * _title       = list._title;
                int64_t     _species_id = list._species_id;
                NSString * _species     = list._species;
                //int64_t _uid            = list._uid; //<<-- Tsy mila alefa miakatra tsony ny _uid satria efa misy ilay session user no mitondra azy any @ server
                int64_t _isLocal        = list._isLocal;
                //int64_t _isSynced       = list._isSynced;
                //NSString* _uuid         = list._uuid;
                NSString* _where_see_it = list._where_see_it;
                int64_t _when_see_it    = list._when_see_it;
                //NSString* _photo_name   = list._photo_name;
                
                NSDate *vDate = [NSDate dateWithTimeIntervalSince1970:_when_see_it];
                NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
                [_formatter setDateFormat:@"y-M-d"];
                NSString * strDate = [_formatter stringFromDate:vDate];
                NSString *body = [NSString stringWithFormat:@"type=personal_lemur_life_list_item&language=und"];
                
                NSString * speciesName = [NSString stringWithFormat:@"%@(%lli)",_species,_species_id];
                body = [body stringByAppendingFormat:@"&title=%@",_title];
                body = [body stringByAppendingFormat:@"&field_species[und][0][target_id]=%@",speciesName];
                body = [body stringByAppendingFormat:@"&field_locality[und][0][value]=%@",_where_see_it];
                body = [body stringByAppendingFormat:@"&field_date[und][0][value][date]=%@",strDate];
                body = [body stringByAppendingFormat:@"&field_is_local[und][value]=%lld",_isLocal];
                
                NSString* url = [NSString stringWithFormat:@"%@%@", SERVER, NODE_ENDPOINT];
                [JSONHTTPClient postJSONFromURLWithString:url bodyString:body completion:^(id json, JSONModelError *error) {
                    
                    NSDictionary * retDict = (NSDictionary*)json;
                    
                    
                    if (error != nil){
                        NSLog(@"Error parse : %@", error.debugDescription);
                    }
                    else{
                        //-- Azo ny NID an'ity sighting vaovao ity ----
                        NSInteger newNID = [[retDict valueForKey:@"nid"] integerValue];
                        list._nid = newNID;
                        list._isSynced = YES;
                        list._isLocal  = NO;
                        [list save];
                    }
                }];
                
            }
        }
    }
}

-(void) unlockSighintg:(Sightings*)sighting{
    if(sighting){
        sighting._locked = NO;
        [sighting save];
    }
}


/**
 --- Sync Sighting with server
 */

-(void) syncWithServer:(NSArray<Sightings *>*)sightings
                  view:(id)vc
           sessionName:(NSString*)sessionName
             sessionID:(NSString*) sessionID
              //callback:(postsViewControllerFunctionCallback)func{
             callbacks:(NSArray<postsViewControllerFunctionCallback>*) callbacks{
    
    if(sightings != nil &&  [sightings count] > 0){
        
        [self buildPOSTHeader];
        NSString * cookie = [NSString stringWithFormat:@"%@=%@",sessionName,sessionID];
        [[JSONHTTPClient requestHeaders] setValue:cookie forKey:@"Cookie"];
        
        for (Sightings * sighting in sightings) {
            
            //--- Update Oct 24 2017 // Verouiller-na ilay row any anaty table mba hisorohana hoe process
            //  (pull to refresh) samihafa miara- mampiakatra azy
            sighting._locked = YES;
            [sighting save];
            //-------------------------------------------------------------
            
            if(sighting._deleted == NO){
            
                NSURL * url             = nil;
                NSString* fileName      = sighting._photoFileNames;
                NSData *data            = nil;
                NSUInteger fileSize     = 0;
                UIImage *img            = nil;
                NSString * _base64Image = nil;
                
                //----------- Jerena sao efa URL ilay fileName --------
                fileName = [fileName stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
                NSURL * tempURL     = [NSURL URLWithString:fileName];
                
                if(tempURL && tempURL.scheme && tempURL.host){
                    url = tempURL;
                }else{
                    NSString * fullPath = [self getImageFullPath:fileName];
                    url = [NSURL fileURLWithPath: fullPath];
                }
                
                
                //---- Create sighting on the server --//
                if(sighting._isLocal && !sighting._isSynced){
                    
                        data = [NSData dataWithContentsOfURL:url];
                        fileSize  = [data length];
                        img = [[UIImage alloc] initWithData:data];
                        _base64Image = [Tools base64:img];
                    
                   
                        [self uploadImage:_base64Image
                                 fileName:fileName
                                 fileSize:(NSUInteger)fileSize
                                 completeBlock:^(id json, JSONModelError *err) {
                       
                                     
                            if(err){
                                BaseViewController *viewController = (BaseViewController*)vc;
                                [Tools showError:err onViewController:viewController];
                                NSLog(@"Error : %@", err.description);
                                
                                [self unlockSighintg:sighting];
                                
                                
                            }else{
                                
                                NSError* error;
                                NSDictionary* tmpDict = (NSDictionary*) json;
                                FileResult* fileResult = [[FileResult alloc] initWithDictionary:tmpDict error:&error];
                                
                                if (error){
                                    BaseViewController *viewController = (BaseViewController*)vc;
                                    [Tools showError:err onViewController:viewController];
                                    NSLog(@"Error when parsing : %@", error.debugDescription);
                                }
                                else{
                                    NSInteger fid  = fileResult.fid;
                                  
                                    [self saveSighting:sighting fileID:fid sessionName:sessionName sessionId:sessionID completeBlock:^(id RETjson, JSONModelError *err) {
                                        
                                        NSDictionary * retDict = (NSDictionary*)RETjson;
                                        
                                        
                                        if (err){
                                            BaseViewController *viewController = (BaseViewController*)vc;
                                            [Tools showError:err onViewController:viewController];
                                            
                                            [self unlockSighintg:sighting];

                                        }
                                        else{
                                            //-- Azo ny NID an'ity sighting vaovao ity ----
                                            NSInteger newNID = [[retDict valueForKey:@"nid"] integerValue];
                                            
                                            if(newNID > 0){
                                                sighting._nid      = newNID;
                                                sighting._isSynced = YES;
                                                sighting._isLocal  = NO;
                                                sighting._locked   = NO; // Unlock the row
                                                [sighting save];
                                                
                                                [self syncSightingComments:sighting
                                                               sessionName:sessionName                                                          sessionId :sessionID
                                                                      view:vc];

                                            }
                                           
                                            
                                        }
                                    }];
                                }
                                
                                
                            }
                        }];
                    
                }
                
                //--- Update Sighting On Server --//
                if(!sighting._isLocal && !sighting._isSynced){
                    
                    if(sighting._hasPhotoChanged){
                        //--- Update October 31 2017 ---
                        // Raha niova ny sarin'ilay sighting ---//
                        
                        data            = [NSData dataWithContentsOfURL:url];
                        fileSize        = [data length];
                        img             = [[UIImage alloc] initWithData:data];
                        _base64Image    = [Tools base64:img];
                        
                        [self uploadImage:_base64Image
                                 fileName:fileName
                                 fileSize:(NSUInteger)fileSize
                            completeBlock:^(id json, JSONModelError *err) {
                                
                                if(err){
                                    
                                    BaseViewController *viewController = (BaseViewController*)vc;
                                    [Tools showError:err onViewController:viewController];
                                    NSLog(@"Error : %@", err.description);
                                    
                                    [self unlockSighintg:sighting];

                                }else{
                                    NSError* error;
                                    NSDictionary* tmpDict = (NSDictionary*) json;
                                    FileResult* fileResult = [[FileResult alloc] initWithDictionary:tmpDict error:&error];
                                    
                                    if (error == nil){
                                    
                                        NSInteger fid  = fileResult.fid;
                                        
                                        Species * species = [Species getSpeciesBySpeciesNID:sighting._speciesNid];
                                        
                                        [self updateSightingWithNID:sighting._nid
                                                              Title:sighting._title
                                                          placeName:sighting._placeName
                                                               date:sighting._date
                                                              count:sighting._speciesCount
                                                            species:species
                                                             fileID:fid
                                                       placeNameNID:sighting._place_name_reference_nid
                                                           latitude:sighting._placeLatitude
                                                          longitude:sighting._placeLongitude
                                                           altitude:sighting._placeAltitude
                                                        sessionName:sessionName
                                                          sessionId:sessionID
                                                      completeBlock:^(id json, JSONModelError *jsonerror) {
                                            
                                                          if (jsonerror){
                                                              
                                                              BaseViewController *viewController = (BaseViewController*)vc;
                                                              [Tools showError:jsonerror onViewController:viewController];
                                                              NSLog(@"Error : %@", jsonerror.description);
                                                              
                                                              [self unlockSighintg:sighting];

                                                          }
                                                          else{
                                                              
                                                              sighting._isSynced = YES;
                                                              sighting._locked   = NO; // Unlock the row
                                                              sighting._hasPhotoChanged = NO;
                                                              [sighting save];
                                                             
                                                              [self syncSightingComments:sighting
                                                                     sessionName:sessionName                                                              sessionId :sessionID
                                                                            view:vc];
   
                                                          }
                                        }];
                                        
                                    }
                              }
                                
                        }];
                            
                    }else{
                        
                        //---- Raha tsy niova ilay sary dia ny info fotsiny sisa no apekarina
                        Species * species = [Species getSpeciesBySpeciesNID:sighting._speciesNid];
                        [self updateSightingWithNID:sighting._nid
                                              Title:sighting._title
                                          placeName:sighting._placeName
                                               date:sighting._date
                                              count:sighting._speciesCount
                                            species:species
                                             fileID:0 // Tsy nisy sary niova
                                       placeNameNID:sighting._place_name_reference_nid
                                           latitude:sighting._placeLatitude
                                          longitude:sighting._placeLongitude
                                           altitude:sighting._placeAltitude
                                        sessionName:sessionName
                                          sessionId:sessionID
                                      completeBlock:^(id json, JSONModelError *jsonerror) {
                                          
                                          if (jsonerror){
                                              
                                              BaseViewController *viewController = (BaseViewController*)vc;
                                              [Tools showError:jsonerror onViewController:viewController];
                                              NSLog(@"Error : %@", jsonerror.description);
                                              
                                              [self unlockSighintg:sighting];
                                              
                                          }
                                          else{
                                              
                                              sighting._isSynced = YES;
                                              sighting._locked   = NO; // Unlock the row
                                              [sighting save];
                                              
                                              
                                          }
                                      }];
                        
                        
                        
                    }
                    
                }//--Updating
            
            
            }else{
            
                if(sighting._nid == 0){
                    //--- Tsy mbola synced (tsy nahazo nid) ity sighting ity dia tonga dia vonona ny local
                    [sighting delete];
                
                }else{
                
                    [self deleteSighting:sighting
                             sessionName:sessionName
                               sessionId:sessionID
                           completeBlock:^(id json, JSONModelError *err) {
                               
                               if (err){
                                   NSLog(@"Error parse : %@", err.debugDescription);
                               }
                               else{
                                   //--- Tonga dia vonona ato @ iPhone avy hatrany ity sighting ity
                                   [sighting delete];
                               }
                    }];
                }
            }
            
        }//for loop
        
        //--- Sync Comments, Onlinesighting
        /*AppDelegate * appDelegate = [Tools getAppDelegate];
        
        for(int i = 0 ; i < [callbacks count]; i++){
            
            dispatch_async(appDelegate.serialSyncQueue,^{
                
                callbacks[i]();
                
            });
        }*/
        
    }else{
        //---- Raha tsy misy ny sightings ho alefa miakatra dia tonga dia asaina mi-load ny online avy hatrany --/
        /*if(func != nil){
            func();
        }*/
        
        AppDelegate * appDelegate = [Tools getAppDelegate];
        
        for(int i = 0 ; i < [callbacks count]; i++){
        
             dispatch_async(appDelegate.serialSyncQueue,^{
             
                 callbacks[i]();
                 
             });
        }
    }
    
    /*AppDelegate * appDelegate = [Tools getAppDelegate];
    
    dispatch_async(appDelegate.serialSyncQueue,^{
        
        if(appDelegate.isSyncing){
            appDelegate.isSyncing = NO;
        }
    });*/
}

/*
    Apekarina ny comment rehetra an'ity 'sighting' ity
 */
-(void) syncSightingComments:(Sightings*)sighting
                 sessionName:(NSString*)sessionName
                  sessionId :(NSString*)sessionId
                        view:(id)viewController{

    if(sighting && ![Tools isNullOrEmptyString:sessionName] && ! [Tools isNullOrEmptyString:sessionId]){
    
        NSArray * sightingComments = [Comment getNotSyncedCommentsBySightingUUID:sighting._uuid];
        
        if(sightingComments != nil && [sightingComments count] != 0){
            
            for (Comment * comment in sightingComments) {
                
                if(sighting._nid > 0 && comment._nid == 0){
                    comment._nid = sighting._nid;
                    [comment save]; // Raha vao avy no-creer-na ilay sighting dia tonga dia efa avy nahazo nid avy tany @ server ilay sighting dia tonga dia associer-na eto ilay comment sy sighting (
                }
                
                [self syncComment:comment
                             view:viewController
                      sessionName:sessionName
                        sessionID:sessionId];
             }
            
        }
        
    }
}




/*
    Sync comment anakiray mankany @ server
 */
-(void) syncComment :(Comment*)comment
                view:(id)vc
         sessionName:(NSString*)sessionName
           sessionID:(NSString*) sessionID{
    
    if(comment && ! [Tools isNullOrEmptyString:sessionName] && ! [Tools isNullOrEmptyString:sessionID]){
        
        [self buildPOSTHeader];
        NSString * cookie = [NSString stringWithFormat:@"%@=%@",sessionName,sessionID];
        [[JSONHTTPClient requestHeaders] setValue:cookie forKey:@"Cookie"];
        
        //if(comment._cid == 0 && comment._local){
        if(comment._local){
            //-- Creer-na any @ server ity comment ity ---//
            
            [self createComment:comment
                  sessionName:sessionName
                    sessionId:sessionID completeBlock:^(id json, JSONModelError *err) {
               
                    if(err == nil && json != nil){
                        
                        NSDictionary * retDict = (NSDictionary*)json;
                        NSInteger newCID       = [[retDict valueForKey:@"cid"] integerValue];
                        
                        if(newCID > 0){
                            comment._locked = (int)NO;
                            comment._synced = (int)YES;
                            comment._local  = (int)NO;
                            comment._cid    = newCID;
                            [comment save];
                        }else{
                            BaseViewController *viewController = (BaseViewController*)vc;
                            [Tools showError:err onViewController:viewController];
                            NSLog(@"Comment syncing error: %@",err.description);
                            
                            comment._locked = (int)NO;
                            [comment save];
                        }
                        
                    }
            }];
            
        }else{
            
            //--- Atao update any @ server ilay comment ---//
            
            [self updateComment:comment
                    sessionName:sessionName
                      sessionId:sessionID completeBlock:^(id json, JSONModelError *err) {
                          
                  if(err == nil ){
                      
                      comment._locked = (int)NO;
                      comment._synced = (int)YES;
                      comment._local  = (int)NO;
                      [comment save];

                      
                  }else{
                      
                      BaseViewController *viewController = (BaseViewController*)vc;
                      [Tools showError:err onViewController:viewController];
                      NSLog(@"Comment syncing error: %@",err.description);
                      
                      comment._locked = (int)NO;
                      [comment save];
                      
                  }
            }];
            
        }
        
        
    }
}

/*
    Sync down - Get comments from server
 
    --> Alaina daholo izay comment niova na vaovao any @ serveur ka mifandray @ sighting an'ity UID ity
*/
-(void) getCommentsWithSessionName:(NSString*) sessionName
                         sessionID:(NSString*) sessionId
                           userUID:(NSInteger)uid
                     completeBlock:(JSONObjectBlock) completeBlock{

    if(uid != 0 && ! [Tools isNullOrEmptyString:sessionName] && ! [Tools isNullOrEmptyString:sessionId]){
        
        
        [self buildPOSTHeader];
        NSString * cookie = [NSString stringWithFormat:@"%@=%@",sessionName,sessionId];
        [[JSONHTTPClient requestHeaders] setValue:cookie forKey:@"Cookie"];
        
        NSString *body           = [NSString stringWithFormat:@""];
        
        NSString * lastSyncDate  = nil;
        //NSInteger synced         = 0;
        
        //lastSyncDate           = [Tools getStringUserPreferenceWithKey:LAST_SYNC_DATE];
        lastSyncDate             = [Tools getStringUserPreferenceWithKey:LAST_SERVER_SYNC_DATE];
        
        body = [body stringByAppendingFormat:@"uid=%li",(long)uid];
        //body = [body stringByAppendingFormat:@"&synced=%i",(int)synced];
        body = [body stringByAppendingFormat:@"&fromDate=%@",lastSyncDate];
        
        NSString* url = [NSString stringWithFormat:@"%@%@", SERVER, CHANGED_COMMENTS];
        [JSONHTTPClient postJSONFromURLWithString:url bodyString:body completion:completeBlock];
        
    }
}


/*
 Sync - Create Comment on server
 */
-(void)  createComment:(Comment*)comment
         sessionName:(NSString*)sessionName
          sessionId :(NSString*)sessionId
       completeBlock:(JSONObjectBlock) completeBlock{
    
    if(comment && ![Tools isNullOrEmptyString: sessionName] &&  ! [Tools isNullOrEmptyString: sessionId]){
        
        [self buildPOSTHeader];
        NSString * cookie = [NSString stringWithFormat:@"%@=%@",sessionName,sessionId];
        [[JSONHTTPClient requestHeaders] setValue:cookie forKey:@"Cookie"];
        
        NSString * uuid                     = comment._uuid;
        NSString * sighting_uuid            = comment._sighting_uuid;
        NSInteger uid                       = comment._uid;
        int status                          = comment._status;
        NSString* commentbody               = comment._commentBody;
        NSInteger nid                       = comment._nid;
        NSString *body                      = [NSString stringWithFormat:@""];
        NSString*subject                    = @"";
        
        
        body = [body stringByAppendingFormat:@"body=%@",commentbody];
        body = [body stringByAppendingFormat:@"&uuid=%@",uuid];
        body = [body stringByAppendingFormat:@"&uid=%li",uid];
        body = [body stringByAppendingFormat:@"&sighting_uuid=%@",sighting_uuid];
        body = [body stringByAppendingFormat:@"&nid=%li",nid];
        body = [body stringByAppendingFormat:@"&status=%i",status];
        body = [body stringByAppendingFormat:@"&subject=%@",subject];
        body = [body stringByAppendingFormat:@"&synced=%i",1];
        
        
        
        NSString* url = [NSString stringWithFormat:@"%@%@", SERVER, NEW_COMMENT];
        [JSONHTTPClient postJSONFromURLWithString:url bodyString:body completion:completeBlock];
        
    }
    
}


/*
 Sync - Update Comment on server
 */
-(void)  updateComment:(Comment*)comment
           sessionName:(NSString*)sessionName
            sessionId :(NSString*)sessionId
         completeBlock:(JSONObjectBlock) completeBlock{
    
    if(comment && ![Tools isNullOrEmptyString: sessionName] &&  ! [Tools isNullOrEmptyString: sessionId]){
        
        [self buildPOSTHeader];
        NSString * cookie = [NSString stringWithFormat:@"%@=%@",sessionName,sessionId];
        [[JSONHTTPClient requestHeaders] setValue:cookie forKey:@"Cookie"];
        
        int status                          = comment._status;
        int deleted                         = comment._deleted;
        NSString* commentbody               = comment._commentBody;
        NSString *body                      = [NSString stringWithFormat:@""];
        NSString* uuid                      = comment._uuid;
        
       
        body = [body stringByAppendingFormat:@"body=%@",commentbody];
        body = [body stringByAppendingFormat:@"&uuid=%@",uuid];
        body = [body stringByAppendingFormat:@"&status=%i",status];
        body = [body stringByAppendingFormat:@"&deleted=%i",deleted];
        
        
        NSString* url = [NSString stringWithFormat:@"%@%@", SERVER, EDIT_COMMENT];
        [JSONHTTPClient postJSONFromURLWithString:url bodyString:body completion:completeBlock];
        
    }
    
}




-(NSString*) getImageFullPath:(NSString*)file{
    if(file){
        NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDir  = [documentPaths objectAtIndex:0];
        
        NSString *outputPath    = [documentsDir stringByAppendingPathComponent:file];
        
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        
        if ([fileManager fileExistsAtPath:outputPath])
        {
            
            return outputPath;
        }
    }
    return nil;
}



-(NSInteger) uploadImage:(NSString*)imagebase64
                fileName:(NSString*) fileName
                fileSize:(NSUInteger)fileSize
                completeBlock:(JSONObjectBlock) completeBlock{
    
    if(imagebase64){
  
        
        //fileName = [fileName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        
        //-- Jerena sao efa URL ilay fileName ---
        NSURL * tempURL = [NSURL URLWithString:fileName];
        
        if(tempURL && tempURL.scheme && tempURL.host){
            // --- http://192.168.2.242/sites/default/files/178_49_2017-05-11_12_38_25.jpeg ---//
            // ---- Toy izao zany ilay fileName miditra eto. Efa synced any @ server izy ity izany
            // fa averina miakatra indray fa nisy niova. Esorina izany ilay  http://192.168.2.242/sites/default/files/ eto ilay fileName farany sisa no ajanona eto.
            
            NSString *serverImagePath = [SERVER stringByAppendingString:SERVER_IMAGE_PATH];
            
             fileName = [fileName stringByReplacingOccurrencesOfString:serverImagePath withString:@""];
            
            
        }
        
        
        NSString * body = [NSString stringWithFormat:@"file[file]=%@&file[filename]=%@&file[filepath]=%@%@&file[filesize]=%li",imagebase64,fileName,PUBLIC_FOLDER,fileName,(unsigned long)fileSize];
        
        
        NSString *charactersToEscape = @"._-!*'();:@+$,/?%#[]" "";
        NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
        NSString *encodedBody = [body stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
                                 
 
        NSString* url = [NSString stringWithFormat:@"%@%@", SERVER, FILE_ENDPOINT];
        [JSONHTTPClient postJSONFromURLWithString:url bodyString:encodedBody completion:completeBlock];
        
    }
    return 0;
}

#pragma SYNC SERVER
/*
 * May 10, 2017
 * Delete Sighting : Mamafa ny sighting any @ server
 */

-(void) deleteSighting:(Sightings*)sighting
           sessionName:(NSString*)sessionName
            sessionId :(NSString*)sessionId
         completeBlock:(JSONObjectBlock) completeBlock{
    
    if(sighting != nil && sighting._nid != 0 && sessionId != nil & sessionName != nil){
        
        //--- Izay sighting manana 'nid' ihany no ho fafana any @ server ---//
        
        [self buildPOSTHeader];
        NSString * cookie = [NSString stringWithFormat:@"%@=%@",sessionName,sessionId];
        [[JSONHTTPClient requestHeaders] setValue:cookie forKey:@"Cookie"];
        
        NSString* url = [NSString stringWithFormat:@"%@%@%li", SERVER, NODE_UPDATE_ENDPOINT,(long)sighting._nid];
        [LOMJSONHttpClient deleteJSONFromURLWithString:url
                                            completion:completeBlock];
            
    }
    /*if(sighting != nil && sighting._nid == 0 && sighting._deleted == YES){
        //--- Tsy mbola synced (tsy nahazo nid) ity sighting ity dia tonga dia vonona ny local
        [sighting delete];
    }*/
    
}


/*
    Sync - Create Sighting on server
 */


-(void) saveSighting:(Sightings*)sighting
              fileID:(NSInteger)fid
         sessionName:(NSString*)sessionName
          sessionId :(NSString*)sessionId

       completeBlock:(JSONObjectBlock) completeBlock{

    if(sighting && sessionName && sessionId && fid != 0){
        
        [self buildPOSTHeader];
        NSString * cookie = [NSString stringWithFormat:@"%@=%@",sessionName,sessionId];
        [[JSONHTTPClient requestHeaders] setValue:cookie forKey:@"Cookie"];
        
        NSString * uuid                     = sighting._uuid;
        NSString * sightingTitle            = sighting._title;
        NSCharacterSet *allowedCharacters = [NSCharacterSet URLFragmentAllowedCharacterSet];
        NSString * encodedTitle             = [sightingTitle stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
        NSInteger speciesNID                = sighting._speciesNid;
        NSString * placeName                = sighting._placeName;
        float latitude                      = sighting._placeLatitude;
        float longitude                     = sighting._placeLongitude;
        float altitude                      = sighting._placeAltitude;
        NSInteger  count                    = sighting._speciesCount;
        NSInteger  isLocal                  = NO;//sighting._isLocal;
        NSInteger  isSynced                 = (int)YES;
        NSInteger  place_name_reference_nid = sighting._place_name_reference_nid;
        double dateTimeStamp                = sighting._date;
        NSTimeInterval _interval            = dateTimeStamp;
        NSDate *vDate                       = [NSDate dateWithTimeIntervalSince1970:_interval];
        NSDateFormatter *_formatter         =[[NSDateFormatter alloc]init];
        [_formatter setDateFormat:@"yyyy-MM-dd"];
        NSString * strDate                  = [_formatter stringFromDate:vDate];
        
        //NSString *body                      = [NSString stringWithFormat:@"type=publication&language=und"];
        NSString *body                      = [NSString stringWithFormat:@""];
        AppDelegate * appDelegate           = [Tools getAppDelegate];
        long uid                            = (long)appDelegate._uid;
        
        body = [body stringByAppendingFormat:@"title=%@",encodedTitle];
        body = [body stringByAppendingFormat:@"&uuid=%@",uuid];
        body = [body stringByAppendingFormat:@"&uid=%li",uid];
        body = [body stringByAppendingFormat:@"&status=%i",1];
        body = [body stringByAppendingFormat:@"&field_uuid=%@",uuid];
        body = [body stringByAppendingFormat:@"&body=%@",sightingTitle];
        body = [body stringByAppendingFormat:@"&field_place_name=%@",placeName];
        body = [body stringByAppendingFormat:@"&field_date=%@",strDate];
        body = [body stringByAppendingFormat:@"&field_associated_species=%li",(long)speciesNID];
        body = [body stringByAppendingFormat:@"&field_lat=%5.8f",latitude];
        body = [body stringByAppendingFormat:@"&field_long=%5.8f",longitude];
        body = [body stringByAppendingFormat:@"&field_altitude=%4.0f",altitude];
        
        body = [body stringByAppendingFormat:@"&field_is_local=%lu",(long)isLocal];
        body = [body stringByAppendingFormat:@"&field_is_synced=%lu",(long)isSynced];
        body = [body stringByAppendingFormat:@"&field_count=%lu",(long)count];
        body = [body stringByAppendingFormat:@"&field_photo=%lu",(long)fid];
        body = [body stringByAppendingFormat:@"&field_place_name_reference=%lu",(long)place_name_reference_nid];
        
        
        NSString* url = [NSString stringWithFormat:@"%@%@", SERVER, NEW_SIGHTING];
        [JSONHTTPClient postJSONFromURLWithString:url bodyString:body completion:completeBlock];
        
    }
    
}


/*

-(void) saveSighting:(Sightings*)sighting
              fileID:(NSInteger)fid
         sessionName:(NSString*)sessionName
          sessionId :(NSString*)sessionId

       completeBlock:(JSONObjectBlock) completeBlock{
    
    if(sighting && sessionName && sessionId && fid != 0){
        
        [self buildPOSTHeader];
        NSString * cookie = [NSString stringWithFormat:@"%@=%@",sessionName,sessionId];
        [[JSONHTTPClient requestHeaders] setValue:cookie forKey:@"Cookie"];

        NSString * uuid                     = sighting._uuid;
        NSString * sightingTitle            = sighting._title;
        NSInteger speciesNID                = sighting._speciesNid;
        NSString * placeName                = sighting._placeName;
        float latitude                      = sighting._placeLatitude;
        float longitude                     = sighting._placeLongitude;
        float altitude                      = sighting._placeAltitude;
        NSInteger  count                    = sighting._speciesCount;
        NSInteger  isLocal                  = NO;//sighting._isLocal;
        NSInteger  isSynced                 = (int)YES;
        NSInteger  place_name_reference_nid = sighting._place_name_reference_nid;
        double dateTimeStamp                = sighting._date;
        NSTimeInterval _interval            = dateTimeStamp;
        NSDate *vDate                       = [NSDate dateWithTimeIntervalSince1970:_interval];
        NSDateFormatter *_formatter         =[[NSDateFormatter alloc]init];
        [_formatter setDateFormat:@"M/d/y"];
        NSString * strDate                  = [_formatter stringFromDate:vDate];

        NSString *body                      = [NSString stringWithFormat:@"type=publication&language=und"];
        
        body = [body stringByAppendingFormat:@"&title=%@",sightingTitle];
        body = [body stringByAppendingFormat:@"&uuid=%@",uuid];
        body = [body stringByAppendingFormat:@"&field_uuid[und][0][value]=%@",uuid];
        body = [body stringByAppendingFormat:@"&body[und][0][value]=%@",sightingTitle];
        body = [body stringByAppendingFormat:@"&field_place_name[und][0][value]=%@",placeName];
        body = [body stringByAppendingFormat:@"&field_date[und][0][value][date]=%@",strDate];
        body = [body stringByAppendingFormat:@"&field_associated_species[und][nid]=%li",(long)speciesNID];
        body = [body stringByAppendingFormat:@"&field_lat[und][0][value]=%5.8f",latitude];
        body = [body stringByAppendingFormat:@"&field_long[und][0][value]=%5.8f",longitude];
         body = [body stringByAppendingFormat:@"&field_altitude[und][0][value]=%4.0f",altitude];
        
        body = [body stringByAppendingFormat:@"&field_is_local[und][value]=%lu",(long)isLocal];
        body = [body stringByAppendingFormat:@"&field_is_synced[und][value]=%lu",(long)isSynced];
        body = [body stringByAppendingFormat:@"&field_count[und][0][value]=%lu",(long)count];
        body = [body stringByAppendingFormat:@"&field_photo[und][0][fid]=%lu",(long)fid];
        body = [body stringByAppendingFormat:@"&field_place_name_reference[und][nid]=%lu",(long)place_name_reference_nid];
        
        NSString* url = [NSString stringWithFormat:@"%@%@", SERVER, NODE_ENDPOINT];
        [JSONHTTPClient postJSONFromURLWithString:url bodyString:body completion:completeBlock];
        
        
    }
}
*/

/*
 Sync-Update Sighting to server miaraka amin'ny fid (izany hoe nisy sary niova izany tafiakatra any @ server)
 */
-(void)   updateSightingWithNID:(NSInteger)nid
                          Title:(NSString*)title
                      placeName:(NSString*) placeName
                           date:(NSInteger)date
                          count:(NSInteger)count
                        species:(Species*) species
                         fileID:(NSInteger)fid
                   placeNameNID:(NSInteger)placeNID
                       latitude:(float)latitude
                      longitude:(float)longitude
                       altitude:(float)altitude
                    sessionName:(NSString*)sessionName
                     sessionId :(NSString*)sessionId
                  completeBlock:(JSONObjectBlock) completeBlock{
    
    if(![Tools isNullOrEmptyString:sessionName] && ![Tools isNullOrEmptyString:sessionId] && nid > 0 &&
       ![Tools isNullOrEmptyString:title] && ![Tools isNullOrEmptyString:placeName] && date != 0 && count > 0 && species != nil ){  //&& fid >0 ){
        
        [self buildPOSTHeader];
       
        NSString * cookie = [NSString stringWithFormat:@"%@=%@",sessionName,sessionId];
        [[JSONHTTPClient requestHeaders] setValue:cookie forKey:@"Cookie"];
        
       
        NSTimeInterval _interval= date;
        NSDate *vDate = [NSDate dateWithTimeIntervalSince1970:_interval];
        NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
        [_formatter setDateFormat:@"M/d/y"];
        NSString * strDate = [_formatter stringFromDate:vDate];
        
        NSString *body = [NSString stringWithFormat:@""];
        
        
        NSCharacterSet *allowedCharacters   = [NSCharacterSet URLFragmentAllowedCharacterSet];
        NSString * encodedTitle             = [title  stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
        
        body = [body stringByAppendingFormat:@"title=%@",encodedTitle];
        body = [body stringByAppendingFormat:@"&body[und][0][value]=%@",encodedTitle];
        body = [body stringByAppendingFormat:@"&field_place_name[und][0][value]=%@",placeName];
        body = [body stringByAppendingFormat:@"&field_date[und][0][value][date]=%@",strDate];
        body = [body stringByAppendingFormat:@"&field_lat[und][0][value]=%5.8f",latitude];
        body = [body stringByAppendingFormat:@"&field_long[und][0][value]=%5.8f",longitude];
        body = [body stringByAppendingFormat:@"&field_altitude[und][0][value]=%4.0f",altitude];
        body = [body stringByAppendingFormat:@"&field_count[und][0][value]=%lu",count];
        body = [body stringByAppendingFormat:@"&field_is_synced[und][0][value]=%i",1];//Update Nov 21 2017
        body = [body stringByAppendingFormat:@"&field_associated_species[und][nid]=%li",(long)species._species_id];
        body = [body stringByAppendingFormat:@"&field_place_name_reference[und][nid]=%li",(long)placeNID];
        
        if(fid != 0){
            body = [body stringByAppendingFormat:@"&field_photo[und][0][fid]=%lu",fid];
        }
        
        NSString* url = [NSString stringWithFormat:@"%@%@%li", SERVER, NODE_UPDATE_ENDPOINT,(long)nid];
        [LOMJSONHttpClient putJSONFromURLWithString:url
                                         bodyString:body
                                         completion:completeBlock];
        
    }
}

#pragma mark - Settings

-(void) getUserSettingsWithUserUID:(NSInteger) user_uid
                     completeBlock:(JSONObjectBlock) completeBlock
{
    [self buildPOSTHeaderWithContentType:@"application/json"];
    
    NSString * sessionName = [[Tools getAppDelegate] _sessionName];
    NSString * session_id  = [[Tools getAppDelegate] _sessid];
    
    NSString * cookie = [NSString stringWithFormat:@"%@=%@",sessionName,session_id];
    [[JSONHTTPClient requestHeaders] setValue:cookie forKey:@"Cookie"];
    
    NSString* url = [NSString stringWithFormat:@"%@%@?user_uid=%li", SERVER, SETTINGS_EXPORT_ENDPOINT,(long)user_uid];
    [JSONHTTPClient postJSONFromURLWithString:url bodyString:nil completion:completeBlock];
   
}

-(void) setUserSettingsWithUserUID:(NSInteger) user_uid
                      settingsName:(NSString*) settings_name
                     settingsValue:(NSString*) settings_value
                     completeBlock:(JSONObjectBlock) completeBlock
{
    [self buildPOSTHeaderWithContentType:@"application/json"];
    
    NSString * sessionName = [[Tools getAppDelegate] _sessionName];
    NSString * session_id  = [[Tools getAppDelegate] _sessid];
    
    NSString * cookie = [NSString stringWithFormat:@"%@=%@",sessionName,session_id];
    [[JSONHTTPClient requestHeaders] setValue:cookie forKey:@"Cookie"];
    
    
    NSString* url = [NSString stringWithFormat:@"%@%@?user_uid=%li&settings_name=%@&settings_value=%@", SERVER, SETTINGS_IMPORT_ENDPOINT,(long)user_uid,settings_name,settings_value];
    [JSONHTTPClient postJSONFromURLWithString:url bodyString:nil completion:completeBlock];
    
}

/*
 Maka ny changed nodes rehetra (Species,Families,Photo, Map,Places)
 - Alaina izay changed na created manomboka @ izay "lastSyncDate" ampiakarin'ity iPhone ity
 */

-(void) getChangedNodesForSessionId:(NSString*)session_id
                           fromDate:(NSString*)fromDate
                      andCompletion:(JSONObjectBlock)completeBlock
{
    //[self buildPOSTHeader];
    [self buildPOSTHeaderWithContentType:@"application/json"];
    
    if (![Tools isNullOrEmptyString:session_id]) {
        
        NSString * sessionName = [[Tools getAppDelegate] _sessionName];
        NSString * cookie = [NSString stringWithFormat:@"%@=%@",sessionName,session_id];
        [[JSONHTTPClient requestHeaders] setValue:cookie forKey:@"Cookie"];
        
        NSString * url          = nil;
        
        NSString * lastSyncDate = fromDate;
        
        /*if([Tools isNullOrEmptyString:lastSyncDate]){
            //lastSyncDate = @"2017-01-01"; // Alaina izay changed/created (defau;t value)
            lastSyncDate   = [NSString stringWithFormat:@"%d",1400000000]; //Date tany aloha be tany fotsiny
        }*/
       
        
        NSCharacterSet *allowedCharacters = [NSCharacterSet URLFragmentAllowedCharacterSet];
        NSString *percentEncodedString = [lastSyncDate stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
        
        url = [NSString stringWithFormat:@"%@%@?from_date=%@", SERVER,CHANGED_NODES,percentEncodedString];
            
        
       [JSONHTTPClient postJSONFromURLWithString:url
                                               params:NULL
                                           completion:completeBlock];
    
    }
}
/*
    Rehefa mahazo izay nodes recently changed rehetra tany @ server dia mahazo io 'jsonFromServer'
    izay ahafahana manao update ny local database.
 */

-(void) updateLocalDatabaseWith:(NSDictionary*)changedNodesJSONDictionary{
    
    if(changedNodesJSONDictionary != nil){
    
        NSArray * speciesDictionary = [changedNodesJSONDictionary valueForKey:@"species"];
        NSArray * mapsDictionary    = [changedNodesJSONDictionary valueForKey:@"maps"];
        NSArray * photoDictionary   = [changedNodesJSONDictionary valueForKey:@"photographs"];
        NSArray * placesDictionary  = [changedNodesJSONDictionary valueForKey:@"best_places"];
        NSArray * familyDictionary  = [changedNodesJSONDictionary valueForKey:@"families"];
        NSArray * authors           = [changedNodesJSONDictionary valueForKey:@"authors"];
        
        if(speciesDictionary != nil){
            [Tools updateLocalSpeciesWith:speciesDictionary];
        }
        if(photoDictionary != nil){
            [Tools updateLocalPhotographsWith:photoDictionary];
        }
        if(familyDictionary != nil){
            [Tools updateLocalLemurFamilies:familyDictionary];
        }
        if(mapsDictionary != nil){
            [Tools updateLocalMaps:mapsDictionary];
        }
        if(placesDictionary != nil){
            [Tools updateLocalSites:placesDictionary];
        }

        
    }
}


@end
