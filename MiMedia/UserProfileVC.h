//
//  UserProfileVC.h
//  Flippy Cloud
//
//  Created by iSquare5 on 15/08/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserProfileVC : UIViewController





@property (nonatomic) UITapGestureRecognizer *tapRecognizer;//CGFloat animateDistance;
@property (nonatomic,weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic,strong) IBOutlet UIButton *openMenu,*UpgradePlanBtn,*HintsBtn,*ContactUsBtn,*HelpBtn,*saveBtn,*RefereFrndBtn,*RewordBtn;
@property (nonatomic,strong) IBOutlet UITextField *f_nameTXT,*l_nameTXT,*emailTXT,*contactTXT,*passTXT,*addTXT,*OldpassTXT;
@property (nonatomic, retain) UIView* contentView;
@property (nonatomic, retain) IBOutlet UIView* UpdateView,*OnlyReferFrndView;
@property (nonatomic,strong) IBOutlet UILabel *usernameL,*avatarLab,*UpgradeKeyLbl;
@property (nonatomic,strong) IBOutlet UIProgressView *ProgressView,*NonShringProgressView;
@property (nonatomic,strong) IBOutlet UILabel *PlanName,*totalSize,*usedSize,*Percantage,*NonShringPercantage,*NonShringtotalSize,*NonShringPlanName;
@property (nonatomic,strong) IBOutlet UIButton *changeProBtn,*UpgradeKeyBTN,*UpgradeMerBtn,*UpgradeOptBackBtn,*UpgradeKeyDoneBtn;
@property (nonatomic,weak) IBOutlet UITextField *UpgradeKeyTXT;
@property (nonatomic,strong) IBOutlet UIView *SecondView,*UpgradeOptionView,*UpgradeBtnView,*NonSharingView;
@property (nonatomic,strong) IBOutlet UILabel *UpgradPlanLbl,*lineLbl,*TotalPointsLbl;



-(IBAction)UpgradePlanBtnPressed:(id)sender;
-(IBAction)EditBtnPressed:(id)sender;
-(IBAction)SaveBtnPressed:(id)sender;
-(IBAction)BackBtnPressed:(id)sender;
-(IBAction)ChangeProBtnPressed:(id)sender;
-(IBAction)UpgradeKeyBTNPressed:(id)sender;
-(IBAction)UpgradeMerBtnPressed:(id)sender;
-(IBAction)UpgradeKeyDoneBtnPressed:(id)sender;
@end
