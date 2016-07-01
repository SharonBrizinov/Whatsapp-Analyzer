//
//  Word.h
//  WhatsappAnalyzer
//
//  Created by Sharon Brizinov on 31/10/2015.
//  Copyright © 2015 SBSoftware. All rights reserved.
//

#import "Globals.h"

@interface Word : SQPObject
@property(nonatomic, retain) NSString   * strWord; // Category word
@property(nonatomic, retain) NSNumber   * numberIsSelected; // Is word selected ?
@end
