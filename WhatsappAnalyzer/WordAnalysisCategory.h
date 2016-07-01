//
//  WordAnalysisCategory.h
//  WhatsappAnalyzer
//
//  Created by Sharon Brizinov on 31/10/2015.
//  Copyright © 2015 SBSoftware. All rights reserved.
//

#import "Globals.h"

@interface WordAnalysisCategory : SQPObject

@property(nonatomic, retain) NSString   * strName; // Category name
@property(nonatomic, retain) NSString   * strDescription; // Description
@property(nonatomic, retain) NSNumber   * numberInnerSearch; // Should do inner search for words
@property(nonatomic, retain) NSNumber   * numberIsSelected; // Is category selected ?
@property(nonatomic, retain) NSMutableArray<SQPObject *>* arrayWord; // Category name
@property(nonatomic, retain) NSMutableArray<SQPObject *>* arrayTag; // Category name



// Get all default categories which comes with app
+(NSMutableArray*)getDefaultWordAnalysisCategories;

// Get all selected words as array of words
-(NSArray*)getAllSelectedWords;
@end
