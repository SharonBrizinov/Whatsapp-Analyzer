//
//  DetailViewController.h
//  WhatsappAnalyzer
//
//  Created by Sharon Brizinov on 14/10/2015.
//  Copyright © 2015 SBSoftware. All rights reserved.
//


#import "Globals.h"
@class WordAnalysisCategory;


@interface GraphForTwoViewController : UIViewController

// Graph view
@property (nonatomic, strong) LGFlapJackStackView   * lgFlapJackStackView;

@property (nonatomic, strong) IBOutlet UILabel               * lblNoDataYet;




// Category
@property(nonatomic, strong) WordAnalysisCategory * category;
// Conversation
@property (nonatomic, strong) Conversation          * conversation;
@end

