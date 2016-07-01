//
//  BarGraphViewVC.h
//  GraphKit
//
//  Created by Michal Konturek on 17/04/2014.
//  Copyright (c) 2014 Michal Konturek. All rights reserved.
//

#import "Globals.h"

@interface GraphBarsViewController : UIViewController<GKBarGraphDataSource>

@property (nonatomic, weak) IBOutlet GKBarGraph              * graphView;
@property (nonatomic, strong) IBOutlet UILabel               * lblNoDataYet;


@property (nonatomic, strong) NSString       *strGraphName;
@property (nonatomic, strong) NSMutableArray *arrayDataValues;
@property (nonatomic, strong) NSMutableArray *arrayDataLabels;
@property (nonatomic, strong) NSArray        *arrayDataColors;
@property (nonatomic, strong) NSNumber       *numberValuesTotal; //sums the total values
@end
