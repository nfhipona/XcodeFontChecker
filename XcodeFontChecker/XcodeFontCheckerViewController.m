//
//  FontCheckUpViewController.m
//  XcodeFontChecker
//
//  Created by Neil Francis Hipona on 5/26/17.
//  Copyright © 2017 Neil Francis Hipona. All rights reserved.
//

#import "XcodeFontCheckerViewController.h"
#import "FontInfoTableViewCell.h"

@interface XcodeFontCheckerViewController ()<UITableViewDelegate, UITableViewDataSource, CAAnimationDelegate>

@property (weak, nonatomic) IBOutlet UITextView *inputField;
@property (weak, nonatomic) IBOutlet UITextField *fontSizeField;

@property (weak, nonatomic) IBOutlet UIButton *minusButton;
@property (weak, nonatomic) IBOutlet UIButton *plusButton;

@property (weak, nonatomic) IBOutlet UITableView *fontTableView;
@property (weak, nonatomic) IBOutlet UITableView *subFontTableView;

@property (nonatomic, strong) NSArray *fontCollections;
@property (nonatomic, strong) NSArray *subFontCollections;

@property (nonatomic, strong) UIFont *activeFont;

@end

@implementation XcodeFontCheckerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self prepareNavigationBar];
    [self prepareUI];
    [self prepareFontData];
}

#pragma mark - Layout

- (void)prepareNavigationBar {
    
    UIBarButtonItem *reloadFonts = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadFonts:)];
    self.navigationItem.rightBarButtonItem = reloadFonts;
}

- (void)prepareUI {
    
    self.fontTableView.delegate = self;
    self.fontTableView.dataSource = self;
    
    self.subFontTableView.delegate = self;
    self.subFontTableView.dataSource = self;
    
    [self addLayoutBorder:self.fontTableView];
    [self addLayoutBorder:self.subFontTableView];
    [self addLayoutBorder:self.inputField];
    [self addLayoutBorder:self.fontSizeField];
    
    [self addLayoutBorder:self.minusButton];
    [self addLayoutBorder:self.plusButton];
    
    [self.fontSizeField addTarget:self action:@selector(fontSizeDidChanged:) forControlEvents:UIControlEventEditingChanged];
}

- (void)addLayoutBorder:(UIView *)view {
    
    view.layer.borderColor = [UIColor lightGrayColor].CGColor;
    view.layer.cornerRadius = 4.0;
    view.layer.borderWidth = 1.0;
    view.clipsToBounds = YES;
}

#pragma mark - Animation

- (void)animateUnsupportedSubFont {
    
    UIView *view = self.subFontTableView;
    [view.layer removeAllAnimations];

    CGPoint startPoint = CGPointMake(view.center.x - 10, view.center.y);
    NSValue *start = [NSValue valueWithCGPoint:startPoint];
    
    CGPoint endPoint = CGPointMake(view.center.x + 10, view.center.y);
    NSValue *end = [NSValue valueWithCGPoint:endPoint];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setDuration:0.03];
    [animation setRepeatCount:3];
    [animation setAutoreverses:YES];
    [animation setFromValue:start];
    [animation setToValue:end];
    [animation setDelegate:self];
    
    [view.layer addAnimation:animation forKey:@"position"];
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStart:(CAAnimation *)anim {
    
    self.subFontTableView.layer.borderColor = [UIColor redColor].CGColor;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
    self.subFontTableView.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

#pragma mark - Font Size

- (UIFont *)fontWithFontName:(NSString *)fontName fontSize:(CGFloat)fontSize {
    
    UIFont *font = [UIFont fontWithName:fontName size:fontSize];
    
    return font;
}

- (void)fontSizeDidChanged:(UITextField *)field {
    
    CGFloat fontSize = [field.text floatValue];
    UIFont *activeFont = [self fontWithFontName:self.activeFont.fontName fontSize:fontSize];
    self.inputField.font = activeFont;
}

- (IBAction)fontSizerButton:(UIButton *)sender {
    
    CGFloat fontSize = [self.fontSizeField.text floatValue];
    
    if (sender.tag == 0) { // -
        fontSize -= 1;
    }else{ // +
        fontSize += 1;
    }
    
    UIFont *activeFont = [self fontWithFontName:self.activeFont.fontName fontSize:fontSize];
    self.inputField.font = activeFont;
    
    NSString *fontSizeStr = [NSString stringWithFormat:@"%0.1f", fontSize];
    self.fontSizeField.text = fontSizeStr;
}

#pragma mark - Data

- (void)prepareFontData {

    self.fontCollections = @[];
    self.subFontCollections = @[];
    
    // list of all available and supported font family
    NSLog(@"\n\nList of supported fonts family names: %@\n\n", UIFont.familyNames);

    self.fontCollections = UIFont.familyNames;
    
    // set default font
    self.activeFont = [UIFont systemFontOfSize:16.0];
    self.inputField.font = self.activeFont;
    self.fontSizeField.text = @"16.0";
    
    [self.fontTableView reloadData];
    [self.subFontTableView reloadData];
}

- (NSArray *)fontsForFamilyName:(NSString *)familyName {
    
    // get font list for this family name
    NSArray *fontList = [UIFont fontNamesForFamilyName:familyName];
    NSMutableArray *fontListTmp = [@[] mutableCopy];
    
    for (NSString *fontName in fontList) {
        UIFont *font = [UIFont fontWithName:fontName size:16.0];
        [fontListTmp addObject:font];
    }
    
    if (fontListTmp.count > 0) {
        NSLog(@"\n\nAvailable fonts for this family name: %@\n\n", fontList);
    }else{
        NSLog(@"\n\nFont not supported.");
    }
    
    return fontListTmp;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView.tag == 0) {
        return self.fontCollections.count;
    }else{
        return self.subFontCollections.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FontInfoTableViewCell *fontInfoCell = [tableView dequeueReusableCellWithIdentifier:@"FontInfoTableViewCell" forIndexPath:indexPath];
    
    return fontInfoCell;
}

#pragma mark - UITableViewDataSource

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FontInfoTableViewCell *fontInfoCell = (FontInfoTableViewCell *)cell;
    
    if (tableView.tag == 0) {
        NSString *fontName = self.fontCollections[indexPath.row];
        fontInfoCell.titleLabel.text = fontName;
        fontInfoCell.titleLabel.font = [UIFont systemFontOfSize:16.0];
    }else{
        UIFont *font = self.subFontCollections[indexPath.row];
        fontInfoCell.titleLabel.text = font.fontName;
        fontInfoCell.titleLabel.font = font;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView.tag == 0) {
        NSString *fontName = self.fontCollections[indexPath.row];
        self.navigationItem.title = fontName;
        
        self.subFontCollections = [self fontsForFamilyName:fontName];
        [self.subFontTableView reloadData];
        
        if (self.subFontCollections.count == 0) {
            [self animateUnsupportedSubFont];
        }
    }else{

        self.activeFont = self.subFontCollections[indexPath.row];
        self.inputField.font = self.activeFont;
    }
}

#pragma mark - Navigation

- (void)reloadFonts:(UIBarButtonItem *)sender {
    
    [self prepareFontData];
}


@end
