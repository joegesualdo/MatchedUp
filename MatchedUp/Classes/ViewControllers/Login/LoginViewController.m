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

// What is NSMutableData?
// Provides an object oriented wrapper for byte buffers
// can query for information and as we get those queries we can add and build our nsmutabledata object, it's not going to come all at one
@property(strong,nonatomic)NSMutableData *imageData;

- (IBAction)loginWithFacebook:(UIButton *)sender;
@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.activityIndicator.hidden = YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self updateUserInformation];
        [self performSegueWithIdentifier:@"loginToHomeSegue" sender:self];
        
    }
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
            [self performSegueWithIdentifier:@"loginToHomeSegue" sender:self];
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
            
            // creates URL
            NSString *facebookID = userDictionary[@"id"];
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resouces=1", facebookID]];
            
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
                // Now we want to get the age based off the birthday
                // convert the string that we get in brithday to a nicely formated date
                NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                [formatter setDateStyle:NSDateFormatterShortStyle];
                NSDate *date = [formatter dateFromString:userDictionary[@"birthday"]];
                NSDate *now = [NSDate date];
                NSTimeInterval seconds = [now timeIntervalSinceDate:date];
                int age = seconds/31536000;
                //convert age into NSNumber
                userProfile[kUserProfileAgeKey] = @(age);
            }
            if (userDictionary[@"interested_in"]) {
                userProfile[kUserProfileInterestedInKey] = userDictionary[@"interested_in"];
            }
            if (userDictionary[@"relationship_status"]) {
                userProfile[kUserProfileRelationshipStatusKey] = userDictionary[@"relationship_status"];
            }
            //absoluteString converts NSURL to NSString
            if ([pictureURL absoluteString]) {
                userProfile[kUserProfilePictureURL]= [pictureURL absoluteString];
            }
            
            [[PFUser currentUser] setObject:userProfile forKey:kUserProfileKey];
            [[PFUser currentUser] saveInBackground];
            [self requestImage];
        } else {
            NSLog(@"Error in FB: %@", error);
        }
    }];
}

// This will upload an image to parse
-(void)uploadPFFileToParse:(UIImage *)image
{
    // we get an image and we are converting it to NSData Object
    // This 0.8 compresses the file to 80%
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    
    if (!imageData) {
        NSLog(@"imageData was not found");
        return;
    }
    
    PFFile *photoFile = [PFFile fileWithData:imageData];
    
    // This will save teh file on parse
    [photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // Now we want to creat an instance of Photo
            PFObject *photo = [PFObject objectWithClassName:kPhotoClassKey];
            // Set the user key on the photo object
            [photo setObject:[PFUser currentUser] forKey:kPhotoUserKey];
            // Set the photo key on the photo object
            [photo setObject:photoFile forKey:kPhotoPictureKey];
            
            [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    NSLog(@"Photos saved successfully");
                } else {
                    NSLog(@"Error saving photo: %@ %@", error, [error userInfo]);
                }
                
            }];
        }
    }];
}

-(void)requestImage
{
    // create a query that gets all the photos from parse
    PFQuery *query = [PFQuery queryWithClassName:kPhotoClassKey];
    // add an additional constaint on query
    // Only give me back the photos where the user marches the current user
    [query whereKey:kPhotoUserKey equalTo:[PFUser currentUser]];
    // we dont actually want the photo, we just want to get a count of the photos
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        // if the user doesn't have a photo yet, we make a request to the url
        if (number == 0) {
            PFUser *user = [PFUser currentUser];
            self.imageData = [[NSMutableData alloc]init];
            
            // Get the url we saved in the user
            NSString *url = user[kUserProfilePictureURL];
            NSURL *profilePictureURL = [NSURL URLWithString:user[kUserProfileKey][kUserProfilePictureURL]];
            // create a request and setup some settings like cache policy and timout
            // Also sets teh cache policy
            // Aso sets teh time out to 4 seconds; incase we dont' get a respones
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:profilePictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4.0f];
            
            // Then we create a connection with the request
            NSURLConnection *urlConnection = [[NSURLConnection alloc]initWithRequest:urlRequest delegate:self];
            
            if (!urlConnection) {
                NSLog(@"Failed to download picture");
            }
        }
    }];
}

#pragma mark - NSURLConnectionData delegate methods

// As chunks of the data is received (the image) we are going to build our file
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // This will just keep adding parts of the image data to the self.imageData
    [self.imageData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    UIImage *profileImage = [UIImage imageWithData:self.imageData];
    // this will save our image to parse
    [self uploadPFFileToParse:profileImage];
}

@end
