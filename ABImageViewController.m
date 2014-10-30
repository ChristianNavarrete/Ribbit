//
//  ABImageViewController.m
//  Ribbit
//
//  Created by HoodsDream on 10/7/14.
//  Copyright (c) 2014 Asteroid Blues. All rights reserved.
//

#import "ABImageViewController.h"

@interface ABImageViewController ()

@end

@implementation ABImageViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    PFFile *imageFile = [self.message objectForKey:@"file"];
    NSURL *imageFileUrl = [[NSURL alloc]initWithString:imageFile.url];
    NSData *imageData = [[NSData alloc] initWithContentsOfURL:imageFileUrl];
    self.image.image = [UIImage imageWithData:imageData];
    
    NSString *senderName = [self.message objectForKey:@"senderName"];
    NSString *title = [NSString stringWithFormat:@"Sent from %@", senderName];
    self.navigationItem.title = title;
    
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([self respondsToSelector:@selector(timeout)]) {
        [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(timeout) userInfo:nil repeats:NO];
    } else {
        NSLog(@"Selector missing!");
    } 
}

#pragma mark - helper methods

-(void)timeout {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
