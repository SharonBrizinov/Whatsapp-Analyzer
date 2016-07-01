//
//  WAObject.m
//  WhatsappAnalyzer
//
//  Created by Sharon Brizinov on 15/10/2015.
//  Copyright © 2015 SBSoftware. All rights reserved.
//

#import "WAObject.h"

@implementation WAObject
@synthesize strComposer, arrayMessages, messageLongest, messageShortest, numberLongestMessageLength, numberShortestMessageLength, numberLetterCountOfAllMessages;

- (id)init {
    self = [super init];
    if (self)
    {
        // Init all variables
        self.arrayMessages                  = [[NSMutableArray alloc]init];
        self.strComposer                    = @"";
        self.numberShortestMessageLength    = @UINT64_MAX;
        self.numberLongestMessageLength     = @0;
        self.numberLetterCountOfAllMessages = @0;
    }
    return self;
}

- (NSString *)description
{
    /* Generate statistcs from WAObjects */
    return [NSString stringWithFormat: @"Composer's name: %@ | How many messages: %lu | Longest Message: %@ | Shortest Message: %@\n",
            self.strComposer,
            (unsigned long)[self.arrayMessages count],
            self.messageLongest,
            self.messageShortest];
}




// Add new message to composer's messages array
-(void) addNewMessage:(Message*)message
{
    /* This message was written by the same composer, adding to its array */
    [self.arrayMessages addObject:message];
    
    /* Check statistcs */
    [self updateStatisticsWithMessage: message];
    
}

// Update composer statistcs
-(void) updateStatisticsWithMessage:(Message*)message
{
    /* Longest message */
    if (message.strMessage.length > self.numberLongestMessageLength.unsignedIntegerValue)
    {
        self.messageLongest = message;
        self.numberLongestMessageLength = [NSNumber numberWithUnsignedLong:message.strMessage.length];
    }
    /* Shortest message */
    else if (message.strMessage.length < self.numberShortestMessageLength.unsignedIntegerValue)
    {
        self.messageShortest = message;
        self.numberShortestMessageLength = [NSNumber numberWithUnsignedLong:message.strMessage.length];
    }
    
    
    // Change letter count
    self.numberLetterCountOfAllMessages = [NSNumber numberWithLongLong:(self.numberLetterCountOfAllMessages.longLongValue + message.strMessage.length)];
}




// Statistcs --> How many times person said certin word in all of his messages
//      isIsolated: True if the word canno't be inside of antoher word
-(NSUInteger) howManyTimeSaid:(NSString*)strWord shouldInStringToBeIsolated:(BOOL)isIsolated shouldTrimWhitespacesFromBaseString:(BOOL)isTrimWhitespaces
{
    NSUInteger howManyTimes = 0;
    
    // Going through all messages
    for (Message * m in self.arrayMessages)
    {
        howManyTimes += [GlobalManager howManyTimesSubtringInString:m.strMessage withSubString:strWord shouldInStringToBeIsolated:isIsolated shouldTrimWhitespacesFromBaseString:isTrimWhitespaces];
    }
    
    return howManyTimes;
}

@end
