//
//  ViewController.m
//  ManualFBLogin
//
//  Created by dev on 12/26/15.
//  Copyright © 2015 dev. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>

@interface ViewController ()
    -(void)hideUserInfo:(BOOL)shouldHide;
    @property (nonatomic, strong) AppDelegate *appDelegate;

-(void)handleFBSessionStateChangeWithNotification:(NSNotification *)notification;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // this will turn the dark statuse bar into light one.
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //this is make the image view rounded.
    self.imgProfilePicture.layer.masksToBounds = YES;
    self.imgProfilePicture.layer.cornerRadius = 30.0;
    self.imgProfilePicture.layer.borderColor = [UIColor whiteColor].CGColor;
    self.imgProfilePicture.layer.borderWidth = 1.0;
    
    [self hideUserInfo:YES];
    self.activityIndicator.hidden = YES;
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFBSessionStateChangeWithNotification:) name:@"SessionStateChangeNotification" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (IBAction)toggleLoginState:(id)sender {
    if ([FBSession activeSession].state != FBSessionStateOpen &&
        [FBSession activeSession].state != FBSessionStateOpenTokenExtended) {
        [self.appDelegate openActiveSessionWithPermissions:@[@"public_profile", @"email"] allowLoginUI:YES];

    }else{
        // Close an existing session.
        [[FBSession activeSession] closeAndClearTokenInformation];
        
        // Update the UI.
        [self hideUserInfo:YES];
        self.lblStatus.hidden = NO;
        self.lblStatus.text = @"You are not logged in.";
    }

}

-(void)hideUserInfo:(BOOL)shouldHide{
    self.imgProfilePicture.hidden = shouldHide;
    self.lblFullname.hidden = shouldHide;
    self.lblEmail.hidden = shouldHide;
}

-(void)handleFBSessionStateChangeWithNotification:(NSNotification *)notification{
    // Get the session, state and error values from the notification's userInfo dictionary.
    NSDictionary *userInfo = [notification userInfo];
    
    FBSessionState sessionState = [[userInfo objectForKey:@"state"] integerValue];
    NSError *error = [userInfo objectForKey:@"error"];
    
    self.lblStatus.text = @"Logging you in...";
    [self.activityIndicator startAnimating];
    self.activityIndicator.hidden = NO;
    
    // Handle the session state.
    // Usually, the only interesting states are the opened session, the closed session and the failed login.
    if (!error) {
        // In case that there's not any error, then check if the session opened or closed.
        if (sessionState == FBSessionStateOpen) {
            // The session is open. Get the user information and update the UI.
            [FBRequestConnection startWithGraphPath:@"me"
                                         parameters:@{@"fields": @"first_name, last_name, picture.type(normal), email"}
                                         HTTPMethod:@"GET"
                                  completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                      if (!error) {
                                          // Set the use full name.
                                          self.lblFullname.text = [NSString stringWithFormat:@"%@ %@",
                                                                   [result objectForKey:@"first_name"],
                                                                   [result objectForKey:@"last_name"]
                                                                   ];
                                          
                                          // Set the e-mail address.
                                          self.lblEmail.text = [result objectForKey:@"email"];
                                          
                                          // Get the user's profile picture.
                                          NSURL *pictureURL = [NSURL URLWithString:[[[result objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"]];
                                          self.imgProfilePicture.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:pictureURL]];
                                          
                                          // Make the user info visible.
                                          [self hideUserInfo:NO];
                                          
                                          // Stop the activity indicator from animating and hide the status label.
                                          self.lblStatus.hidden = YES;
                                          [self.activityIndicator stopAnimating];
                                          self.activityIndicator.hidden = YES;
                                      }
                                      else{
                                          NSLog(@"%@", [error localizedDescription]);
                                      }
                                  }];
            
            [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                
                if (!error) {
                    NSLog(@"%@", result);
                }
                
            }];
            
            [self.btnToggleLoginState setTitle:@"Logout" forState:UIControlStateNormal];
            
        }
        else if (sessionState == FBSessionStateClosed || sessionState == FBSessionStateClosedLoginFailed){
            // A session was closed or the login was failed or canceled. Update the UI accordingly.
            [self.btnToggleLoginState setTitle:@"Login" forState:UIControlStateNormal];
            self.lblStatus.text = @"You are not logged in.";
            self.activityIndicator.hidden = YES;
        }
    }
    else{
        // In case an error has occured, then just log the error and update the UI accordingly.
        NSLog(@"Error: %@", [error localizedDescription]);
        
        [self hideUserInfo:YES];
        [self.btnToggleLoginState setTitle:@"Login" forState:UIControlStateNormal];
        
    }
}

@end
