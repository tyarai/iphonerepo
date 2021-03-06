//
//  UITableViewCell+Stretch.m
//  LOM
//
//  Created by Ranto Andrianavonison on 20/10/2016.
//  Copyright © 2016 Kerty KAMARY. All rights reserved.
//

#import "UITableViewCell+Stretch.h"
#import "Constants.h"

@implementation UITableViewCell (Stretch)

-(UITableViewCell*) stretchCell:(UITableViewCell*) cell
                          width:(NSUInteger) width
                         height:(NSUInteger) height
{
    if(cell){
        cell.contentView.backgroundColor = [UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1.0];
        UIView  *whiteRoundedView = [[UIView alloc]initWithFrame:CGRectMake(0, TABLEVIEW_CELL_OFFSET, width, height - TABLEVIEW_CELL_OFFSET)];
        CGFloat colors[]={1.0,1.0,1.0,1.0};//cell color white
        whiteRoundedView.layer.backgroundColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), colors);
        whiteRoundedView.layer.masksToBounds = false;
        whiteRoundedView.layer.cornerRadius = TABLEVIEW_CELL_CORNER_RADIUS;
        //whiteRoundedView.layer.shadowOffset = CGSizeMake(-1, 1);
        //whiteRoundedView.layer.shadowOpacity = 0;
        [cell.contentView addSubview:whiteRoundedView];
        [cell.contentView sendSubviewToBack:whiteRoundedView];
        return cell;
    }
    return nil;
}

@end
