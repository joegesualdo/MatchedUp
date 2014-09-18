//
//  AppDelegate.m
//  MatchedUp
//
//  Created by Joe Gesualdo on 9/18/14
//  Copyright (c) 2014 joegesualdo. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Get the dictionary from our Keys.plist file. This file stores all our secret api credentials
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Keys" ofType:@"plist"]];
    
    
    // Get and set Parse credentials
    NSString *parseApplicationId = [dictionary objectForKey:@"parseApplicationId"];
    NSString *parseClientKey = [dictionary objectForKey:@"parseClientKey"];
    //add your parse keys here
    [Parse setApplicationId:parseApplicationId
                  clientKey:parseClientKey];
    
    //setup parse with facebook. This is a singleton
    [PFFacebookUtils initializeFacebook];
    
    
    
    return YES;
}

// TODO: What is this? It's required for facebook sdk & ParseFAcebook sdk
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // supports single login feature for facebook sdk
    // This helps use setup and instance of PFFacebook Utilis
    // attempt to extract a token from the url
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

@end
