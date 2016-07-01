//
//  BarGraphViewVC.m
//  GraphKit
//
//  Created by Michal Konturek on 17/04/2014.
//  Copyright (c) 2014 Michal Konturek. All rights reserved.
//

#import "GraphBarsViewController.h"


@interface GraphBarsViewController ()
@end

@implementation GraphBarsViewController
@synthesize arrayDataValues, arrayDataLabels, arrayDataColors, strGraphName;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /* Design */
    self.view.backgroundColor = [UIColor gk_cloudsColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
    self.navigationItem.leftItemsSupplementBackButton = YES;
    self.title = self.strGraphName;
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(redrawGraph)];
    self.navigationItem.rightBarButtonItem = refreshButton;
    
    /* Initialize data */
    //self.arrayDataValues = @[@100, @100, @40, @90];
    //self.arrayDataLabels = @[@"AA", @"AB", @"BB", @"CC"];
    if (!self.arrayDataColors)
    {
        self.arrayDataColors = @[[UIColor gk_peterRiverColor],
                                 [UIColor gk_turquoiseColor],
                                 [UIColor gk_alizarinColor],
                                 [UIColor gk_amethystColor],
                                 [UIColor gk_emerlandColor],
                                 [UIColor gk_sunflowerColor]
                                 ];
    }
    // Set deleage
    self.graphView.dataSource = self;
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // If we don't have any data to work with, we will present nice lable
    //      saying that "No data is available!"
    
    if (self.arrayDataValues)
    {
        // Sums data values
        self.numberValuesTotal = [self.arrayDataValues valueForKeyPath: @"@sum.self"];
        
        // Redraw after having data and view
        [self redrawGraph];
        
        // We have data, Hide lable
        [self.lblNoDataYet setHidden:YES];
    }
    else
    {
        // Hide graph
        [self.graphView reset];
        
        // Show text lable
        [self.lblNoDataYet setHidden:NO];
    }
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void) redrawGraph
{
    /* Prepare */
    self.graphView.frame = self.view.frame;
    self.graphView.barHeight = self.graphView.frame.size.height - 65;
    self.graphView.barWidth = (self.graphView.frame.size.width / self.arrayDataValues.count) - 10.f;
    self.graphView.animationDuration = 1.5;
    self.graphView.marginBar = 10.0f;
    
    /* Draw */
    [self.graphView draw];
}



#pragma mark - GKBarGraphDataSource

- (NSInteger)numberOfBars
{
    return MIN([self.arrayDataValues count], kGraphBarsMaxRows);
}

- (NSNumber *)valueForBarAtIndex:(NSInteger)index
{
    // 100 * (Value / Total )
    return [NSNumber numberWithFloat: 100.0f *
            (((NSNumber*)[self.arrayDataValues objectAtIndex:index]).floatValue /
            self.numberValuesTotal.floatValue)
            ];
}

- (UIColor *)colorForBarAtIndex:(NSInteger)index
{
    return [self.arrayDataColors objectAtIndex:index];
}

- (NSString *)titleForBarAtIndex:(NSInteger)index
{
    //  John Doe
    //   123.1
    //   65.21%
    return [
            NSString stringWithFormat:@"%@\n%.0f\n%.2f%%",
    [self.arrayDataLabels objectAtIndex:index],                         // Name
    ((NSNumber*)[self.arrayDataValues objectAtIndex:index]).floatValue, // Value
    [self.graphView.dataSource valueForBarAtIndex:index].floatValue     // Percentage
    ];
}








#pragma mark - System (Orientation and shaking)

-(void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        // Redraw
        [self redrawGraph];
    }
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         //UIInterfaceOrientation orientation = (UIInterfaceOrientation)[[UIApplication sharedApplication] statusBarOrientation];
         // do whatever
     } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         // Redraw after transition chage
         [self redrawGraph];
     }];
    
    
}
@end
