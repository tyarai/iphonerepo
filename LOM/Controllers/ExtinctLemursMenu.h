//
//  ExtinctLemursMenu.h
//  LOM
//
//  Created by Ranto Andrianavonison on 17/03/2016.
//  Copyright © 2016 Kerty KAMARY. All rights reserved.
//

#import <UIKit/UIKit.h>
@import SafariServices;
@interface ExtinctLemursMenu : UITableViewController <UITableViewDataSource,UITableViewDelegate,SFSafariViewControllerDelegate>
@property NSArray *allLinks;

@end
