//
//  ABEditFriendsTableViewController.h
//  Ribbit
//
//  Created by HoodsDream on 9/27/14.
//  Copyright (c) 2014 Asteroid Blues. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ABEditFriendsTableViewController : UITableViewController

@property (nonatomic, strong) NSArray *allUsers;
@property (nonatomic, strong) PFUser *currentUser;
@property (nonatomic, strong) NSMutableArray *friends;

-(BOOL) isFriend:(PFUser *)user;

@end
