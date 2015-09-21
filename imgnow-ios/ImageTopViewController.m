//
//  ImageTopViewController.m
//  imgnow-ios
//
//  Created by Henry Ehly on 2015/09/21.
//  Copyright © 2015年 Henry Ehly. All rights reserved.
//

#import "ImageTopViewController.h"
#import "ViewController.h"
#import "ImageDetailViewController.h"

@interface ImageTopViewController ()

@end

@implementation ImageTopViewController

NSArray *fakeTitles;
NSArray *fakeDetails;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    fakeTitles = [NSArray arrayWithObjects:@"6f73hf84", @"u57s21k0", @"7f82hcmx", @"7d51k8m0", @"0sg1nna4", @"8h92h7vu", nil];
    fakeDetails = [NSArray arrayWithObjects:@"28 days left", @"23 days left", @"19 days left", @"17 days left", @"10 days left", @"1 day left", nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [fakeTitles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = [fakeTitles objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [fakeDetails objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
//
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"imageDetail"]) {
        
        ImageDetailViewController *idvc = (ImageDetailViewController *)[segue destinationViewController];
        idvc.delegate = self;
        
        [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:YES];

        
    }
}

@end
