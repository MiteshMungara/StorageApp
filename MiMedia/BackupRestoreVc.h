//
//  BackupRestoreVc.h
//  Flippy Cloud
//
//  Created by iSquare5 on 29/08/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import "ViewController.h"
#import "DLPieChart.h"

@interface BackupRestoreVc : ViewController

@property (nonatomic,weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic,weak) IBOutlet UILabel * audioLbl,*videoLbl,*ImageLbl,*FileLbl;
@property (nonatomic ,retain) IBOutlet DLPieChart *piechartView;

@property (nonatomic,weak) IBOutlet UIButton *videoBtn,*audioBtn,*imageBtn,*filesBtn,*contactBtn,*syncBtn;

-(IBAction)syncBtnPressed:(id)sender;
-(IBAction)contactBtnPressed:(id)sender;
-(IBAction)audioBtnPressed:(id)sender;
-(IBAction)videoBtnPressed:(id)sender;
-(IBAction)imagesBtnPressed:(id)sender;
-(IBAction)filesBtnPressed:(id)sender;

@end


