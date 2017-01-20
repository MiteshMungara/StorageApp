//
//  MiSignupVC.h
//  MiMedia
//
//  Created by iSquare5 on 08/08/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MiSignupVC : UIViewController
{
        CGFloat animateDistance;
}

@property (nonatomic,strong) IBOutlet UITextField  *f_nameTXT,*l_nameTXT,*emailTXT,*passTXT,*p_codeTXT,*PhoneTxt;
@property (nonatomic) UITapGestureRecognizer *tapRecognizer;

-(IBAction)SignupBtnPressed:(id)sender;
-(IBAction)BackBtnPressed:(id)sender;
-(IBAction)TermsBtnPressed:(id)sender;
-(IBAction)PolicyBtnPressed:(id)sender;

@end
