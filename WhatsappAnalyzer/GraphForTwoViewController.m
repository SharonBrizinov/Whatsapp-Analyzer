//
//  DetailViewController.m
//  WhatsappAnalyzer
//
//  Created by Sharon Brizinov on 14/10/2015.
//  Copyright © 2015 SBSoftware. All rights reserved.
//

#import "GraphForTwoViewController.h"

@interface GraphForTwoViewController ()

@end

@implementation GraphForTwoViewController
@synthesize category, conversation, lgFlapJackStackView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /* Design */
    self.view.backgroundColor = [UIColor gk_cloudsColor];
    self.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
    self.navigationItem.leftItemsSupplementBackButton = YES;
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editWords:)];
    self.navigationItem.rightBarButtonItem = editButton;
    
    // View's title
    self.navigationItem.title = [NSString stringWithFormat:@"%@ (%@)",self.category.strName, self.category.numberInnerSearch.boolValue?@"Inner Search":@"Isolated Search"];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Show loading HUD
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    // If we don't have any data to work with, we will present nice lable
    //      saying that "No data is available!"
    
    if (self.conversation)
    {
        // We have data, Hide lable
        [self.lblNoDataYet setHidden:YES];
        
        // Show graph
        [self prepareGraphForDisplay];
    }
    else
    {
        // Show text lable
        [self.lblNoDataYet setHidden:NO];
        // Stop loading animation HUD
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }

}


-(void) editWords:(id)sender
{
    // Prepare view controller
    MultiSelectionWordsViewController* vc = [[UIStoryboard storyboardWithName:kStoryBoard bundle:nil] instantiateViewControllerWithIdentifier: kStoryBoard_Words];
    vc.category = self.category;
    
    // Prepare STPopup with previous vc
    STPopupController *popupController = [[STPopupController alloc] initWithRootViewController: vc];
    popupController.style = STPopupStyleBottomSheet;
    
    // Present
    [popupController presentInViewController:self completion:^{
    }];
}


#pragma mark - Graph

-(void) prepareGraphForDisplay
{
    if(self.lgFlapJackStackView)
    {
        // If graph was loaded, we will re-present it
        [self.lgFlapJackStackView removeFromSuperview];
    }
    
    
    // left     = top
    // right    = bottom
    
    NSMutableArray*flapJacks = [NSMutableArray new];
    for (Word * w in [self.category getAllSelectedWords])
    {
        LGFlapJack *flapJack = [LGFlapJack new];
        
        NSUInteger howMnayTimesSaidLeft = [self.conversation getHowManyTimesItWasSaid:w.strWord forComposer:[self.conversation getAllComposers][0] shouldInStringToBeIsolated:!self.category.numberInnerSearch.boolValue shouldTrimWhitespacesFromBaseString:YES];
        NSUInteger howMnayTimesSaidRight = [self.conversation getHowManyTimesItWasSaid:w.strWord forComposer:[self.conversation getAllComposers][1] shouldInStringToBeIsolated:!self.category.numberInnerSearch.boolValue shouldTrimWhitespacesFromBaseString:YES];
        
        flapJack.leftBarTotal = [NSNumber numberWithUnsignedInteger: howMnayTimesSaidLeft];
        flapJack.rightBarTotal = [NSNumber numberWithUnsignedInteger:howMnayTimesSaidRight];
        
        flapJack.leftBarColor = [UIColor colorWithRed:17/255. green:159/255. blue:194/255. alpha:1.0];
        flapJack.rightBarColor = [UIColor colorWithRed:206/255. green:218/255. blue:60/255. alpha:1.0];
        flapJack.inlineString = [NSString stringWithFormat:@"%@ (%lu)",w.strWord, (unsigned long)howMnayTimesSaidLeft + howMnayTimesSaidRight];
        [flapJacks addObject:flapJack];
    }
    
    
    self.lgFlapJackStackView = [[LGFlapJackStackView alloc]initWithFrame: CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y + self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - self.navigationController.navigationBar.frame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height)];
    self.lgFlapJackStackView.flapJacks = flapJacks;
    self.lgFlapJackStackView.flapJackHeight = 42;
    self.lgFlapJackStackView.barLabelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    self.lgFlapJackStackView.barLabelTextColor = [UIColor colorWithRed:85/255. green:85/255. blue:85/255. alpha:1.0];
    self.lgFlapJackStackView.inlineLabelFont =  [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    self.lgFlapJackStackView.inlineLabelTextColor = [UIColor colorWithRed:100/255. green:100/255. blue:100/255. alpha:1.0];
    self.lgFlapJackStackView.tableFooterView = [self sampleFooterView];
    
    
    //Name of the graph to be shown in email attachements.
    self.lgFlapJackStackView.name = @"lukegeiger";
    
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(exportGraphWasPressed)];
    //self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:17/255. green:159/255. blue:194/255. alpha:1.0];
    
    [self.view addSubview:self.lgFlapJackStackView];
    
    
    // Stop loading animation HUD
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
-(UIView*)sampleFooterView{
    
    UIView*footer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 115)];
    
    UIView*topCircle = [[UIView alloc]initWithFrame:CGRectMake(10, 5, 40, 40)];
    topCircle.backgroundColor = [UIColor colorWithRed:17/255. green:159/255. blue:194/255. alpha:1.0];
    topCircle.layer.cornerRadius = 20;
    topCircle.clipsToBounds = YES;
    [footer addSubview:topCircle];
    
    UIView*botomCircle = [[UIView alloc]initWithFrame:CGRectMake(10, 50, 40, 40)];
    botomCircle.backgroundColor = [UIColor colorWithRed:206/255. green:218/255. blue:60/255. alpha:1.0];
    botomCircle.layer.cornerRadius = 20;
    botomCircle.clipsToBounds = YES;
    [footer addSubview:botomCircle];
    
    UILabel*topLabel = [[UILabel alloc]initWithFrame:CGRectMake(topCircle.frame.origin.x+topCircle.frame.size.width+5, topCircle.frame.origin.y, 200, 40)];
    topLabel.backgroundColor = [UIColor clearColor];
    topLabel.textAlignment = NSTextAlignmentLeft;
    topLabel.text = [self.conversation getAllComposers][0];
    topLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    [footer addSubview:topLabel];
    
    UILabel*bottomLabel = [[UILabel alloc]initWithFrame:CGRectMake(topLabel.frame.origin.x, botomCircle.frame.origin.y, 200, 40)];
    bottomLabel.backgroundColor = [UIColor clearColor];
    bottomLabel.textAlignment = NSTextAlignmentLeft;
    bottomLabel.text = [self.conversation getAllComposers][1];
    bottomLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    [footer addSubview:bottomLabel];
    
    return footer;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
