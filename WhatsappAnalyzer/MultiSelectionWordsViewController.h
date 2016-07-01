//
//  MultiSelectionViewController.h
//  STPopup
//
//  Created by Kevin Lin on 11/10/15.
//  Copyright © 2015 Sth4Me. All rights reserved.
//

#import "Globals.h"

@class MultiSelectionWordsViewController;
@class WordAnalysisCategory;

@protocol MultiSelectionWordsViewControllerDelegate <NSObject>

- (void)multiSelectionViewController:(MultiSelectionWordsViewController *)vc didFinishWithSelections:(NSArray *)selections;

@end

@interface MultiSelectionWordsViewController : UITableViewController

// Category
@property(nonatomic, strong) WordAnalysisCategory * category;
// Delegate
@property (nonatomic, weak) id<MultiSelectionWordsViewControllerDelegate> delegate;
@end
