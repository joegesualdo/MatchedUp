//
//  Constants.h
//  MatchedUp
//
//  Created by Joe Gesualdo on 9/18/14.
//  Copyright (c) 2014 joegesualdo. All rights reserved.
//

// Why would we use global constants instead of define?
// global constants let you declare type of constant, cna when using defines
// defines are more useful when doing macros
// global constants are good when we have a variable that represent something that will always be the same
#import <Foundation/Foundation.h>

@interface Constants : NSObject

#pragma mark - User Class
// as soon as our program starts, for the entrie life span of the program, we will keep a pointer in memory whos variable name is kUserProfileKey.
// BUT we CAN change the value of the constant;
extern NSString *const kUserProfileKey;
extern NSString *const kUserProfileNameKey;
extern NSString *const kUserProfileFirstNameKey;
extern NSString *const kUserProfileLocationKey;
extern NSString *const kUserProfileGenderKey;
extern NSString *const kUserProfileBirthdayKey;
extern NSString *const kUserProfileInterestedInKey;
extern NSString *const kUserProfilePictureURL;
extern NSString *const kUserProfileRelationshipStatusKey;
extern NSString *const kUserProfileAgeKey;

#pragma mark - Photo Class

extern NSString *const kPhotoClassKey;
extern NSString *const kPhotoUserKey;
extern NSString *const kPhotoPictureKey;

@end
