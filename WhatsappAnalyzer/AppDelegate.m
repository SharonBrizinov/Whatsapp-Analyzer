//
//  AppDelegate.m
//  WhatsappAnalyzer
//
//  Created by Sharon Brizinov on 14/10/2015.
//  Copyright © 2015 SBSoftware. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    /* Design */
    [[UINavigationBar appearance] setBarTintColor:[UIColor gk_greenSeaColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor gk_cloudsColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor gk_cloudsColor]}];
    

    /* FOR DEBUG PURPOSES ONLY */
    if (kDEBUG)
    {
        // Create DB to work with
        [[SQPDatabase sharedInstance] setupDatabaseWithName: kDBBase];  // Create DB (if not existed yet)
        [SQPDatabase sharedInstance].addMissingColumns = YES;           // Important for 1 to many relation
        
        // Remove file disk, DB
        for (Conversation * conv in [Conversation SQPFetchAll])
        {
            // remove from DB
            [conv SQPDeleteEntityWithCascade:YES];
            // remove from disk
            [GlobalManager removeConversationFromStorageWithConversation:conv];
        }
        
        
        // Remove DB
        [[SQPDatabase sharedInstance] removeDatabase];
        
        
    }
    
    
    // Create DB to work with
    [[SQPDatabase sharedInstance] setupDatabaseWithName: kDBBase];  // Create DB (if not existed yet)
    [SQPDatabase sharedInstance].addMissingColumns = YES;           // Important for 1 to many relation
    
    
    
    /* FOR DEBUG PURPOSES ONLY */
    if (kDEBUG)
    {
        // Test for public view
        NSURL* urlPathTest = [[NSBundle mainBundle] URLForResource:kFileNameDemoTest withExtension:kFileFormat];
        Conversation * convTest = [AnalyzeData parseMessagesFromLocalFileWithURL: urlPathTest];
        convTest.urlFileOnDisk = urlPathTest; // Path to conversation local file on disk
        convTest.dateAddedAt = [NSDate date]; // Set the date for now
        convTest.numberTotalMessages = [NSNumber numberWithUnsignedInteger:[convTest.arrayMessages count]]; // total messages in conversation
        [convTest.arrayWordAnalysisCategory addObjectsFromArray:[WordAnalysisCategory getDefaultWordAnalysisCategories]];
        [convTest SQPSaveEntityWithCascade:YES];
        
        
        /*
        NSURL* urlPath = [[NSBundle mainBundle] URLForResource:kFileNameDemo withExtension:kFileFormat];
        Conversation * conv = [AnalyzeData parseMessagesFromLocalFileWithURL: urlPath];
        conv.urlFileOnDisk = urlPath; // Path to conversation local file on disk
        conv.dateAddedAt = [NSDate date]; // Set the date for now
        conv.numberTotalMessages = [NSNumber numberWithUnsignedInteger:[conv.arrayMessages count]]; // total messages in conversation
        [conv.arrayWordAnalysisCategory addObjectsFromArray:[WordAnalysisCategory getDefaultWordAnalysisCategories]];
        [conv SQPSaveEntityWithCascade:YES];
        
        
        NSURL* urlPath2 = [[NSBundle mainBundle] URLForResource:kFileNameDemo2 withExtension:kFileFormat];
        Conversation * conv2 = [AnalyzeData parseMessagesFromLocalFileWithURL: urlPath2];
        conv2.urlFileOnDisk = urlPath2; // Path to conversation local file on disk
        conv2.dateAddedAt = [NSDate date]; // Set the date for now
        conv2.numberTotalMessages = [NSNumber numberWithUnsignedInteger:[conv2.arrayMessages count]]; // total messages in conversation
        [conv2.arrayWordAnalysisCategory addObjectsFromArray:[WordAnalysisCategory getDefaultWordAnalysisCategories]];
        [conv2 SQPSaveEntityWithCascade:YES];
        
        
        NSURL* urlPath3 = [[NSBundle mainBundle] URLForResource:kFileNameDemo3 withExtension:kFileFormat];
        Conversation * conv3 = [AnalyzeData parseMessagesFromLocalFileWithURL: urlPath3];
        conv3.urlFileOnDisk = urlPath3; // Path to conversation local file on disk
        conv3.dateAddedAt = [NSDate date]; // Set the date for now
        conv3.numberTotalMessages = [NSNumber numberWithUnsignedInteger:[conv3.arrayMessages count]]; // total messages in conversation
        [conv3.arrayWordAnalysisCategory addObjectsFromArray:[WordAnalysisCategory getDefaultWordAnalysisCategories]];
        [conv3 SQPSaveEntityWithCascade:YES];
        
        NSURL* urlPath4 = [[NSBundle mainBundle] URLForResource:kFileNameDemo4 withExtension:kFileFormat];
        Conversation * conv4 = [AnalyzeData parseMessagesFromLocalFileWithURL: urlPath4];
        conv4.urlFileOnDisk = urlPath4; // Path to conversation local file on disk
        conv4.dateAddedAt = [NSDate date]; // Set the date for now
        conv4.numberTotalMessages = [NSNumber numberWithUnsignedInteger:[conv4.arrayMessages count]]; // total messages in conversation
        [conv4.arrayWordAnalysisCategory addObjectsFromArray:[WordAnalysisCategory getDefaultWordAnalysisCategories]];
        [conv4 SQPSaveEntityWithCascade:YES];
         */
    }
    
    
    
    return YES;
}



// Import from another app
-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options
{
    if (url)
    {
        /* Run code with HUD */
        [MBProgressHUD showHUDAddedTo: self.window.rootViewController.view animated:YES];
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            //file:///private/var/mobile/Containers/Data/Application/451826D0-8A69-44BF-8188-51890EB3CD3D/Documents/Inbox/WhatsApp%20Chat:%20~-8.txt
            // Analyze conversation and store in DB as new conversation
            Conversation * conv = [AnalyzeData parseMessagesFromLocalFileWithURL: url];
            conv.urlFileOnDisk = url; // Path to conversation local file on disk
            conv.dateAddedAt = [NSDate date]; // Set the date for now
            conv.numberTotalMessages = [NSNumber numberWithUnsignedInteger:[conv.arrayMessages count]]; // total messages in conversation
            [conv.arrayWordAnalysisCategory addObjectsFromArray:[WordAnalysisCategory getDefaultWordAnalysisCategories]];
            [conv SQPSaveEntityWithCascade:YES];
            
            // Handle possible older conversations
            NSMutableArray * arrayConversationsOlder = [Conversation getPreviousConversations:conv];
            if (arrayConversationsOlder && arrayConversationsOlder.count > 0) {
                // Remove duplicates
                for (Conversation * convOld in arrayConversationsOlder)
                {
                    [GlobalManager askTheUserForDeletingConversation:convOld withReason:(ConversationDeleteType)ConversationDeleteDuplicate];
                }
            }
            else {
                // Imported successfully
dispatch_async(dispatch_get_main_queue(), ^{
                OpinionzAlertView * alertView = [[OpinionzAlertView alloc] initWithTitle: conv.strGroupName message: @"Imported successfully !" cancelButtonTitle:@"OK" otherButtonTitles:nil];
                alertView.iconType = OpinionzAlertIconSuccess;
                [alertView show];
});
            }
            
            
            
            
            // Notify everyone that we have a new conversation
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCenterNewConversation object:conv];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView: self.window.rootViewController.view animated:YES];
            });
        });
    
        
        
        
    }
    return YES;
}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



@end
