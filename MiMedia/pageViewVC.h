//
//  pageViewVC.h
//  MiMedia
//
//  Created by iSquare5 on 08/08/16.
//  Copyright © 2016 MitSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface pageViewVC : UIViewController


@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property NSUInteger pageIndex;
@property NSString *titleText;
@property NSString *imageFile;
@end
