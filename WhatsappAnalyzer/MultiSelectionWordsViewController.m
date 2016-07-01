//
//  MultiSelectionViewController.m
//  STPopup
//
//  Created by Kevin Lin on 11/10/15.
//  Copyright © 2015 Sth4Me. All rights reserved.
//

#import "MultiSelectionWordsViewController.h"

@interface MultiSelectionWordsViewController ()

// @NOTE: Not in use
- (IBAction)done:(id)sender;

@end

@implementation MultiSelectionWordsViewController
{

}
@synthesize category;

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.contentSizeInPopup = CGSizeMake([UIScreen mainScreen].bounds.size.width, 300);
    self.landscapeContentSizeInPopup = CGSizeMake([UIScreen mainScreen].bounds.size.height, 300);
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    /* Design */
    self.view.backgroundColor = [UIColor gk_cloudsColor];
    self.title = self.category.strName;
    
    // Add buttons
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewWordAlert:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    
    
}




#pragma mark - Functions

-(void)addNewWordsFromCSVString:(NSString*)strCSVNewWords
{
    if (strCSVNewWords.length > 0)
    {
        // Split CSV style
        for (NSString * strName in [strCSVNewWords componentsSeparatedByString:kSeperatorComma])
        {
            // Don't add empty words
            if (strName.length > 0)
            {
                // Check if exists already
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.strWord ==[c] %@", strName];
                NSArray *filteredArray = [self.category.arrayWord filteredArrayUsingPredicate:predicate];
                // If not exists, add it
                if ([filteredArray count] == 0)
                {
                    // Create new object + populate
                    Word * w = [Word SQPCreateEntity];
                    w.strWord = strName;
                    w.numberIsSelected = @YES;
                    [w SQPSaveEntityWithCascade:YES];
                    
                    // Add to array
                    [self.category.arrayWord addObject:w];
                }
            }
        }
    }
    
    
    // Add to tableview
    [self.tableView reloadData];
    
    // Scroll down
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.category.arrayWord count]-1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

-(void) addNewWordAlert:(id)sender
{
    // Show alert asking for new categry
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"New Word" message: @"Insert multiple words using CSV Style" preferredStyle:UIAlertControllerStyleAlert];
    
    // Add new text field for category name
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = NSLocalizedString(@"Word", @"Word");
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
                                                          [self addNewWordsFromCSVString: txtfieldCategory.text];
                                                          
                                                      }];
    
    [alert addAction:cancelAction];
    [alert addAction:addAction];
    [self presentViewController:alert animated:YES completion:nil];
}


// @NOTE: Not in use
- (void)done:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(multiSelectionViewController:didFinishWithSelections:)]) {
        [self.delegate multiSelectionViewController:self didFinishWithSelections:nil];
    }
    [self.popupController popViewControllerAnimated:YES];
}






#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.category.arrayWord.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID_Word];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID_Word];
    }
    
    // Word object
    Word * word = (Word*)self.category.arrayWord[indexPath.row];
    
    // Populate cell
    cell.textLabel.text = word.strWord;
    cell.accessoryType = word.numberIsSelected.boolValue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Word object
    Word * word = (Word*)self.category.arrayWord[indexPath.row];
    
    // Set opposite (V --> X  |  X --> V)
    word.numberIsSelected = [NSNumber numberWithBool:!word.numberIsSelected.boolValue];
    
    // Save selection
    [word SQPSaveEntityWithCascade:YES];
    
    // Reload table
    [tableView reloadData];
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Get conversation object
    Word * w = ((Word*)[self.category.arrayWord objectAtIndex:indexPath.row]);
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Remove from array
        [self.category.arrayWord removeObject:w];
        
        // Remove from DB
        [w SQPDeleteEntityWithCascade:YES];
        
        // Update table
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}




@end
