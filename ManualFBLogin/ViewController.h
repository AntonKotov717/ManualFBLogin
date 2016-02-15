//
//  ViewController.h
//  ManualFBLogin
//
//  Created by dev on 12/26/15.
//  Copyright © 2015 dev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *btnToggleLoginState;
@property (weak, nonatomic) IBOutlet UIImageView *imgProfilePicture;
@property (weak, nonatomic) IBOutlet UILabel *lblFullname;

@property (weak, nonatomic) IBOutlet UILabel *lblEmail;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)toggleLoginState:(id)sender;
@end

