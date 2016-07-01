//
//  Globals
//  WA
//
//  Created by Sharon Brizinov on 3/9/14.
//  Copyright (c) 2014 Sharon Brizinov. All rights reserved.

/*
 
 Feature list
 -========== -========== -========== -==========
 
 - Add support for the following graphs:
 1. Days vs. amount-of-messages (what is the most chatted day in the week)
 2. Hours vs. amount-of-messages (what is the most chatted hour in 24-hr day)
 3. Time to respond to a previous message
 4. Histogram of the number of characters per message
 5. Day in month vs. number of message (git style graph)
 6. Who's strating the conversation mostly
 
 - Add support for the following word-clouds
 1. Get the most unique words from conversation
 2. Get the most frequent words form conversation

 - Order categories somehow (alphabetically?)
	- words: wordsviewcontroller, graphvc
	- categories: conversationviewcontroller, categoriesvc

 - Add support for differnet exported conversations
 */


/* IMPORTS */
/**************************/
// Basic
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// External
#import "MBProgressHUD.h"
#import "LGFlapJackStackView.h"
#import "LGFlapJack.h"
#import "M13OrderedDictionary.h"
#import "SQPDatabase.h"
#import "SQPObject.h"
#import <OpinionzAlertView/OpinionzAlertView.h>
#import <STPopup/STPopup.h>
#import "UIColor+GraphKit.h"
#import "GraphKit.h"
#import <MKFoundationKit/NSArray+MK.h>

// Project
#import "GlobalManager.h"

// View Controllers
#import "MainViewController.h"
#import "ConversationViewController.h"
#import "GraphForTwoViewController.h"
#import "BottomSheetCategorySelectorViewController.h"
#import "MultiSelectionWordsViewController.h"
#import "GraphBarsViewController.h"

// Classes
#import "Message.h"
#import "Conversation.h"
#import "WAObject.h"
#import "AnalyzeData.h"
#import "WordAnalysisCategory.h"
#import "Tag.h"
#import "Word.h"

// External Libs
/**************************/


// Debug
/**************************/
#define kDEBUG YES

// Singleton easy-usage
/**************************/
#define kGlobalConversation ((GlobalManager*)[GlobalManager sharedManager]).conversation
#define kGlobalUsername     ((GlobalManager*)[GlobalManager sharedManager]).strUserName


// Consts
/**************************/

// Conversation
#define kConversationTypePersonNumberOfParticipants 2
#define kConversationStatisticsValues               @"values"
#define kConversationStatisticsLabels               @"labels"
#define kConversationStatisticsLabelAfterLimit      @"Others"


// Parsing
#define kDateFormat                 @"dd.MM.yyyy, H:m:ss"
#define kDateFormat2                @"MM/dd/yy, H:m"  //@NOTE: Andorid?

#define kSeperatorInlineMessage     @": "
#define kSeperatorInlineDate        @": "
#define kSeperatorInlineDate2       @"- "

#define kSeperatorInlineAdded       @"added "           //@TODO: support
#define kSeperatorInlineCreated     @"created group "   //@TODO: support
#define kSeperatorInlineLeft        @"left"           //@TODO: support

#define kSeperatorBetweenlines      @"\n"
#define kSeperatorComma             @","
#define kSeperatorFileNameOnDisk    @"WhatsApp Chat: "


// File
#define kDBBase                 @"wamaindb.db"
#define kFileFormat             @"txt"
#define kFileNameDemo           @"text"
#define kFileNameDemo2          @"text2"
#define kFileNameDemo3          @"text3"
#define kFileNameDemo4          @"text4"

// Word Analysis - Defualt list
#define kWordAnalysisFileFormat                     @"plist"
#define kWordAnalysisFileName                       @"WordAnalysisDefaultCategory"
#define kWordAnalysisFileKeyName_Name               @"Name"
#define kWordAnalysisFileKeyName_Words              @"Words"
#define kWordAnalysisFileKeyName_Tags               @"Tags"
#define kWordAnalysisFileKeyName_Description        @"Description"
#define kWordAnalysisFileKeyName_InnerSearch        @"InnerSearch"

// Inner notifications
#define kNotificationCenterNewConversation             @"kNotificationCenterNewConversation"
#define kNotificationCenterDeleteConversation          @"kNotificationCenterDeleteConversation"


// Regex
#define kRegexGroupNameOriginal         @"(.*)-[\\d]+$"

// Graphs
#define kGraphBarsMaxRows               6


/**************************/
/* Easy methods */
#define kAppVersion [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

#define kSetValueForKey(value,key)  [[NSUserDefaults standardUserDefaults] setValue:value forKey:key]
#define kGetValueForKey(key)  [[NSUserDefaults standardUserDefaults] valueForKey:key]

// Shared

// Gets string and return True or False
#define kIS_IOS_X(x) [[[UIDevice currentDevice] systemVersion] hasPrefix:x]
#define kIS_IOS_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


#define IS_WIDESCREEN [[UIScreen mainScreen] bounds].size.height == 568.0
#define IS_IPHONE ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPhone" ] )
#define IS_IPOD   ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPod touch" ] )
#define IS_IPHONE_5 ( IS_IPHONE && IS_WIDESCREEN )



#define NSLogFormat1Arg @"\n-----\n%@\n------\n"
#ifdef kDEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#ifdef kDEBUG
#   define ULog(fmt, ...)  { UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%s\n [Line %d] ", __PRETTY_FUNCTION__, __LINE__] message:[NSString stringWithFormat:fmt, ##__VA_ARGS__]  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil]; [alert show]; }
#else
#   define ULog(...)
#endif

/**************************/

/**************************/
/* Globals */

/**************************/



/**************************/
/* KEYS */


/**************************/


/**************************/
/* FILES */

/**************************/



/**************************/
/* Custom Message */

/**************************/


// External APIs
/**************************/
#define kGOOGLE_ANALYTICS_TRACKING_ID @""


/**************************/

/**************************/


/* Storyboard */
#define kStoryBoard                 @"Main"

/* StoryboardID */
#define kStoryBoard_Main                @"MainStoryboardID"
#define kStoryBoard_Conversation        @"ConversationStoryboardID"
#define kStoryBoard_GraphForTwo         @"GraphForTwoStoryboardID"
#define kStoryBoard_GraphForMultiple    @"GraphForMultipleStoryboardID"
#define kStoryBoard_Categories          @"CategoriesStoryboardID"
#define kStoryBoard_Words               @"WordsStoryboardID"

/**************************/
/* Segues */
#define kSegue_Show_Conversation        @"showConversation"
#define kSegue_Show_Graph               @"showConversationGraph"
#define kSegue_Show_WordsSelection      @"showWordsSelection"

/**************************/
/* Cell ids */
#define kCellID_Message                 @"CellMessage"
#define kCellID_Basic                   @"CellBasic"
#define kCellID_BasicEdit               @"CellBasicEdit"
#define kCellID_Graph                   @"CellGraph"
#define kCellID_Category                @"CellCategory"
#define kCellID_CategoryScrollView      @"CellWordsScrollview"
#define kCellID_Word                    @"CellWord"

/**************************/
/* View Tags */
#define kTag_View_Cell_Message_TextView 1001



/*  ENUMS   */



/**************************/
/* ERROR CODES */
#define kERROR_SUCCESS 0
#define kERROR_GENERAL 1
/**************************/