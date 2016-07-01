//
//  AnalyzeData.m
//  WhatsappAnalyzer
//
//  Created by Sharon Brizinov on 15/10/2015.
//  Copyright © 2015 SBSoftware. All rights reserved.
//

#import "AnalyzeData.h"

@implementation AnalyzeData

// Parse messages for an existing conversation object
+(Conversation*) parseMessagesFromExistingConversationObject:(Conversation*)conv
{
    return [AnalyzeData parseRawMessagesWithArray:[AnalyzeData getRawMessages:conv.urlFileOnDisk] withConversation:conv];
}

// Parse messages into Conversation object from local file (mostly for testing)
+(Conversation*) parseMessagesFromLocalFileWithURL:(NSURL*)urlPath
{
    // Get path
    //NSString* path = [[NSBundle mainBundle] pathForResource:kFileName ofType:kFileFormat];
    
    // Get all raw messages and parse
    Conversation * conv = [AnalyzeData parseRawMessagesWithArray:[AnalyzeData getRawMessages:urlPath] withConversation:nil];
    
    //@TODO: kGlobalUsername - get the real username
    // Find name for conversation (Basically it's the other person you are talking with)
    if ([conv.arrayWAObjects count] == kConversationTypePersonNumberOfParticipants) // Two people conversation
    {
        conv.strGroupName = [((WAObject*)[conv.arrayWAObjects firstObject]).strComposer isEqualToString:kGlobalUsername] ? ((WAObject*)[conv.arrayWAObjects lastObject]).strComposer : ((WAObject*)[conv.arrayWAObjects firstObject]).strComposer;
    }
    else
    {
        /* The file's name should be like that "WhatsApp Chat: ~-8.txt" 
         Regex --> (.*)-[\\d]+$
         */
        
        NSString* strGroupName = [[[[[[urlPath absoluteString] stringByRemovingPercentEncoding] componentsSeparatedByString:kSeperatorFileNameOnDisk] lastObject] componentsSeparatedByString: [NSString stringWithFormat:@".%@", kFileFormat]] firstObject];
        // Check if group name already exists in app -> duplicated conversation
        // If so, extract original group's name
        NSString * strGroupNameOrigianl = [GlobalManager getOriginalGroupNameFromPossibleDuplicatedGroupName:strGroupName];
        if (strGroupNameOrigianl && ![strGroupNameOrigianl isEqualToString:@""])
        {
            conv.strGroupName = strGroupNameOrigianl;
        }
        else
        {
            conv.strGroupName = strGroupName;
        }
    }
    
    return conv;
}


// Get lines from file as raw messages
+(NSArray*) getRawMessages:(NSURL*)urlPath
{
    // Get local file (for testing)
    NSString* content = [NSString stringWithContentsOfURL:urlPath encoding:NSUTF8StringEncoding error:NULL];
    
    // Create array with all raw meessages
    NSArray * arrayMessagesRaw = [content componentsSeparatedByString: kSeperatorBetweenlines];
    
    return arrayMessagesRaw;
}



// Parse messages from raw lines array
+(Conversation*) parseRawMessagesWithArray:(NSArray*) arrayMessagesRaw withConversation:(Conversation*)conv
{
    if (!conv)
        conv = [Conversation SQPCreateEntity];
    
    // Store previous message if needed
    NSString * strPreviousMessage = @"";
    Message * messagePrevious;
    BOOL isStartedBrokenMessage = false;
    
    // Parse all messages
    for (NSString * strLine in arrayMessagesRaw)
    {
        // Parse message
        Message * message = [Message strToMessage:strLine];
        
        // Everything is fine with message
        if (message)
        {
            // Handle broken message
            if (isStartedBrokenMessage)
            {
                // Combine messages all together
                messagePrevious.strMessage = [messagePrevious.strMessage stringByAppendingString:strPreviousMessage];
                
                // Broken message has ended
                isStartedBrokenMessage = false;
                strPreviousMessage = @"";
            }
            
            // Must be chronological
            if (message.date >= messagePrevious.date)
            {
                // Moving to the next message
                [conv addNewMessage:message];
                messagePrevious = message;
            }
            // Or else it's just a text inside our message
            // As if someone copied exported messages into his conversation
            else
            {
                // Combine messages all together
                messagePrevious.strMessage = [messagePrevious.strMessage stringByAppendingString:strLine];
            }
            
            
        }
        // Not a real message --> part of previous message
        else
        {
            // Started a broken message
            isStartedBrokenMessage = true;
            
            // Add parts of the message together
            strPreviousMessage = [strPreviousMessage stringByAppendingString:kSeperatorBetweenlines];
            strPreviousMessage = [strPreviousMessage stringByAppendingString:strLine];
        }
    }
    
    // One final check:
    // In the end we must make sure there are no broken messages in queue
    if (isStartedBrokenMessage)
    {
        // Combine messages all together
        messagePrevious.strMessage = [messagePrevious.strMessage stringByAppendingString:strPreviousMessage];
        
        // Broken message has ended
        isStartedBrokenMessage = false;
        strPreviousMessage = @"";
    }

    return conv;
}


@end
