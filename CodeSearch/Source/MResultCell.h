//
//  ResultCell.h
//  CodeSearch
//
//  Created by Brian Stern on 9/15/15.
//  Copyright © 2015 PhoneyDeveloper. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kResultCellReuseIdentifier @"ResultCell"

@class AreaCode;

@interface MResultCell : UITableViewCell

@property (nonatomic, weak) AreaCode* areaCode;

@end
