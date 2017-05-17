//
//  LemursWatchingSites.m
//  LOM
//
//  Created by Andrianavonison Ranto Tiaray on 25/11/2015.
//  Copyright © 2015 Kerty KAMARY. All rights reserved.
//

#import "LemursWatchingSites.h"

@implementation LemursWatchingSites


+ (NSArray*) getLemursWatchingSitesLike:(NSString*) strValue {
	return [LemursWatchingSites instancesWhere:[NSString stringWithFormat:@"_title LIKE '%%%@%%'", strValue]];
}


+ (NSArray*) allSitesOrderedByTitle:(NSString*)direction{
    if([direction length] != 0){
        return [LemursWatchingSites instancesOrderedBy:[NSString stringWithFormat:@" _title %@",direction]];
    }else{
        return [LemursWatchingSites instancesOrderedBy:[NSString stringWithFormat:@" _title ASC"]];
    }
    return nil;
}

+ (NSArray*) getSitesLike:(NSString*) strValue {
    return [LemursWatchingSites instancesWhere:[NSString stringWithFormat:@"_title LIKE '%%%@%%' ", strValue]];
}



@end
