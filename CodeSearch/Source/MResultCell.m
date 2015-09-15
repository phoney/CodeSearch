//
//  ResultCell.m
//  CodeSearch
//
//  Created by Brian Stern on 9/15/15.
//  Copyright © 2015 PhoneyDeveloper. All rights reserved.
//

#import "MResultCell.h"
#import "AreaCode.h"

@implementation MResultCell

-(void)setAreaCode:(AreaCode *)areaCode
{
	_areaCode = areaCode;
	
	[self configureCell];
}

-(void)configureCell
{
	NSString* areaCode = self.areaCode.areaCodeString;
	NSString* location = self.areaCode.location;
	NSString* country = self.areaCode.country;
	
	NSMutableString* text = [NSMutableString string];
	// Protect against nil areaCode or any missing fields
	if (areaCode.length > 0) {
		[text appendString:areaCode];
	}

	if (location.length > 0) {
		if (text.length > 0) {
			[text appendFormat:@", %@", location];
		} else {
			[text appendString:location];
		}
	}

	if (country.length > 0) {
		if (text.length > 0) {
			[text appendFormat:@", %@", country];
		} else {
			[text appendString:country];
		}
	}

	self.textLabel.text = text;
}

@end
