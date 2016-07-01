//
//  GlobalManager.m
//  iNvity
//
//  Created by Sharon Brizinov on 3/9/14.
//  Copyright (c) 2014 Sharon Brizinov. All rights reserved.
//

#import "GlobalManager.h"
#import "Conversation.h"

@implementation GlobalManager

@synthesize conversation, strUserName;

#pragma mark Singleton Methods
static GlobalManager *sharedGlobalManager = nil;
+ (id)sharedManager {
    @synchronized(self) {
        if (sharedGlobalManager == nil)
            sharedGlobalManager = [[self alloc] init];
    }
    return sharedGlobalManager;
}


- (id)init {
    if (self = [super init])
    {
        conversation = nil;
        strUserName = @"Sharon B";
    }
    return self;
}




+(int)getRandomNumberBetween:(int)from to:(int)to
{
    return (int)from + arc4random() % (to-from+1);
}


// Checks if the group name is already exists (Addition of "-[\d]+" at the end of group's name)
// Returns nil if didn't find anything
+(NSString*) getOriginalGroupNameFromPossibleDuplicatedGroupName:(NSString*)strGroupNameNew
{
    /* REGEX */
    // Prepare the regex
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:kRegexGroupNameOriginal options:(NSRegularExpressionCaseInsensitive) error:&error];
    NSTextCheckingResult *match = [regex firstMatchInString:strGroupNameNew options:0 range:NSMakeRange(0, [strGroupNameNew length])];
    // If we found a location of inner text return just the name of the group without the additional numbers
    if (match.range.location != NSNotFound)
    {
        // extract the real name
        return [strGroupNameNew substringWithRange:match.range];
    }
    // Didn't find nothing, return null
    else
    {
        return nil;
    }
}

// Search and returns how many times 'substring' is found in 'string'
+(NSUInteger) howManyTimesSubtringInString:(NSString*)strString withSubString:(NSString*)strSubString shouldInStringToBeIsolated:(BOOL)isWordIsolated shouldTrimWhitespacesFromBaseString:(BOOL)isTrimWhitespaces
{
    
    /* Quick checks */
    if ([strSubString isEqualToString:strString])
        return 1;
    
    
    /* Prepare */
    NSString * strStringToWork = isTrimWhitespaces ? [strString stringByTrimmingCharactersInSet: [NSCharacterSet newlineCharacterSet]] : strString;
    NSString * strSubStringToWork = [GlobalManager stringHelperPrepareSubStringForRegex:strSubString shouldInStringToBeIsolated:isWordIsolated];
    
    
    /* REGEX */
    // Prepare the regex
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:strSubStringToWork options:(NSRegularExpressionCaseInsensitive) error:&error];
    // Search how many occurances of 'substring' are found
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:strStringToWork options:0 range:NSMakeRange(0, [strStringToWork length])];
    
    
    
    /***************************/
    /* Test - DEBUG MODE ONLY */
    if (kDEBUG)
    {
        // Prepare string
        strStringToWork = [strString stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
        strSubStringToWork = [@"" stringByAppendingString:strSubString];
        
        if (isWordIsolated)
            strSubStringToWork = [NSString stringWithFormat:@" %@ ",strSubStringToWork];

        // Compare regular 'rangeOfString' to regular expression
        if ([strStringToWork rangeOfString: strSubStringToWork].location != NSNotFound && numberOfMatches == 0)
        {
            NSLog(@"Regular expression error!\nOriginal String: %@\nSubstring: %@\nRegex match found: %lu", strString, strSubString, (unsigned long)numberOfMatches);
        }
    }
    /***************************/
    
    return numberOfMatches;
}
+(NSString*) stringHelperPrepareSubStringForRegex:(NSString*)strInString shouldInStringToBeIsolated:(BOOL)isWordIsolated
{
    // Must be escaped:
    // * ? + [ ( ) { } ^ $ | \ . /
    
    // Replace escaped items
    strInString = [strInString stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"]; // Must be first
    strInString = [strInString stringByReplacingOccurrencesOfString:@"*" withString:@"\\*"];
    strInString = [strInString stringByReplacingOccurrencesOfString:@"?" withString:@"\\?"];
    strInString = [strInString stringByReplacingOccurrencesOfString:@"[" withString:@"\\["];
    strInString = [strInString stringByReplacingOccurrencesOfString:@"(" withString:@"\\("];
    strInString = [strInString stringByReplacingOccurrencesOfString:@")" withString:@"\\)"];
    strInString = [strInString stringByReplacingOccurrencesOfString:@"{" withString:@"\\{"];
    strInString = [strInString stringByReplacingOccurrencesOfString:@"}" withString:@"\\}"];
    strInString = [strInString stringByReplacingOccurrencesOfString:@"^" withString:@"\\^"];
    strInString = [strInString stringByReplacingOccurrencesOfString:@"$" withString:@"\\$"];
    strInString = [strInString stringByReplacingOccurrencesOfString:@"|" withString:@"\\|"];
    strInString = [strInString stringByReplacingOccurrencesOfString:@"." withString:@"\\."];
    strInString = [strInString stringByReplacingOccurrencesOfString:@"/" withString:@"\\/"];
    
    // Isolate word from another words
    if (isWordIsolated)
        strInString = [NSString stringWithFormat:@"\\b%@\\b",strInString];
    
    return strInString;
    
}


// Removes conversation's file on disk
+(BOOL)removeConversationFromStorageWithConversation:(Conversation*)conv
{
    return [GlobalManager removeFileFromStorageWithURL:conv.urlFileOnDisk];
}
+(BOOL)removeFileFromStorageWithURL:(NSURL*) url
{
    return [[NSFileManager defaultManager] removeItemAtURL:url error:NULL];
}

// Ask the user if he wants to delete conversation, and delete from all resources if so (SQL DB, File on disk, notify everyone)
+(void) askTheUserForDeletingConversation:(Conversation*) convToDelete withReason:(NSInteger) conversationDeleteType
{
dispatch_async(dispatch_get_main_queue(), ^{

    // Date formatting
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterLongStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    
    // Alert properties
    NSString * strTitle = @"Delete Conversation";
    OpinionzAlertIcon alertIcon = OpinionzAlertIconWarning;
    
    switch (conversationDeleteType) {
        case ConversationDeleteDuplicate:
            strTitle = @"Older Conversation Was Found";
            alertIcon = OpinionzAlertIconInfo;
            break;
        case ConversationDeleteGeneral:
            strTitle = @"Delete Selected Conversation";
            alertIcon = OpinionzAlertIconWarning;
            break;
        default:
            break;
    }
    OpinionzAlertView * alertView = [[OpinionzAlertView alloc] initWithTitle: strTitle message: [NSString stringWithFormat:@"'%@' was added at %@, with %d messages", convToDelete.strGroupName, [dateFormatter stringFromDate:convToDelete.dateAddedAt], convToDelete.numberTotalMessages.intValue] cancelButtonTitle:@"Keep it" otherButtonTitles:@[@"Delete it"] usingBlockWhenTapButton:^(OpinionzAlertView *alertView, NSInteger buttonIndex) {
        switch (buttonIndex) {
            case 0:
                // Cancel
                break;
            case 1:
                // Delete
                
                // remove from DB
                [convToDelete SQPDeleteEntityWithCascade:YES];
                
                // remove from disk
                [GlobalManager removeConversationFromStorageWithConversation:convToDelete];
                
                // Notify everyone that we have a new conversation
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCenterDeleteConversation object:convToDelete];
                break;
                
            default:
                break;
        }
    }];
    alertView.iconType = alertIcon;
    [alertView show];
});
}

@end