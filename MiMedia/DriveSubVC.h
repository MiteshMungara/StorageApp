//
//  DriveSubVC.h
//  Flippy Cloud
//
//  Created by iSquare5 on 29/08/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import "ViewController.h"

@interface DriveSubVC : ViewController
{
      IBOutlet UICollectionView *photosCollectionCV;
     IBOutlet UIImageView *photoImageIV,*MemberImgView;
}

@property (nonatomic) UITapGestureRecognizer *tapRecognizer;

@property (nonatomic,weak) IBOutlet UIView *EmptyView,*CollectionView,*RenameDriveView,*DeleteDriveView,*ShareDriveView,*RenameView,*MemberShowOrAddView;
@property (nonatomic,weak) IBOutlet UILabel *DriveNamelbl,*DeleteDriveLBL;
@property (nonatomic,strong) IBOutlet UIButton *MenuBtn,*MemberViewBackBtn,*AddMemberBtn;
@property (nonatomic,weak) IBOutlet UIButton *RenameBackBtn,*RenameDoneBtn,*ChatBtn,*MemberListShowOrAddBtn;
@property (nonatomic,weak) IBOutlet UITextField *RenameDriveTXT;
@property(strong,nonatomic)  IBOutlet UITableView *MemberListTableView;



-(IBAction)BackBtnPressed:(id)sender;
-(IBAction)MemberViewBackBtnPressed:(id)sender;
-(IBAction)MenuBtnPressed:(id)sender;
-(IBAction)AddMemberBtnPressed:(id)sender;//addMemberVC
//-(IBAction)DeleteCollBtnPressed:(id)sender;
-(IBAction)RenameCollBtnPressed:(id)sender;
-(IBAction)ShareCollBtnPressed:(id)sender;
-(IBAction)ChatBtnPressed:(id)sender;
-(IBAction)MemberShowOrAddBtnPressed:(id)sender;
@end
