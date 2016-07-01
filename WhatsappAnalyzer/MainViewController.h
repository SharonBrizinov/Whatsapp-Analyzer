//
//  MasterViewController.h
//  WhatsappAnalyzer
//
//  Created by Sharon Brizinov on 14/10/2015.
//  Copyright © 2015 SBSoftware. All rights reserved.
//

#import "Globals.h"

@class ConversationViewController;

@interface MainViewController : UITableViewController

@property (strong, nonatomic) ConversationViewController    *viewControllerConversation;
@property (strong, nonatomic) NSMutableArray                *arrayConversations;




-(void) recievingNotificationNewConversation:(NSNotification *)notification;
-(void) recievingNotificationDeleteConversation:(NSNotification *)notification;


@end

