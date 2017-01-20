//
//  UploadSettingVC.h
//  Flippy Cloud
//
//  Created by iSquare5 on 22/08/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import "ViewController.h"

@interface UploadSettingVC : ViewController


@property (nonatomic,strong) IBOutlet UIButton *openMenu;
@property (nonatomic,strong) IBOutlet UISwitch *AutoSCH,*SyncSCH;

-(IBAction)AutoSCHBtnPressed:(id)sender;
-(IBAction)SyncSCHBtnPressed:(id)sender;
@end
