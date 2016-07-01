//
//  GlobalManager.h
//  iNvity
//
//  Created by Sharon Brizinov on 3/9/14.
//  Copyright (c) 2014 Sharon Brizinov. All rights reserved.
//
#import "Globals.h"
@class Conversation;


@interface GlobalManager : NSObject
{
    Conversation * conversation;
    NSString     * strUserName;
}

@property (nonatomic, retain) Conversation * conversation;
@property (nonatomic, retain) NSString * strUserName;


// Shared instance
+ (id)sharedManager;

// Random int
+(int)getRandomNumberBetween:(int)from to:(int)to;


// Checks if the group name is already exists (Addition of "-[\d]+" at the end of group's name)
// Returns nil if didn't find anything
+(NSString*) getOriginalGroupNameFromPossibleDuplicatedGroupName:(NSString*)strGroupNameNew;

// Search and returns how many times 'substring' is found in 'string'
+(NSUInteger) howManyTimesSubtringInString:(NSString*)strString withSubString:(NSString*)strSubString shouldInStringToBeIsolated:(BOOL)isWordIsolated shouldTrimWhitespacesFromBaseString:(BOOL)isTrimWhitespaces;
+(NSString*) stringHelperPrepareSubStringForRegex:(NSString*)strInString shouldInStringToBeIsolated:(BOOL)isWordIsolated;


// Removes conversation's file on disk
+(BOOL)removeConversationFromStorageWithConversation:(Conversation*)conv;
+(BOOL)removeFileFromStorageWithURL:(NSURL*) url;

// Ask the user if he wants to delete conversation, and delete from all resources if so (SQL DB, File on disk, notify everyone)
+(void) askTheUserForDeletingConversation:(Conversation*) convToDelete withReason:(NSInteger) conversationDeleteType;
@end