//
//  Message.m
//  WhatsappAnalyzer
//
//  Created by Sharon Brizinov on 14/10/2015.
//  Copyright © 2015 SBSoftware. All rights reserved.
//

#import "Message.h"

@implementation Message
@synthesize strComposer, strMessage, date;


/* Get message line in format of:
 -->    06.3.2015, 15:14:41: Sharon B: asd1
 And returns Message object or nil if the format is wrong
 */
+ (Message*) strToMessage:(NSString*)strMessageAll
{
    // Break into components
    NSArray * arrayMessageComponents = [strMessageAll componentsSeparatedByString: kSeperatorInlineMessage];
    
    // Should be at least --> "Date: Composer: Message"
    if ([arrayMessageComponents count] < 3)
        return nil;
    
    
    // Date formatter
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat: kDateFormat];
    NSDateFormatter *dateFormater2 = [[NSDateFormatter alloc] init];
    [dateFormater2 setDateFormat: kDateFormat2];
    
    NSString   * strComposer;
    NSString   * strMessage;
    NSDate     * date;
    
    // Try to parse
    @try
    {
        // Date
        NSString * strDate     = arrayMessageComponents[0];
        date   = [dateFormater dateFromString:strDate];
        if (!date) // let's try again
            date   = [dateFormater2 dateFromString:strDate];
        
        // Composer
        strComposer = arrayMessageComponents[1];
        
        // Message (with previos message (if needed))
        strMessage  = arrayMessageComponents[2];
        // Maybe there are more seperators in message string (e.g: ": ")
        // Let's combine them all together
        if ([arrayMessageComponents count] > 3)
        {
            // We need to merge the rest of the strings
            for (unsigned indexInnerMessage = 3; indexInnerMessage < [arrayMessageComponents count]; indexInnerMessage++)
            {
                strMessage = [strMessage stringByAppendingString: kSeperatorInlineMessage];
                strMessage = [strMessage stringByAppendingString:arrayMessageComponents[indexInnerMessage]];
            }
        }
    }
    @catch (NSException *exception)
    {
        // We are in the middle of previous message, should continue collect the rest of the message
        if (exception.name == NSRangeException)
        {
            return nil;
        }
    }
    
    // Create new Message object
    Message * message = [[Message alloc] init];
    message.date = date;
    message.strComposer = strComposer;
    message.strMessage = strMessage;
    
    return message;
}

/* // ORIGINAL
+ (Message*) strToMessage:(NSString*)strMessageAll
{
    // Break into components
    NSArray * arrayMessageComponents = [strMessageAll componentsSeparatedByString: kSeperatorInlineMessage];
    
    // Should be at least --> "Date: Composer: Message"
    if ([arrayMessageComponents count] < 3)
        return nil;
    
    
    // Date formatter
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat: kDateFormat];
    
    NSString   * strComposer;
    NSString   * strMessage;
    NSDate     * date;
    
    // Try to parse
    @try
    {
        // Date
        NSString * strDate     = arrayMessageComponents[0];
        date   = [dateFormater dateFromString:strDate];
        
        // Composer
        strComposer = arrayMessageComponents[1];
        
        // Message (with previos message (if needed))
        strMessage  = arrayMessageComponents[2];
        // Maybe there are more seperators in message string (e.g: ": ")
        // Let's combine them all together
        if ([arrayMessageComponents count] > 3)
        {
            // We need to merge the rest of the strings
            for (unsigned indexInnerMessage = 3; indexInnerMessage < [arrayMessageComponents count]; indexInnerMessage++)
            {
                strMessage = [strMessage stringByAppendingString: kSeperatorInlineMessage];
                strMessage = [strMessage stringByAppendingString:arrayMessageComponents[indexInnerMessage]];
            }
        }
    }
    @catch (NSException *exception)
    {
        // We are in the middle of previous message, should continue collect the rest of the message
        if (exception.name == NSRangeException)
        {
            return nil;
        }
    }
    
    // Create new Message object
    Message * message = [[Message alloc] init];
    message.date = date;
    message.strComposer = strComposer;
    message.strMessage = strMessage;
    
    return message;
}
*/

- (NSString *)description
{
    return [NSString stringWithFormat: @"\n-------------\nDate: %@ | Composer: %@ | Message: %@\n-------------",
                        self.date,
                        self.strComposer,
                        self.strMessage];
}


@end
