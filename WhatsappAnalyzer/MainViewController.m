//
//  MasterViewController.m
//  WhatsappAnalyzer
//
//  Created by Sharon Brizinov on 14/10/2015.
//  Copyright © 2015 SBSoftware. All rights reserved.
//



#import "MainViewController.h"



@interface MainViewController ()

@end
@implementation MainViewController
@synthesize arrayConversations, viewControllerConversation;



- (void)viewDidLoad
{    
    [super viewDidLoad];

    /* Design */
    self.view.backgroundColor = [UIColor gk_cloudsColor];
    self.title = @"Conversations";
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    // Add button
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(updateAll:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    /* Initialization */
    self.arrayConversations = [Conversation SQPFetchAll];
    
    // Register for inner notifcations
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recievingNotificationNewConversation:) name:kNotificationCenterNewConversation object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recievingNotificationDeleteConversation:) name:kNotificationCenterDeleteConversation object:nil];
    
    
    
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateAll:(id)sender
{
    self.arrayConversations = [Conversation SQPFetchAll];
    [self.tableView reloadData];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString: kSegue_Show_Conversation])
    {
        // Add HUD
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        // Split view
        UISplitViewController *splitViewController = (UISplitViewController *)[segue destinationViewController];
        
        // Master
        UINavigationController *navigationControllerMaster = [splitViewController.viewControllers firstObject];
        ConversationViewController * viewControllerMaster = (ConversationViewController*)[navigationControllerMaster topViewController];
        splitViewController.delegate = viewControllerMaster; // Set the delegate to be the master
        
        // Detail
        /*
        UINavigationController *navigationControllerDetail = [splitViewController.viewControllers lastObject];
        GraphForTwoViewController * viewControllerDetail = (GraphForTwoViewController*)[navigationControllerDetail topViewController];
        viewControllerDetail.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        viewControllerDetail.navigationItem.leftItemsSupplementBackButton = YES;
        */
        
        // Conversation view controller
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        viewControllerMaster.conversation = [self.arrayConversations objectAtIndex:indexPath.row];

        // Deselect row
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];

    }

}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.arrayConversations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Init cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    // Date formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterLongStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    
    // Populate cell with data
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%lu Messages)", ((Conversation*)[self.arrayConversations objectAtIndex:indexPath.row]).strGroupName, (unsigned long)((Conversation*)[self.arrayConversations objectAtIndex:indexPath.row]).numberTotalMessages.unsignedIntegerValue];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate: ((Conversation*)[self.arrayConversations objectAtIndex:indexPath.row]).dateAddedAt]];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Get conversation object
    Conversation * conv = ((Conversation*)[self.arrayConversations objectAtIndex:indexPath.row]);
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [GlobalManager askTheUserForDeletingConversation:conv withReason:(ConversationDeleteType)ConversationDeleteGeneral];

    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}


#pragma mark - Notification
-(void) recievingNotificationNewConversation:(NSNotification *)notification
{
    // notification.object --> Should be Conversation object
    if (notification.object && // Isn't null
        [notification.object isKindOfClass:[Conversation class]]) // Kind of Conversation
    {
        // Frist get new index
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.arrayConversations.count inSection:0];
        
        // Add to array
        [self.arrayConversations addObject:notification.object];
        
        // Add to tableview
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
        
    }
    
    // Refresh data
    [self.tableView reloadData];
}
-(void) recievingNotificationDeleteConversation:(NSNotification *)notification
{
    // notification.object --> Should be Conversation object
    if (notification.object && // Isn't null
        [notification.object isKindOfClass:[Conversation class]] && // Kind of Conversation
        [self.arrayConversations containsObject:notification.object]) // Exists in array
    {
        // First get new index
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.arrayConversations indexOfObject:notification.object] inSection:0];
        // Remove from array
        [self.arrayConversations removeObject:notification.object];

        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }
    // Refresh data
    [self.tableView reloadData];
}


@end
