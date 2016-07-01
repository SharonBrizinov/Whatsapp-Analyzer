//
//  AnalyzeData.h
//  WhatsappAnalyzer
//
//  Created by Sharon Brizinov on 15/10/2015.
//  Copyright © 2015 SBSoftware. All rights reserved.
//

#import "Globals.h"
@class Conversation;


@interface AnalyzeData : NSObject

// Parse messages into Conversation object from local file (mostly for testing)
+(Conversation*) parseMessagesFromLocalFileWithURL:(NSURL*)urlPath;
// Get lines from file as raw messages
+(NSArray*) getRawMessages:(NSURL*)urlPath;
// Parse messages from raw lines array
+(Conversation*) parseRawMessagesWithArray:(NSArray*) arrayMessagesRaw withConversation:(Conversation*)conv;
// Parse messages for an existing conversation object
+(Conversation*) parseMessagesFromExistingConversationObject:(Conversation*)conv;

@end
