//
//  ABImageViewController.h
//  Ribbit
//
//  Created by HoodsDream on 10/7/14.
//  Copyright (c) 2014 Asteroid Blues. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ABImageViewController : UIViewController

@property (nonatomic, strong) PFObject *message;
@property (weak, nonatomic) IBOutlet UIImageView *image;

@end
