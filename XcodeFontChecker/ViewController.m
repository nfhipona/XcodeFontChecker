//
//  ViewController.m
//  XcodeFontChecker
//
//  Created by Neil Francis Hipona on 5/22/17.
//  Copyright © 2017 Neil Francis Hipona. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // will be a valid font if this kind of font exists
    UIFont *sampleFont = [UIFont fontWithName:@"Helvetica" size:16];
    NSLog(@"Sample Font: %@\n\n", sampleFont);
    
    if (sampleFont) {
        // log sample font's family name
        NSLog(@"\nSample font family name: %@\n\n", sampleFont.familyName);
        
        // get font list for this family name
        [self listFontsForFamilyName:sampleFont.familyName];
    }
    
    // you can check for all available and supported font family
    NSLog(@"\n\nList of supported fonts family names: %@\n\n", UIFont.familyNames);
    // use 'listFontsForFamilyName:'
    
    // sample:
    [self listFontsForFamilyName:@"Font family name goes here"];
}

- (void)listFontsForFamilyName:(NSString *)familyName {
    
    // get font list for this family name
    NSArray *fontList = [UIFont fontNamesForFamilyName:familyName];
    
    if (fontList.count > 0) {
        NSLog(@"\n\nAvailable fonts for this family name: %@\n\n", fontList);
    }else{
        NSLog(@"\n\nFont not supported.");
    }
}

@end
