//
//  ABLoginViewController.h
//  Ribbit
//
//  Created by HoodsDream on 9/17/14.
//  Copyright (c) 2014 Asteroid Blues. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ABLoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;


- (IBAction)login:(id)sender;
@end
