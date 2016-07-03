//
//  ViewController.m
//  TestDeeplink
//
//  Created by johney.song on 15/2/24.
//  Copyright (c) 2015年 johney.song. All rights reserved.
//

#import "ViewController.h"
#import "DeepShare.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *textInfo;
@property (weak, nonatomic) IBOutlet UILabel *textParams;
@property (weak, nonatomic) IBOutlet UILabel *textInstall;
@property (weak, nonatomic) IBOutlet UILabel *textOpen;
@property (weak, nonatomic) IBOutlet UILabel *textInstallChannel;
@property (weak, nonatomic) IBOutlet UITextField *textFieldParamsValue1;
@property (weak, nonatomic) IBOutlet UITextField *textFieldParmasKey1;
@property (weak, nonatomic) IBOutlet UITextField *textFieldChangeValueTag;
@property (weak, nonatomic) IBOutlet UITextField *textFieldChangeValueValue;
@end

@implementation ViewController


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:true];
    [self.textParams setText:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldUpdateParams:) name:NOTIFICATION_PARAM_UPDATE object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter]  removeObserver:self];
}


- (void)shouldUpdateParams:(NSNotification *) notification{
    NSDictionary *params = notification.userInfo;
    [self.textParams setText:params.description];
    NSArray *chans =[DeepShare getInstallChannel];
    NSString *strChans = [chans componentsJoinedByString:@","];
    [self.textInstallChannel setText:strChans];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onOpenWebClicked:(id)sender {
    // shareUrl should be filled with the destination url you want user to see when they click the button
    NSString *shareUrl = @"http://deepshare.io/deepshare-web-demo.html";
    
    // set the appid, you can find your appid in deepshare dashboard. URL:dashboard.deepshare.io
    NSString *appId = @"f709f09576216199";
    
    // put key value pairs into NSDictionary as inapp_data
    NSString *paramsKey1 = self.textFieldParmasKey1.text;
    NSString *paramsValue1 = self.textFieldParamsValue1.text;
    NSDictionary*params = [[NSDictionary alloc] initWithObjects:@[paramsValue1] forKeys:@[paramsKey1]];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
    if (!jsonData) {
        NSLog(@"Got an error when serialize the jsonData, check your inapp_data!: %@", error);
        return;
    }
    NSString *inappData = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    // should pass appid, inapp_data, sender_id as parameters.
    NSString *senderId = [DeepShare getSenderID];
    NSString *desUrl = [NSString stringWithFormat:@"%@?appid=%@&inapp_data=%@&sender_id=%@", shareUrl, appId, inappData, senderId];
    NSString *encodingUrl = [desUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:encodingUrl];
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)onChangeValueClicked:(id)sender {
    NSString *tag = self.textFieldChangeValueTag.text;
    NSNumber *value = @([self.textFieldChangeValueValue.text intValue]);
    if (tag != nil && ![tag isEqualToString:@""]) {
        NSDictionary *tagTovalue = [[NSDictionary alloc] initWithObjects:@[value] forKeys:@[tag]];
        [DeepShare attribute:tagTovalue completion:^(NSError *error) {
            if(error) {
                NSString *errorString = [[[error userInfo] objectForKey:NSLocalizedDescriptionKey] objectAtIndex:0];
                [self.textInfo setText:errorString];
                NSLog(@"change value error id:%ld %@", (long)error.code, errorString);
            }
        }];
    }
}

- (IBAction)onGetUsageClicked:(id)sender {
    [DeepShare getNewUsageFromMe:^(int newInstall, int newOpen, NSError *error) {
        if (!error) {
            [self.textInstall setText:[@(newInstall) stringValue]];
            [self.textOpen setText:[@(newOpen) stringValue]];
        } else {
            NSString *errorString = [[[error userInfo] objectForKey:NSLocalizedDescriptionKey] objectAtIndex:0];
            [self.textInfo setText:errorString];
            NSLog(@"get usage error id:%ld %@", (long)error.code, errorString);
        }
    }];
}

- (IBAction)onClearUsageClicked:(id)sender {
    [DeepShare clearNewUsageFromMe:^(NSError *error) {
        NSString *errorString = [[[error userInfo] objectForKey:NSLocalizedDescriptionKey] objectAtIndex:0];
        [self.textInfo setText:errorString];
        NSLog(@"clear usage error id:%ld %@", (long)error.code, errorString);
    }];
}

@end
