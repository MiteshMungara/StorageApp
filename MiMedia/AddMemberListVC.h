//
//  AddMemberListVC.h
//  Flippy Cloud
//
//  Created by isquare3 on 11/22/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddMemberListVC : UIViewController
{
    IBOutlet UIImageView *SettingImage;
    IBOutlet UILabel *DriveName;
    IBOutlet UIButton *DriveNameEditBtn;
    IBOutlet UITextField *Drivetxt;
    IBOutlet UIButton *DeleteDriveBtn,*LeaveDriveBtn,*ShowInvitedEmails;
    IBOutlet UIView *InvitedEmailsListview;
    IBOutlet UITableView *InvitedEmaillist;
    
}
//@property (nonatomic,weak) IBOutlet UICollectionView *EmailCollectionView;
@end
