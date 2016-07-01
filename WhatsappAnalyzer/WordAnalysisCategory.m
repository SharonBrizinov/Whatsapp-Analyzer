//
//  WordAnalysisCategory.m
//  WhatsappAnalyzer
//
//  Created by Sharon Brizinov on 31/10/2015.
//  Copyright © 2015 SBSoftware. All rights reserved.
//

#import "WordAnalysisCategory.h"

@implementation WordAnalysisCategory
@synthesize strName, arrayTag, arrayWord;

- (id)init {
    self = [super init];
    if (self)
    {
        // Init all variables
        self.arrayTag                  = [[NSMutableArray alloc]init];
        self.arrayWord                 = [[NSMutableArray alloc]init];
    }
    return self;
}


// Add single new tag
-(void)addNewTag:(NSString*)strTagNew
{
    [self addListOfWords:@[strTagNew]];
}
// Add list of new tags
-(void)addListOfTags:(NSArray*)arrayTagsNew
{
    for (NSString * tag in arrayTagsNew)
    {
        // Create new object
        Tag * t = [Tag SQPCreateEntity];
        // Set with data
        t.strTag = tag;
        // Add to array
        [self.arrayTag addObject:t];
    }
}

// Add single new word
-(void)addNewWord:(NSString*)strWordNew
{
    [self addListOfWords:@[strWordNew]];
}
// Add list of new words
-(void)addListOfWords:(NSArray*)arrayWordsNew
{
    for (NSString * word in arrayWordsNew)
    {
        // Create new object
        Word * w = [Word SQPCreateEntity];
        // Set with data
        w.strWord = word;
        w.numberIsSelected = @YES;
        // Add to array
        [self.arrayWord addObject:w];
    }
}


// Get all default categories which comes with app
+(NSMutableArray*)getDefaultWordAnalysisCategories
{
    // Prepare list for categories
    NSMutableArray * arrayCategories = [[NSMutableArray alloc]init];
    
    // Get Defualt categories
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:kWordAnalysisFileName ofType: kWordAnalysisFileFormat];
    NSDictionary * rootDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    // From dictionary to object
    for (NSString * key in [rootDictionary allKeys])
    {
        // Create new object
        WordAnalysisCategory * wordAnalysisCategory = [WordAnalysisCategory SQPCreateEntity];
        
        // Get current category
        NSDictionary * dictCategory = [rootDictionary objectForKey:key];
        wordAnalysisCategory.strName = [dictCategory objectForKey:kWordAnalysisFileKeyName_Name]; //category name
        wordAnalysisCategory.strDescription = [dictCategory objectForKey:kWordAnalysisFileKeyName_Description]; // description
        wordAnalysisCategory.numberInnerSearch = [dictCategory objectForKey:kWordAnalysisFileKeyName_InnerSearch]; // Should perform inner search
        wordAnalysisCategory.numberIsSelected = @YES;
        [wordAnalysisCategory addListOfWords: [dictCategory objectForKey:kWordAnalysisFileKeyName_Words]]; //words
        [wordAnalysisCategory addListOfTags: [dictCategory objectForKey:kWordAnalysisFileKeyName_Tags]]; //tags

        // Add to array
        [arrayCategories addObject:wordAnalysisCategory];
        [wordAnalysisCategory SQPSaveEntityWithCascade:YES]; // Important: Save before assigning to Conversation object
    }
    
    return arrayCategories;
}



// Get all selected words as array of words
-(NSArray*)getAllSelectedWords
{
    NSIndexSet *idxSetOfStrings = [self.arrayWord indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return ((Word*)obj).numberIsSelected.boolValue; // is selected
    }];
    
    return [self.arrayWord objectsAtIndexes:idxSetOfStrings];
}


@end
