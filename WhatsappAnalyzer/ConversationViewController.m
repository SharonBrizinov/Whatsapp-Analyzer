//
//  MasterViewController.m
//  WhatsappAnalyzer
//
//  Created by Sharon Brizinov on 14/10/2015.
//  Copyright © 2015 SBSoftware. All rights reserved.
//


#import "ConversationViewController.h"


/* Sections
 - (0)      Basic Information
 - (1..N)   Single Composer Statistics (X number of composers)
 - (N + 1)  Grpahs (Single/Multiple Type)
 */
#define kSectionBasicInformaion 0
#define kSection_MinimumSections 2

/* # of rows */
#define kSection_BasicInformaion_MaxRows 6
#define kSection_SingleComposer_MaxRows 4
#define kSection_GraphForMultiple_MaxRows 4
#define kSection_GraphForSingle_MinimumRows 1 // Edit button

/* # row - special rows */
#define kSection_GraphForSingle_RowNumber_EditButton 0



@interface ConversationViewController ()
@end

@implementation ConversationViewController
@synthesize conversation;

- (void)viewDidLoad
{    
    [super viewDidLoad];
    
    /* Design */
    self.view.backgroundColor = [UIColor gk_cloudsColor];
    self.title = self.conversation.strGroupName;

    // Add button
    UIBarButtonItem *changePositionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(changePositionScrollView:)];
    self.navigationItem.rightBarButtonItem = changePositionButton;
    
    /* Features */
    self.shouldCollapseDetailViewController = YES;
    self.isInEditMode = NO;

}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    
    
    /* Initialization */
    // If Conversation object is not fully parsed, now it's the time.
    if (![self.conversation isParsed])
    {
        self.conversation = [AnalyzeData parseMessagesFromExistingConversationObject:self.conversation];
    }
    else
    {
        // If we just came back from editintg, we need to save our work
        if (self.isInEditMode)
        {
            // Save all
            [self.conversation SQPSaveEntityWithCascade:YES];
            
            // Reload data
            [self.tableView reloadData];
            
            // After saving we need to quit edit mode
            self.isInEditMode = NO;
        }
    }
    self.nHowManyComposers = (int)[[self.conversation getAllComposers] count];
    self.isMultipleConversation = self.nHowManyComposers > kConversationTypePersonNumberOfParticipants;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];


    // Hide HUD
    [MBProgressHUD hideHUDForView: self.view animated:YES];
}




-(void) changePositionScrollView:(id)sender
{
    // If the scroll's position is more than half the tableview
    //  We will go up. Otherwise, we will scroll down all the way to the bottom.
    if (self.tableView.contentOffset.y  > (self.tableView.contentSize.height / 2))
    {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    else
    {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:(self.nHowManyComposers + 1)] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }

}
#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get current selected cell
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
    if ([[segue identifier] isEqualToString:kSegue_Show_Graph])
    {
        // Multiple Conversation
        // --> Bar Graphs
        if (self.isMultipleConversation)
        {
            // Get Navigation bar
            UINavigationController *navigationController = (UINavigationController *)[segue destinationViewController];
            
            // Prepare new VC
            GraphBarsViewController* controller = [[UIStoryboard storyboardWithName:kStoryBoard bundle:nil] instantiateViewControllerWithIdentifier: kStoryBoard_GraphForMultiple];
            
            // Data for graphs (array values, array labels)
            NSDictionary * dictData;
            
            switch (indexPath.row)
            {
                case 0:
                    dictData = [self.conversation getGraphDataDESCOfNumberOfMessagesWithFewestMessages:NO withLimit:kGraphBarsMaxRows];
                    controller.strGraphName = @"# of Messages (Bottom)";
                    controller.arrayDataValues = [[dictData valueForKey:kConversationStatisticsValues] mk_reverse];
                    controller.arrayDataLabels = [[dictData valueForKey:kConversationStatisticsLabels] mk_reverse];
                    
                    break;
                case 1:
                    dictData = [self.conversation getGraphDataDESCOfNumberOfMessagesWithFewestMessages:YES withLimit:kGraphBarsMaxRows];
                    controller.strGraphName = @"# of Messages (Top)";
                    controller.arrayDataValues = [[dictData valueForKey:kConversationStatisticsValues] mk_reverse];
                    controller.arrayDataLabels = [[dictData valueForKey:kConversationStatisticsLabels] mk_reverse];
                    
                    break;
                case 2:
                    dictData = [self.conversation getGraphDataDESCOfHowManyTimesEachWordWasSaidWithArrayOfWords:@[@"Cool",@"Awesome",@"Wow",@"Lol"] withLimit:kGraphBarsMaxRows];
                    controller.strGraphName = @"Cool";
                    controller.arrayDataValues = [dictData valueForKey:kConversationStatisticsValues];
                    controller.arrayDataLabels = [dictData valueForKey:kConversationStatisticsLabels];
                    controller.arrayDataColors = @[[UIColor gk_colorFromHexCode:@"7A4893"], [UIColor gk_colorFromHexCode:@"D27BFB"], [UIColor gk_midnightBlueColor], [UIColor gk_peterRiverColor]];
                    break;
                case kSection_GraphForMultiple_MaxRows - 1:
                    dictData = [self.conversation getGraphDataDESCOfHowManyTimesEachWordWasSaidWithArrayOfWords:@[@"Yo",@"Hey",@"Hi",@"Hello"] withLimit:kGraphBarsMaxRows];
                    controller.strGraphName = @"Hello";
                    controller.arrayDataValues = [dictData valueForKey:kConversationStatisticsValues];
                    controller.arrayDataLabels = [dictData valueForKey:kConversationStatisticsLabels];
                    controller.arrayDataColors = @[[UIColor gk_colorFromHexCode:@"D4A190"], [UIColor gk_colorFromHexCode:@"A1D490"], [UIColor gk_colorFromHexCode:@"90C3D4"], [UIColor gk_colorFromHexCode:@"217A2B"]];
                    break;
                default:
                    break;
            }

            
            // Set VC as root view controller of navigation controller
            [navigationController setViewControllers:@[controller] animated:NO];
        }

        // Single Person Conversation
        // --> Word Analysis
        else
        {
            /* Edit button only */
            if (indexPath.section == (self.nHowManyComposers + 1) && indexPath.row > 0)
            {
                // Get Navigation bar
                UINavigationController *navigationController = (UINavigationController *)[segue destinationViewController];
                
                // Prepare new VC
                GraphForTwoViewController* controller = [[UIStoryboard storyboardWithName:kStoryBoard bundle:nil] instantiateViewControllerWithIdentifier: kStoryBoard_GraphForTwo];
                controller.conversation = self.conversation;
                WordAnalysisCategory * category = (WordAnalysisCategory*)[self.conversation.arrayWordAnalysisCategory objectAtIndex:indexPath.row - 1];
                controller.category = category;
                
                // Set VC as root view controller of navigation controller
                [navigationController setViewControllers:@[controller] animated:NO];

            }
        }
    
        // Now we can open the detail view controller
        self.shouldCollapseDetailViewController = NO;
    }
    

    else
    {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        // Collpase = Don't go to detail view controller if user rotates the screen
        self.shouldCollapseDetailViewController = YES;
    }
}

#pragma mark - Table View


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return kSection_MinimumSections + self.nHowManyComposers;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    /* Basic Info - General information about the whole conversation */
    if (section == kSectionBasicInformaion)
    {
        return kSection_BasicInformaion_MaxRows;
    }
    /* Person Info - specific information about each participants in conversation */
    else if (self.nHowManyComposers >= section)
    {
        return kSection_SingleComposer_MaxRows;
    }
    /* Graphs view */
    else if (section == self.nHowManyComposers + 1)
    {
        // Multiple Conversation
        // --> Bar Graphs
        if (self.isMultipleConversation)
        {
            return kSection_GraphForMultiple_MaxRows;
        }
        else
        {
            // Single Person Conversation
            // --> Word Analysis
            // First  - "Edit" button, then all categories
            return kSection_GraphForSingle_MinimumRows + [self.conversation.arrayWordAnalysisCategory count];
        }
        
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    /* Basic Info - General information about the whole conversation */
    if (section == kSectionBasicInformaion)
    {
        return @"Basic Info";
    }
    /* Person Info - specific information about each participants in conversation */
    else if (self.nHowManyComposers >= section)
    {
        return [self.conversation getAllComposersWithShouldIndicateYourseld:YES][section - 1];
    }
    /* Graphs view */
    else if (section == self.nHowManyComposers + 1)
    {
        // Multiple Conversation
        // --> Bar Graphs
        if (self.isMultipleConversation)
        {
            return @"Graphs";
        }
        // Single Person Conversation
        // --> Word Analysis
        else
        {
           return @"Word analysis";
        }
        
    }
    return @"";
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /* Variables for displaying alerts */
    UIAlertController* alert;
    NSString * strParticipants;
    
    switch (indexPath.section)
    {
        case 0: // Basic info
            switch (indexPath.row)
            {
                case 0: // Participants
                    
                    // Alert with all participatns
                    strParticipants = [[self.conversation getAllComposersWithShouldIndicateYourseld:YES] componentsJoinedByString:@", "];
                    alert = [UIAlertController alertControllerWithTitle:@"Participants" message: strParticipants preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                          handler:^(UIAlertAction * action) {}];
                    
                    [alert addAction:defaultAction];
                    [self presentViewController:alert animated:YES completion:nil];
                    break;
            }
            break;

        default:
            break;
    }

    
    /* Graphs views */
    if (indexPath.section == (self.nHowManyComposers + 1))
    {
        // Multiple Conversation
        // --> Bar Graphs
        if (self.isMultipleConversation)
        {
            // DO NOTHING
        }
        
        // Single Person Conversation
        // --> Word Analysis
        else
        {
            if (indexPath.row == kSection_GraphForSingle_RowNumber_EditButton)
            {
                // Edit categories
                [self editWordAnalysisCategories:nil];
                
                // Deselect
                [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
        }
    }
    // Basic + Participants - Deselect row if it's not word-analysis group
    else
    {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    
    // Date formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterLongStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    
    /* Basic Info - General information about the whole conversation */
    if (indexPath.section == kSectionBasicInformaion)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:kCellID_Basic forIndexPath:indexPath];
    
        switch (indexPath.row)
        {
            case 0:
                cell.textLabel.text = @"Participants";
                cell.detailTextLabel.text = [[self.conversation getAllComposersWithShouldIndicateYourseld:YES] componentsJoinedByString:@", "];
                break;
            case 1:
                cell.textLabel.text = @"Chat Type";
                cell.detailTextLabel.text = [self.conversation getChatType];
                break;
            case 2:
                cell.textLabel.text = @"Total Messages";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu Messages", (unsigned long)self.conversation.arrayMessages.count];
                break;
            case 3:
                cell.textLabel.text = @"Total Letters";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu Letters", (unsigned long)[self.conversation getHowManyCharsInConversation]];
                break;
            case 4:
                cell.textLabel.text = @"First Msg";
                cell.detailTextLabel.text = [dateFormatter stringFromDate: ((Message*)[self.conversation.arrayMessages firstObject]).date];
                break;
            case 5:
                cell.textLabel.text = @"Last Msg";
                cell.detailTextLabel.text = [dateFormatter stringFromDate: ((Message*)[self.conversation.arrayMessages lastObject]).date];
                break;
            default:
                break;
        }
        cell.editingAccessoryType = UITableViewCellEditingStyleNone;
    }
    /* Person Info - specific information about each participants in conversation */
    else if (self.nHowManyComposers >= indexPath.section)
    {
        // Get the current object <==> current person in conversation
        WAObject* waObjectCurrent = ((WAObject*)self.conversation.arrayWAObjects[indexPath.section - 1]);
        switch (indexPath.row)
        {
            case 0:
                cell = [tableView dequeueReusableCellWithIdentifier:kCellID_Basic forIndexPath:indexPath];
                cell.textLabel.text = @"# of Messages";
                NSUInteger nNumberOfMessages = waObjectCurrent.arrayMessages.count;
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu (%02.2f%%)",(unsigned long)nNumberOfMessages, ( (float) nNumberOfMessages / (float)self.conversation.arrayMessages.count) * 100 ];
                break;
            case 1:
                cell = [tableView dequeueReusableCellWithIdentifier:kCellID_Basic forIndexPath:indexPath];
                cell.textLabel.text = @"# of Letters";
                NSUInteger nNumberOfChars = waObjectCurrent.numberLetterCountOfAllMessages.unsignedLongValue;
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu (%02.2f%%)",(unsigned long)nNumberOfChars, ( (float) nNumberOfChars / (float)[self.conversation getHowManyCharsInConversation]) * 100 ];
                break;
            case 2:
                cell = [tableView dequeueReusableCellWithIdentifier:kCellID_Basic forIndexPath:indexPath];
                cell.textLabel.text = @"Shortest Message";
                cell.detailTextLabel.text = waObjectCurrent.messageShortest.strMessage;
                break;
            case 3:
                cell = [tableView dequeueReusableCellWithIdentifier:kCellID_Message forIndexPath:indexPath];
                cell.textLabel.text = @"Longest Message";
                
                UITextView * tx = (UITextView*)[cell viewWithTag:1001];
                tx.text = waObjectCurrent.messageLongest.strMessage;
                break;
        }
    }

    /* Graphs view */
    else if (indexPath.section == self.nHowManyComposers + 1)
    {
        // Multiple Conversation
        // --> Bar Graphs
        if(self.isMultipleConversation)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:kCellID_Graph forIndexPath:indexPath];
            switch (indexPath.row)
            {
                case 0:
                    cell.textLabel.text = @"# of Messages (Top)";
                    break;
                case 1:
                    cell.textLabel.text = @"# of Messages (Bottom)";
                    break;
                case 2:
                    cell.textLabel.text = @"Words Analysis 1";
                    break;
                case kSection_GraphForMultiple_MaxRows - 1: //3
                    cell.textLabel.text = @"Words Analysis 2";
                    break;
                default:
                    break;
            }
            
        }
        // Single Person Conversation
        // --> Word Analysis
        else
        {
            // If the first row --> edit
            if (indexPath.row == kSection_GraphForSingle_RowNumber_EditButton)
            {
                cell = [tableView dequeueReusableCellWithIdentifier:kCellID_BasicEdit forIndexPath:indexPath];
                cell.textLabel.text = @"Edit";
            }
            else
            {
                cell = [tableView dequeueReusableCellWithIdentifier:kCellID_Graph forIndexPath:indexPath];
                WordAnalysisCategory * category = (WordAnalysisCategory*)[self.conversation.arrayWordAnalysisCategory objectAtIndex:indexPath.row - 1];
                cell.textLabel.text = category.strName;
            }
        }
    }
    
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
 
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}




#pragma mark - View - Button actions

-(IBAction)closeView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)editWordAnalysisCategories:(id)sender
{
    // Prepare view controller
    BottomSheetCategorySelectorViewController* vc = [[UIStoryboard storyboardWithName:kStoryBoard bundle:nil] instantiateViewControllerWithIdentifier: kStoryBoard_Categories];
    vc.arrayWordAnalysisCategory = self.conversation.arrayWordAnalysisCategory;

    // Prepare STPopup with previous vc
    STPopupController *popupController = [[STPopupController alloc] initWithRootViewController: vc];
    popupController.style = STPopupStyleBottomSheet;

    // Present
    [popupController presentInViewController:self completion:^{

        // Now we are in edit mode
        self.isInEditMode = YES;
    }];
}




#pragma mark - Split view

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController
{
    
    return self.shouldCollapseDetailViewController;

}

@end
