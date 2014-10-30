//
//  ABCameraViewController.m
//  Ribbit
//
//  Created by HoodsDream on 10/6/14.
//  Copyright (c) 2014 Asteroid Blues. All rights reserved.
//

#import "ABCameraViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>

@interface ABCameraViewController ()

@end

@implementation ABCameraViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.recipients = [[NSMutableArray alloc] init];

}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.friendsRelation = [[PFUser currentUser] objectForKey:@"friendsRelation"];
    
    PFQuery *query = [self.friendsRelation query];
    [query orderByAscending:@"username"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        } else {
            self.friends = objects;
            [self.tableView reloadData];
        }
    }];
    
    if (self.image == nil && [self.videoFilePath length] == 0) {
    
    self.imagePicker = [[UIImagePickerController alloc]init];
    self.imagePicker.delegate = self;
    self.imagePicker.allowsEditing = NO;
    self.imagePicker.videoMaximumDuration = 10;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    self.imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:self.imagePicker.sourceType];
    
    [self presentViewController:self.imagePicker animated:NO completion:nil];
        
    }
    
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        //A photo was taken
        self.image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        if (self.imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil);
            
        }
        
    } else {
        //A video was taken
        self.videoFilePath = CFBridgingRelease([[info objectForKey:UIImagePickerControllerMediaURL] path]);
        if (self.imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            //Save the video
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(self.videoFilePath)) {
                UISaveVideoAtPathToSavedPhotosAlbum(self.videoFilePath, nil, nil, nil);
            }
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.friends count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    PFUser *user = [self.friends objectAtIndex:indexPath.row];
    cell.textLabel.text = user.username;
    
    if ([self.recipients containsObject:user.objectId]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    PFUser *user = [self.friends objectAtIndex:indexPath.row];
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.recipients addObject:user.objectId];
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.recipients removeObject:user.objectId];
    }
}

#pragma mark - image picker controller

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:NO completion:nil];
    [self.tabBarController setSelectedIndex:0];
}


#pragma mark - IBActions


- (IBAction)cancel:(id)sender {
    
    [self reset];
    
    [self.tabBarController setSelectedIndex:0];
    
    
}

- (IBAction)send:(id)sender {
    
    if (self.image == nil && [self.videoFilePath length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Try Again" message:@"Please select a photo or video to share!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        
        [alertView show];
        [self presentViewController:self.imagePicker animated:NO completion:nil];
    } else {
        [self uploadMessage];
        [self.tabBarController setSelectedIndex:0];
    }
}

#pragma mark - helper methods

-(void)uploadMessage {
    
    NSData *fileData;
    NSString *fileName;
    NSString *fileType;

    if (self.image != nil) {
        UIImage *newImage = [self resizeImage:self.image toWidth:640.0f toHeight:1136.0f];
        fileData = UIImagePNGRepresentation(newImage);
        fileName = @"img.png";
        fileType = @"image";
        
    } else {
        
        fileData = [NSData dataWithContentsOfFile:self.videoFilePath];
        fileName = @"video.mov";
        fileType = @"video";
        
    }

    PFFile *file = [PFFile fileWithName:fileName data:fileData];
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error occurred" message:@"Please try sending your message again" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alertView show];
    } else {
        PFObject *message = [PFObject objectWithClassName:@"Messages"];
        [message setObject:file forKey:@"file"];
        [message setObject:fileType forKey:@"fileType"];
        [message setObject:self.recipients forKey:@"recipientIds"];
        [message setObject:[[PFUser currentUser]objectId] forKey:@"senderId"];
        [message setObject:[[PFUser currentUser]username] forKey:@"senderName"];
        [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error occurred" message:@"Please try sending your message again" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alertView show];
                } else {
                //message got uploaded!
                [self reset];
                }
            }];
        }
    }];
}


- (void)reset {
    [self.recipients removeAllObjects];
    self.videoFilePath = nil;
    self.image = nil;
}



-(UIImage *)resizeImage:(UIImage *)image toWidth:(float)width toHeight:(float)height {
    CGSize newSize = CGSizeMake(width, height);
    CGRect newRectangle = CGRectMake(0,0,width,height);
    UIGraphicsBeginImageContext(newSize);
    [self.image drawInRect:newRectangle];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return resizedImage;
}




@end
