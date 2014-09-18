//
//  HomeViewController.m
//  MatchedUp
//
//  Created by Joe Gesualdo on 9/18/14.
//  Copyright (c) 2014 joegesualdo. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController ()

#pragma mark - IBOutlets

@property (weak, nonatomic) IBOutlet UIBarButtonItem *chatBatButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingsBarButtonItem;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UILabel *tagLineLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (weak, nonatomic) IBOutlet UIButton *dislikeButton;

#pragma mark - IBActions

- (IBAction)chatBarButtonItemPressed:(UIBarButtonItem *)sender;
- (IBAction)settingsBarButtonPressed:(UIBarButtonItem *)sender;
- (IBAction)likeButtonPressed:(UIButton *)sender;
- (IBAction)dislikeButtonPressed:(UIButton *)sender;
- (IBAction)infoButtonPressed:(UIButton *)sender;

// We are going to store all the photos from other users in this photos property
@property(strong,nonatomic)NSArray *photos;
@property(strong,nonatomic)PFObject *photo;
// activies let us keep track of who we liked
@property(strong, nonatomic)NSMutableArray *activities;
// This will store the current photo your looking at
@property(nonatomic)int currentPhotoIndex;
// for the current use on screen, have i already liked or disliked them
@property(nonatomic)BOOL isLikedByCurrentUser;
@property(nonatomic)BOOL isDislikedByCurrentUser;

@end

@implementation HomeViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Don't want user to immediately press the like, dislike, or info untile we get all the info from the network
//    self.likeButton.enabled = NO;
//    self.dislikeButton.enabled = NO;
    self.infoButton.enabled = NO;
    
    self.currentPhotoIndex = 0;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    // include key will also include the User object from the parse User
    // When we dowload the photo we should also download the user
    [query includeKey:@"user"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.photos = objects;
            // We created this method below
            [self queryForCurrentPhotoIndex];
            // we update the view outlets
            [self updateView];
        } else {
            NSLog(@"Error: %@", error);
        }
    }];
    
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

- (IBAction)chatBarButtonItemPressed:(UIBarButtonItem *)sender {
}

- (IBAction)settingsBarButtonPressed:(UIBarButtonItem *)sender {
}
- (IBAction)likeButtonPressed:(UIButton *)sender {
    [self checkLike];
}

- (IBAction)dislikeButtonPressed:(UIButton *)sender {
    [self checkDislike];
}

- (IBAction)infoButtonPressed:(UIButton *)sender {
}

#pragma mark - Helper Methods

// query for current photo index to get back PFFile that will store the data for the image we want to display for our use
-(void)queryForCurrentPhotoIndex
{
    // we first chck if we have photos
    if ([self.photos count] > 0) {
        self.photo = self.photos[self.currentPhotoIndex];
        // access the value for the key image to get back a PFFile
        // this is just a pointer to the file
        PFFile *file = self.photo[@"image"];
        // this will actually get the file
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:data];
                self.photoImageView.image = image;
            } else {
                NSLog(@"%@",error);
            }
        }];
    }
}

-(void)updateView
{
    // We can get the user fromt he photo, because on our query above we included key for user
    self.firstNameLabel.text = self.photo[@"user"][@"profile"][@"firstName"];
    self.ageLabel.text = [NSString stringWithFormat:@"%@", self.photo[@"user"][@"profile"][@"age"]];
    self.tagLineLabel.text = self.photo[@"user"][@"tagLine"];
}

-(void)setupNextPhoto
{
    // checks if there is another photo
    if ((self.currentPhotoIndex + 1) < self.photos.count) {
        self.currentPhotoIndex ++;
        [self queryForCurrentPhotoIndex];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"No More uesrs to view" message:@"Check back later for more people" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

-(void)saveLike
{
    // This is how we create a new class - Activity
    PFObject *likeActivity = [PFObject objectWithClassName:@"Activity"];
    [likeActivity setObject:@"like" forKey:@"type"];
    [likeActivity setObject:[PFUser currentUser] forKey:@"fromUser"];
    [likeActivity setObject:[self.photo objectForKey:@"user"] forKey:@"toUser"];
    [likeActivity setObject:self.photo forKey:@"Photo"];
    [likeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.isLikedByCurrentUser = YES;
        self.isDislikedByCurrentUser = NO;
        [self.activities addObject:likeActivity];
        [self setupNextPhoto];
    }];
}

-(void)saveDislike
{
    // This is how we create a new class - Activity
    PFObject *dislikeActivity = [PFObject objectWithClassName:@"Activity"];
    [dislikeActivity setObject:@"dislike" forKey:@"type"];
    [dislikeActivity setObject:[PFUser currentUser] forKey:@"fromUser"];
    [dislikeActivity setObject:[self.photo objectForKey:@"user"] forKey:@"toUser"];
    [dislikeActivity setObject:self.photo forKey:@"Photo"];
    [dislikeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.isLikedByCurrentUser = NO;
        self.isDislikedByCurrentUser = YES;
        [self.activities addObject:dislikeActivity];
        [self setupNextPhoto];
    }];
}

-(void)checkLike
{
    // checks if you already like current user
    if (self.isLikedByCurrentUser) {
        [self setupNextPhoto];
        return;
    // checks if you disliked the user in the past
    } else if (self.isDislikedByCurrentUser){
        for (PFObject *activity in self.activities){
            [activity deleteInBackground];
        }
        [self.activities removeLastObject];
        [self saveLike];
    // If you havent either liked or disliked the user
    } else {
        [self saveLike];
    }
}

-(void)checkDislike
{
    // checks if you already like current user
    if (self.isDislikedByCurrentUser) {
        [self setupNextPhoto];
        return;
    // checks if you disliked the user in the past
    } else if (self.isLikedByCurrentUser){
        for (PFObject *activity in self.activities){
            [activity deleteInBackground];
        }
        [self.activities removeLastObject];
        [self saveDislike];
    // If you havent either liked or disliked the user
    } else {
        [self saveDislike];
    }
}
@end
