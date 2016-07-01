//
//  BottomSheetDemoViewController.m
//  STPopup
//
//  Created by Kevin Lin on 11/10/15.
//  Copyright © 2015 Sth4Me. All rights reserved.
//

#import "BottomSheetCategorySelectorViewController.h"

@interface BottomSheetDemoSelectionCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UILabel *placeholderLabel;
@property (nonatomic, strong) NSArray * buttons; // scrollview button

@end

@implementation BottomSheetDemoSelectionCell
{
}

- (void)setSelections:(NSArray *)selections
{
    //selections = [selections sortedArrayUsingSelector:@selector(localizedCompare:)];
    [self.buttons makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.placeholderLabel.hidden = selections.count > 0;
    
    CGFloat buttonX = 15;
    NSMutableArray *buttonsNew = [NSMutableArray new];
    for (Word *selection in selections) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.layer.cornerRadius = 4;
        button.backgroundColor = button.tintColor;
        button.contentEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 10);
        [button setTitle:selection.strWord forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button sizeToFit];
        button.frame = CGRectMake(buttonX, (self.scrollView.frame.size.height - button.frame.size.height) / 2, button.frame.size.width, button.frame.size.height);
        
        [buttonsNew addObject:button];
        [self.scrollView addSubview:button];
        
        buttonX += button.frame.size.width + 10;
    }
    self.scrollView.contentSize = CGSizeMake(buttonX, self.scrollView.frame.size.height);
    
    self.buttons = [NSArray arrayWithArray:buttonsNew];
}
@end




#pragma mark - BottomSheetCategorySelectorViewController with delegate

@interface BottomSheetCategorySelectorViewController () <MultiSelectionWordsViewControllerDelegate>
@end

@implementation BottomSheetCategorySelectorViewController
@synthesize arrayWordAnalysisCategory;

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.contentSizeInPopup = CGSizeMake([UIScreen mainScreen].bounds.size.width, 180);
    self.landscapeContentSizeInPopup = CGSizeMake([UIScreen mainScreen].bounds.size.height, 180);
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    /* Design */
    self.view.backgroundColor = [UIColor gk_cloudsColor];
    self.title = @"Category Selection";
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewCategoryAlert:)];
    self.navigationItem.rightBarButtonItem = addButton;
    

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Refresh
    [self.tableView reloadData];
}



// @NOTE: Not in use
- (void)multiSelectionViewController:(MultiSelectionWordsViewController *)vc didFinishWithSelections:(NSArray *)selections
{
    // Reload table
    [self.tableView reloadData];
}




// Add new category with name
-(void) addNewCategoryWithString:(NSString*)strCategoryName
{
    // We won't add empty names of categories
    if (strCategoryName && ![strCategoryName isEqualToString:@""])
    {
        // Create new object + populate
        WordAnalysisCategory * wac = [WordAnalysisCategory SQPCreateEntity];
        wac.strName = strCategoryName;
        wac.numberIsSelected = @YES;    // Default values
        wac.numberInnerSearch = @YES;  // Default values
        [wac SQPSaveEntityWithCascade:YES];
        
        // Add to array
        [self.arrayWordAnalysisCategory addObject:wac];
        
        // Add to tableview
        [self.tableView reloadData];
        
        // Scroll down
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.arrayWordAnalysisCategory count]-1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}


-(void) addNewCategoryAlert:(id)sender
{
    // Show alert asking for new category
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"New Category" message: @"" preferredStyle:UIAlertControllerStyleAlert];
    
    // Add new text field for category name
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = NSLocalizedString(@"Category", @"Category");
    }];

    // Cancel button
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    // Add button
    UIAlertAction* addAction = [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action){
                                        
                                        // Get the text field
                                        UITextField *txtfieldCategory = alert.textFields.firstObject;
                                        
                                        // Category's name
                                        [self addNewCategoryWithString:txtfieldCategory.text];
                                                          }];
    
    [alert addAction:cancelAction];
    [alert addAction:addAction];
    [self presentViewController:alert animated:YES completion:nil];
}



#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.arrayWordAnalysisCategory count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    BottomSheetDemoSelectionCell *selectionCell = (BottomSheetDemoSelectionCell *)[tableView dequeueReusableCellWithIdentifier:kCellID_CategoryScrollView];
    return selectionCell.scrollView.frame.size.height;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    BottomSheetDemoSelectionCell *selectionCell = (BottomSheetDemoSelectionCell *)[tableView dequeueReusableCellWithIdentifier:kCellID_CategoryScrollView];
    
    // Get all selected words from all categories
    NSMutableArray * arrayWordSelections = [NSMutableArray new];
    for (WordAnalysisCategory * wac in self.arrayWordAnalysisCategory)
    {
        [arrayWordSelections addObjectsFromArray:[wac getAllSelectedWords]];
    }
    [selectionCell setSelections:arrayWordSelections];
    
    return selectionCell;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kCellID_Category forIndexPath:indexPath];
       
    // Word Analysis object
    WordAnalysisCategory * wac = [self.arrayWordAnalysisCategory objectAtIndex:indexPath.row];
   
    // Populate cell with data
    cell.textLabel.text = wac.strName;
    cell.detailTextLabel.text = wac.strDescription;
    
    
    return cell;
}


-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Get conversation object
    WordAnalysisCategory * wac = ((WordAnalysisCategory*)[self.arrayWordAnalysisCategory objectAtIndex:indexPath.row]);
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Remove from array
        [self.arrayWordAnalysisCategory removeObject:wac];
        
        // Remove from DB
        [wac SQPDeleteEntityWithCascade:YES];
        
        // Update table
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        // Refresh
        [self.tableView reloadData];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}





- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Word Analysis object
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    WordAnalysisCategory * wac = [self.arrayWordAnalysisCategory objectAtIndex:indexPath.row];
    
    // Destination Segue
    MultiSelectionWordsViewController *destinationViewController = (MultiSelectionWordsViewController *)segue.destinationViewController;
    destinationViewController.delegate = self;
    destinationViewController.category = wac;
    
    // Deselect row
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

@end
