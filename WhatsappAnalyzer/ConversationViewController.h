//
//  MasterViewController.h
//  WhatsappAnalyzer
//
//  Created by Sharon Brizinov on 14/10/2015.
//  Copyright © 2015 SBSoftware. All rights reserved.
//

#import "Globals.h"

@class Conversation;

@interface ConversationViewController : UITableViewController <UISplitViewControllerDelegate>

// Conversation
@property (nonatomic, strong) Conversation * conversation;
@property () int nHowManyComposers;

// Indicator for collapsing the detail view controller
@property (nonatomic) BOOL shouldCollapseDetailViewController;

// Is in edit mode
@property (nonatomic) BOOL isInEditMode;

// Is multiple person converstaion?
@property (nonatomic) BOOL isMultipleConversation;
@end

