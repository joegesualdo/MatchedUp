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
    
    
    return YES;
}

@end
