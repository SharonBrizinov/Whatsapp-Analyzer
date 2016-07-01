//
//  Conversation.m
//  WhatsappAnalyzer
//
//  Created by Sharon Brizinov on 15/10/2015.
//  Copyright © 2015 SBSoftware. All rights reserved.
//

#import "Conversation.h"

@implementation Conversation
@synthesize arrayMessages,arrayWAObjects,strGroupName, arrayWordAnalysisCategory;


- (id)init {
    self = [super init];
    if (self)
    {
        // Init all variables
        self.arrayMessages      = [[NSMutableArray alloc]init];
        self.strGroupName       = @"";
        self.arrayWAObjects     = [[NSMutableArray alloc]init];
        self.arrayWordAnalysisCategory     = [[NSMutableArray alloc]init];
    }
    return self;
}


- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[Conversation class]]) {
        return NO;
    }
    return [self.objectID isEqualToString:((Conversation*)object).objectID];
}


// Is the object parsed already
-(BOOL) isParsed
{
    return (self.arrayMessages && [self.arrayMessages count] != 0);
}
- (NSString *)description
{
    /* Generate statistcs from WAObjects */
    NSString * strWAObjectsStatistcs = @"";
    for (WAObject * w in self.arrayWAObjects)
    {
        strWAObjectsStatistcs = [strWAObjectsStatistcs stringByAppendingString: [w description]];
    }
    
    return [NSString stringWithFormat: @"\n=========\nFirst message: %@\n\n=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-\nComposerses Statistcs: %@\n=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-\n\nLast message: %@\n=========",
            [self.arrayMessages firstObject],
            strWAObjectsStatistcs,
            [self.arrayMessages lastObject]];
}




// Adding new message to array
-(void) addNewMessage:(Message*)message
{
    // Init
    if (!self.arrayMessages) {
        self.arrayMessages      = [[NSMutableArray alloc]init];
    }
    
    if (!self.arrayWAObjects) {
        self.arrayWAObjects      = [[NSMutableArray alloc]init];
    }
    
    // Add to messages array
    [self.arrayMessages addObject:message];
    
    // Check if we need to create new WAObject
    for(WAObject * w in self.arrayWAObjects)
    {
        if ([w.strComposer isEqualToString:message.strComposer])
        {
            // We are adding message to WAObject
            [w addNewMessage:message];
            
            // And we are done.
            return;
        }
    }
    
    
    // If we got here, it means there are no composers with our
    //      Message composer yet
    // Creating new WAObject and populate it
    WAObject * wao = [[WAObject alloc] init];
    wao.strComposer = message.strComposer;
    [wao addNewMessage:message];
    [self.arrayWAObjects addObject:wao];
}


// Get Chat Type
-(NSString*) getChatType
{
    if ([self.arrayWAObjects count] == kConversationTypePersonNumberOfParticipants)
    {
        return @"Single Person";
    }
    else
    {
        return @"Group Chat";
    }
}

// Get all composers
-(NSArray*) getAllComposersWithShouldIndicateYourseld:(BOOL)isIndicateYourself
{
    NSMutableArray * arrayComposers = [[NSMutableArray alloc] init];
    
    for (WAObject * w in self.arrayWAObjects)
    {
        if (isIndicateYourself && [w.strComposer isEqualToString:kGlobalUsername])
        {
            [arrayComposers addObject: @"You"];
        }
        else
        {
            [arrayComposers addObject: w.strComposer];
        }
        
    }
    return [arrayComposers copy];
}
-(NSArray*) getAllComposers
{
    return [self getAllComposersWithShouldIndicateYourseld:NO];
}


// How many times a person said a certin word
-(NSUInteger) getHowManyTimesItWasSaid:(NSString*)strWord forComposer:(NSString*)strComposer shouldInStringToBeIsolated:(BOOL)isIsolated shouldTrimWhitespacesFromBaseString:(BOOL)isTrimWhitespaces
{
    // Search for composer
    for (WAObject * w in self.arrayWAObjects) {
        if ([w.strComposer isEqualToString:strComposer])
        {
            return [w howManyTimeSaid:strWord shouldInStringToBeIsolated:isIsolated shouldTrimWhitespacesFromBaseString:isTrimWhitespaces];
        }
    }
    return 0;
}


// Get how many chars were written in chat all together
-(NSUInteger) getHowManyCharsInConversation
{
    NSUInteger count = 0;
    for (WAObject * w in self.arrayWAObjects)
    {
        count += w.numberLetterCountOfAllMessages.longLongValue;
    }
    
    return count;
}


// Return previous conversation if found. nil otherwise
+(NSMutableArray *)getPreviousConversations:(Conversation*)convCurrent
{
    // Same group name, but not same object..
    return [Conversation SQPFetchAllWhere:[NSString stringWithFormat:@"strGroupName = '%@' AND NOT (objectID = '%@')", convCurrent.strGroupName, convCurrent.objectID]];
}





#pragma mark - Statistcs for graphs

// Number of message each participants sent
// limit: All the items after 'limit' items will be counted as "Other"
// bMostMessages: Should return the most message or the fewest
// Returns dictionary with two DESC arrays (values, labels)
-(NSDictionary*)getGraphDataDESCOfNumberOfMessagesWithFewestMessages:(BOOL)bFewMessages withLimit:(int)limit
{
    /* Initialize variable */
    NSMutableDictionary * dict          = [[NSMutableDictionary alloc] init];
    NSMutableArray      * arrayValues   = [[NSMutableArray alloc] init];
    NSMutableArray      * arrayLabels   = [[NSMutableArray alloc] init];
    
    /* Sort (DESC) */
    // Must be DESC because of 'limit'
    //  Sort by: How many sent messages
    NSArray *sortedArray = [self.arrayWAObjects sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
    {
        WAObject * w1 = (WAObject*)obj1;
        WAObject * w2 = (WAObject*)obj2;
        if (bFewMessages)
            return w1.arrayMessages.count > w2.arrayMessages.count;
        else
            return w1.arrayMessages.count <= w2.arrayMessages.count;
    }];
    
    /* Add values */
    // Taking care of limited number of items
    int index = 1;
    NSNumber * numberSumFromLimit = @0;
    
    for (WAObject * w in sortedArray)
    {
        // Other
        if (index >= limit)
        {
            // Adding the rest of the data as 'Other'
            numberSumFromLimit = [NSNumber numberWithFloat:numberSumFromLimit.floatValue + w.arrayMessages.count];
        }
        // Regular
        else
        {
            // Adding regular values
            [arrayValues addObject:[NSNumber numberWithFloat:w.arrayMessages.count]];
            [arrayLabels addObject:w.strComposer];
        }
        // Adding index
        index++;
    }
    // Check if we reached the limit
    if (index > limit)
    {
        // If so add the value as "Other"
        [arrayValues addObject:numberSumFromLimit];
        [arrayLabels addObject:kConversationStatisticsLabelAfterLimit];
    }

    
    /* Set arrays to dictionary */
    [dict setObject:arrayLabels forKey: kConversationStatisticsLabels];
    [dict setObject:arrayValues forKey: kConversationStatisticsValues];
    
    /* Return */
    return dict;
}


// Number of times each word was said
// limit: All the items after 'limit' items will be counted as "Other"
// Returns dictionary with two DESC arrays (values, labels)
-(NSDictionary*)getGraphDataDESCOfHowManyTimesEachWordWasSaidWithArrayOfWords:(NSArray*)arrayWords withLimit:(int)limit
{
    /* Initialize variable */
    NSMutableDictionary * dict          = [[NSMutableDictionary alloc] init];
    NSMutableArray      * arrayValues   = [[NSMutableArray alloc] init];
    NSMutableArray      * arrayLabels   = [[NSMutableArray alloc] init];
    
    
    /* Add values */
    
    int index = 0;
    // For each word
    for (NSString * strWord in arrayWords)
    {
        [arrayValues addObject:@0];
        [arrayLabels addObject:strWord];
        
        // For each participants
        for (WAObject * w in self.arrayWAObjects)
        {
            arrayValues[index] = [NSNumber numberWithFloat: ((NSNumber*)arrayValues[index]).floatValue + [self getHowManyTimesItWasSaid:strWord forComposer:w.strComposer shouldInStringToBeIsolated:NO shouldTrimWhitespacesFromBaseString:YES]];
        }
        
        index ++;
      }

    
    /* Set arrays to dictionary */
    [dict setObject:arrayLabels forKey: kConversationStatisticsLabels];
    [dict setObject:arrayValues forKey: kConversationStatisticsValues];
    
    /* Return */
    return dict;
}


@end
