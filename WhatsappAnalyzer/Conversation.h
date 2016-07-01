//
//  Conversation.h
//  WhatsappAnalyzer
//
//  Created by Sharon Brizinov on 15/10/2015.
//  Copyright © 2015 SBSoftware. All rights reserved.
//

#import "Globals.h"
@class Message;


@interface Conversation : SQPObject

/* Basic */
@property(nonatomic, retain) NSString                       * strGroupName;
@property(nonatomic, retain) NSMutableArray                 * arrayMessages;
@property(nonatomic, retain) NSMutableArray                 * arrayWAObjects;

// For DB purposes
@property(nonatomic, retain) NSDate                         * dateAddedAt; // When the conversation was added to app
@property(nonatomic, retain) NSNumber                       * numberTotalMessages; // How many messages were sent in total
@property(nonatomic, retain) NSURL                          * urlFileOnDisk; // URL path to file on disk

// Word analysis
@property(nonatomic, retain) NSMutableArray<SQPObject *>    * arrayWordAnalysisCategory;



/* Reasons to delete conversation */
typedef NS_ENUM(NSInteger, ConversationDeleteType) {
    ConversationDeleteDuplicate,
    ConversationDeleteGeneral,
};




// Is the object parsed already
-(BOOL) isParsed;

// Adding new message to array
-(void) addNewMessage:(Message*)message;

// Get all composers
-(NSArray*) getAllComposersWithShouldIndicateYourseld:(BOOL)isIndicateYourself;
-(NSArray*) getAllComposers;

// Get Chat Type
-(NSString*) getChatType;

// How many times a person said a certin word
-(NSUInteger) getHowManyTimesItWasSaid:(NSString*)strWord forComposer:(NSString*)strComposer shouldInStringToBeIsolated:(BOOL)isIsolated shouldTrimWhitespacesFromBaseString:(BOOL)isTrimWhitespaces;

// Get how many chars were written in chat all together
-(NSUInteger) getHowManyCharsInConversation;

// Return previous conversation if found. nil otherwise
+(NSMutableArray *)getPreviousConversations:(Conversation*)convCurrent;



/* Graph Statistcs */

// Number of message each participants sent
// limit: All the items after 'limit' items will be counted as "Other"
// bMostMessages: Should return the most message or the fewest
// Returns dictionary with two DESC arrays (values, labels)
-(NSDictionary*)getGraphDataDESCOfNumberOfMessagesWithFewestMessages:(BOOL)bFewMessages withLimit:(int)limit;

// Number of times each word was said
// limit: All the items after 'limit' items will be counted as "Other"
// Returns dictionary with two DESC arrays (values, labels)
-(NSDictionary*)getGraphDataDESCOfHowManyTimesEachWordWasSaidWithArrayOfWords:(NSArray*)arrayWords withLimit:(int)limit;
@end
