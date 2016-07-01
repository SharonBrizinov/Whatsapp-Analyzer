//
//  Message.h
//  WhatsappAnalyzer
//
//  Created by Sharon Brizinov on 14/10/2015.
//  Copyright © 2015 SBSoftware. All rights reserved.
//

#import "Globals.h"


@interface Message : NSObject

@property(nonatomic, retain) NSString   * strComposer;
@property(nonatomic, retain) NSString   * strMessage;
@property(nonatomic, retain) NSDate     * date;

/* Get message line in format of:
    -->    06.3.2015, 15:14:41: Sharon B: asd1
 And returns Message object or nil if the format is wrong
 */
+ (Message*) strToMessage:(NSString*)strMessage;

@end
