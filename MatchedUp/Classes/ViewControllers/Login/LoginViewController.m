//
//  LoginViewController.m
//  MatchedUp
//
//  Created by Joe Gesualdo on 9/18/14.
//  Copyright (c) 2014 joegesualdo. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)loginWithFacebook:(UIButton *)sender;
@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.activityIndicator.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)loginWithFacebook:(UIButton *)sender {
    // Grab information from user that logs in
    // We are setting up an array that lists everything we want from a users facebook. Full list can be found here: https://developers.facebook.com/docs/facebook-login/permissions/v2.1
    // This is where you add, remove permissions
    NSArray *permissionsArray = @[@"user_about_me", @"user_interests", @"user_relationships", @"user_birthday", @"user_location", @"user_relationship_details"];
    
    // shows and starts activity indicator
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    
    // This will return a PFUser
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        
        // This will hiden and stop animating the activity indicator when block returns with a response
        self.activityIndicator.hidden = YES;
        [self.activityIndicator stopAnimating];
        
        if (!user) {
            if (!error) {
                // This is how we tell if a user pressed cancel : if !user and !error
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Log In Error" message:@"The Facebook Login was Cancelled" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alertView show];
            } else {
                // this will be called if we didn't get a user back and there was and error
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Log In Error" message:[error description] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alertView show];
                
            }
        } else {
            [self updateUserInformation];
            [self performSegueWithIdentifier:@"loginToTabBarSegue" sender:self];
        }
    }];
}

#pragma mark - Helper Methods

// This will update the users information with the info from facebook
-(void)updateUserInformation
{
    // set the request you want to send to facebook
    // requestForMe - Creates a request representing a Graph API call to the "me" endpoint, using the active session.
    FBRequest *request = [FBRequest requestForMe];
    // make that request you defined above
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            NSDictionary *userDictionary = (NSDictionary *)result;
            NSMutableDictionary *userProfile = [[NSMutableDictionary alloc]initWithCapacity:8];
            if (userDictionary[@"name"]) {
                userProfile[kUserProfileNameKey]= userDictionary[@"name"];
            }
            if (userDictionary[@"first_name"]) {
                userProfile[kUserProfileFirstNameKey]= userDictionary[@"first_name"];
            }
            if (userDictionary[@"location"][@"name"]) {
                userProfile[kUserProfileLocationKey] = userDictionary[@"location"][@"name"];
            }
            if (userDictionary[@"gender"]) {
                userProfile[kUserProfileGenderKey] = userDictionary[@"gender"];
            }
            if (userDictionary[@"birthday"]) {
                userProfile[kUserProfileBirthdayKey] = userDictionary[@"birthday"];
            }
            if (userDictionary[@"interested_in"]) {
                userProfile[kUserProfileInterestedInKey] = userDictionary[@"interested_in"];
            }
            
            [[PFUser currentUser] setObject:userProfile forKey:kUserProfileKey];
            [[PFUser currentUser] saveInBackground];
        } else {
            NSLog(@"Error in FB: %@", error);
        }
    }];
}
@end
