//
//  Constants.m
//  MatchedUp
//
//  Created by Joe Gesualdo on 9/18/14.
//  Copyright (c) 2014 joegesualdo. All rights reserved.
//

#import "Constants.h"

@implementation Constants

// Now we give the key we created int he header a value
NSString *const kUserTagLineKey = @"tagLine";

NSString *const kUserProfileKey             = @"profile";
NSString *const kUserProfileNameKey         = @"name";
NSString *const kUserProfileFirstNameKey    = @"firstName";
NSString *const kUserProfileLocationKey     = @"location";
NSString *const kUserProfileGenderKey       = @"gender";
NSString *const kUserProfileBirthdayKey     = @"birthday";
NSString *const kUserProfileInterestedInKey = @"interestedIn";
NSString *const kUserProfilePictureURL      = @"pictureURL";
NSString *const kUserProfileAgeKey          = @"age";
NSString *const kUserProfileRelationshipStatusKey = @"relationshipStatus";

NSString *const kPhotoClassKey   = @"Photo";
NSString *const kPhotoUserKey    = @"user";
NSString *const kPhotoPictureKey = @"image";

#pragma mark - Activity Class

NSString *const kActivityClassKey       = @"Activity";
NSString *const kActivityTypeKey        = @"type";
NSString *const kActivityFromUserKey    = @"fromUser";
NSString *const kActivityToUserKey      = @"toUser";
NSString *const kActivityPhotoKey       = @"photo";
NSString *const kActivityTypeLikeKey    = @"like";
NSString *const kActivityTypeDislikeKey = @"dislike";

@end
