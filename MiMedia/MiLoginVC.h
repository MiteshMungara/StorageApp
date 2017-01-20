//
//  MiLoginVC.h
//  MiMedia
//
//  Created by iSquare5 on 09/08/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"


@interface MiLoginVC : UIViewController
{
    CGFloat animateDistance;
    AppDelegate *app;
}


@property (nonatomic,strong) IBOutlet UITextField *userNameTxt,*PassTxt,*forPassTxt;
@property (nonatomic) UITapGestureRecognizer *tapRecognizer;//CGFloat animateDistance;
@property (nonatomic,strong) IBOutlet UIView *ForgotPassView;

-(IBAction)LoginBtnPressed:(id)sender;
-(IBAction)BackBtnPressed:(id)sender;
-(IBAction)forgotBtnPressed:(id)sender;
-(IBAction)resetPassBtnPressed:(id)sender;
-(IBAction)forBackBtnPressed:(id)sender;
-(IBAction)TermsBtnPressed:(id)sender;
-(IBAction)PolicyBtnPressed:(id)sender;

@end
