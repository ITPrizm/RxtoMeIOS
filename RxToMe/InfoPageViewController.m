//
//  InfoPageViewController.m
//  RxToMe
//
//  Created by Michael Spearman on 9/15/15.
//  Copyright (c) 2015 Michael Spearman. All rights reserved.
//

#import "InfoPageViewController.h"
#import "User.h"
@interface InfoPageViewController ()

@property (weak, nonatomic) IBOutlet UILabel *name_field;
@property (weak, nonatomic) IBOutlet UILabel *email_field;
@property (weak, nonatomic) IBOutlet UILabel *phone_field;
@property (weak, nonatomic) IBOutlet UILabel *state_field;
@property (weak, nonatomic) IBOutlet UILabel *zip_field;
@property (weak, nonatomic) IBOutlet UILabel *city_field;
@property (weak, nonatomic) IBOutlet UILabel *address_field;
@property (weak, nonatomic) IBOutlet UILabel *address2_field;
@property (weak, nonatomic) IBOutlet UILabel *country_field;
@property (weak, nonatomic) IBOutlet UIView  *prescription;
@property (weak, nonatomic) IBOutlet UIView  *payment;
@property User *user;

@end

@implementation InfoPageViewController

- (void)viewDidLoad {
    _user = [User sharedManager];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_name_field setText:_user.name];
    [_email_field setText:_user.email];
    [_phone_field setText:_user.phone];
    [_state_field setText:_user.state];
    [_zip_field setText:_user.zip];
    [_city_field setText:_user.city];
    [_address_field setText:_user.address];
    [_address2_field setText:_user.address2];
    [_country_field setText:_user.country];
}



@end
