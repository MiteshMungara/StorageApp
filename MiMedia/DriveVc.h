//
//  DriveVc.h
//  Flippy Cloud
//
//  Created by iSquare5 on 22/08/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import "ViewController.h"

@interface DriveVc : ViewController
{
    CGFloat animateDistance;

}



@property (nonatomic) UITapGestureRecognizer *tapRecognizer;
//collectionView
@property (nonatomic,weak) IBOutlet UICollectionView *collectionView,*EmailCollectionView;
@property (nonatomic,weak) IBOutlet UILabel *collTitleL,*totalImgL;
//--stop

@property (nonatomic,weak) IBOutlet UITableView *EmailsSharingTV;

@property (nonatomic,strong) IBOutlet UIButton *openMenu,*TableBackBtn,*TableDoneBtn;
@property (nonatomic, retain) UIView* contentView;

@property (nonatomic,weak) IBOutlet UIView *mainHeaderView,*mainView,*EmailSharingView;

//createdrive
@property (nonatomic,weak) IBOutlet UIView *CreateDrive;
@property (nonatomic,weak) IBOutlet UITextField *DriveNameTxt;


-(IBAction)addBtnPressed:(id)sender;
-(IBAction)CreateCollBtnPressed:(id)sender;
-(IBAction)CancelBtnPressed:(id)sender;
-(IBAction)createBtnPressed:(id)sender;
-(IBAction)TableBackBtnPressed:(id)sender;
-(IBAction)TableDoneBtnPressed:(id)sender;





@end
