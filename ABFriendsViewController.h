//
//  ABFriendsViewController.h
//  Ribbit
//
//  Created by HoodsDream on 9/29/14.
//  Copyright (c) 2014 Asteroid Blues. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ABFriendsViewController : UITableViewController

@property (nonatomic, strong) PFRelation *friendsRelation;
@property (nonatomic, strong) NSArray *friends;


@end
