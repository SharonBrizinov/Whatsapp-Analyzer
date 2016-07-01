//
//  WAObject.h
//  WhatsappAnalyzer
//
//  Created by Sharon Brizinov on 15/10/2015.
//  Copyright © 2015 SBSoftware. All rights reserved.
//
#import "Globals.h"
@class Message;


@interface WAObject : NSObject

@property(nonatomic, retain) NSString           * strComposer;           // Composer Name
@property(nonatomic, retain) NSMutableArray     * arrayMessages;         // Messages of composer
@property(nonatomic, retain) NSNumber   * numberLetterCountOfAllMessages;// How many chars were written in total

// Statistics
@property(nonatomic, retain) Message    * messageLongest;               // The longest message
@property(nonatomic, retain) NSNumber   * numberLongestMessageLength;

@property(nonatomic, retain) Message    * messageShortest;              // The shortests message
@property(nonatomic, retain) NSNumber   * numberShortestMessageLength;




// Add new message to composer's messages array
-(void) addNewMessage:(Message*)message;


// Statistcs --> How many times person said certin word in all of his messages
//      isIsolated: True if the word canno't be inside of antoher word
-(NSUInteger) howManyTimeSaid:(NSString*)strWord shouldInStringToBeIsolated:(BOOL)isIsolated shouldTrimWhitespacesFromBaseString:(BOOL)isTrimWhitespaces;

@end
