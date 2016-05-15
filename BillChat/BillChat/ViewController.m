//
//  ViewController.m
//  BillChat
//
//  Created by Ariel Melendez on 5/13/16.
//  Copyright © 2016 ALM Projects. All rights reserved.
//

#import "ViewController.h"

static NSString * const TimestampCellReuseID = @"TimestampCellId";
static NSString * const UserMsgCellReuseID = @"UserMessageCellId";
static NSString * const BotMsgCellReuseID = @"BotMessageCellId";
static NSString * const UserBillCellReuseID = @"UserBillCellId";

static NSUInteger const ChatCellTextVerticalMargin = 5;
static NSUInteger const ChatCellTextHorizontalMargin = 5;

@interface TimestampCollectionViewCell : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;

@end

@interface MockSectionData : NSObject
- (instancetype)initWithArray:(NSArray*)array withTimestamp:(NSString*)timestamp;
@property (retain, nonatomic, readwrite) NSMutableArray *messages;
@property (copy, nonatomic, readwrite) NSString *timestamp;
@end

@implementation MockSectionData
- (instancetype)initWithArray:(NSArray*)array withTimestamp:(NSString*)timestamp {
    if(self = [super init]) {
        self.messages = [array mutableCopy];
        self.timestamp = timestamp;
    }
    return self;
}
@end

// TODO: Move to other source files
@implementation TimestampCollectionViewCell

@end

@interface UserMessageCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *chatTextLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatTextHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatTextWidthConstraint;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomMarginConstraint;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topMarginConstraint;
@property (weak, nonatomic) IBOutlet UIView *chatTextBackground;
@end

@implementation UserMessageCollectionViewCell

@end

@interface BotMessageCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *chatTextLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatTextHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatTextWidthConstraint;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomMarginConstraint;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topMarginConstraint;
@property (weak, nonatomic) IBOutlet UIView *chatTextBackground;
@end

@implementation BotMessageCollectionViewCell

@end

@interface UserBillCollectionViewCell : UICollectionViewCell

@end

@implementation UserBillCollectionViewCell

@end

@interface ViewController () <
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UITextFieldDelegate,
    UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *chatCollectionView;
@property (weak, nonatomic) IBOutlet UITextField *chatTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *keyboardHeightConstraint;

@property (strong, nonatomic, readwrite) NSMutableArray *mockData;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupMockData];
    [self setupCollectionView];
    [self setupTextField];
    [self startObservingKeyboard];
    [self setupKeyboardAutoDismisser];
}

- (void) dealloc {
    [self stopObservingKeyboard];
}

- (void)setupCollectionView {
    self.chatCollectionView.dataSource = self;
    self.chatCollectionView.delegate = self;
}

- (void)setupTextField {
    self.chatTextField.delegate = self;
}

- (void)startObservingKeyboard {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)stopObservingKeyboard {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)setupKeyboardAutoDismisser {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
}

- (void)dismissKeyboard {
    [self.chatTextField resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification*)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSValue *keyboardFrameValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrameRect = [keyboardFrameValue CGRectValue];
    CGFloat keyboardHeight = keyboardFrameRect.size.height;
    self.keyboardHeightConstraint.constant = -keyboardHeight;
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification*)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    self.keyboardHeightConstraint.constant = 0;
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Mock Data Methods

- (void)setupMockData {
    NSDateFormatter *dateFormatter=[NSDateFormatter new];
    [dateFormatter setDateFormat:@"h:mma"];
    [dateFormatter setAMSymbol:@"am"];
    [dateFormatter setPMSymbol:@"pm"];
    
    self.mockData = [NSMutableArray new];
    MockSectionData* entry = [[MockSectionData alloc] initWithArray:[[NSMutableArray alloc] initWithArray:@[@"Hello", @"Bot hello"]]
                                                      withTimestamp:[dateFormatter stringFromDate:[NSDate date]]];
    [self.mockData addObject:entry];
}

#pragma mark - UICollectionViewDelegate

// TODO: Decide if we need any callbacks

#pragma mark - UICollectionViewDataSource


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    // TODO: Update for real data
    if([self.mockData count] > section) {
        MockSectionData* sectionData = [self.mockData objectAtIndex:section];
        return [sectionData.messages count];
    } else
        return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Update for real data!
    MockSectionData *sectionData = [self.mockData objectAtIndex:indexPath.section];
    UICollectionViewCell *cell = nil;
    if(indexPath.row % 2 == 0) {
        UserMessageCollectionViewCell *userMsgCell =
            (UserMessageCollectionViewCell*)[self.chatCollectionView dequeueReusableCellWithReuseIdentifier:UserMsgCellReuseID
                                                                                               forIndexPath:indexPath];
        
        [userMsgCell.chatTextBackground.layer setCornerRadius:ChatCellTextVerticalMargin];
        //userMsgCell.topMarginConstraint.constant = ChatCellTextVerticalMargin;
        //userMsgCell.bottomMarginConstraint.constant = ChatCellTextVerticalMargin;

        userMsgCell.chatTextLabel.text = [sectionData.messages objectAtIndex:indexPath.row];
        CGRect r = [userMsgCell.chatTextLabel.text boundingRectWithSize:CGSizeMake(self.chatCollectionView.frame.size.width, 0)
                                                                options:NSStringDrawingUsesLineFragmentOrigin
                                                             attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.0f]}
                                                                context:nil];
        userMsgCell.chatTextHeightConstraint.constant = userMsgCell.frame.size.height;
        userMsgCell.chatTextWidthConstraint.constant = MIN(r.size.width + 2 * ChatCellTextHorizontalMargin, self.chatCollectionView.frame.size.width);
        
        cell = userMsgCell;
    } else {
         BotMessageCollectionViewCell *botMsgCell =
            [self.chatCollectionView dequeueReusableCellWithReuseIdentifier:BotMsgCellReuseID
                                                               forIndexPath:indexPath];
        [botMsgCell.chatTextBackground.layer setCornerRadius:ChatCellTextVerticalMargin];
        //botMsgCell.topMarginConstraint.constant = ChatCellTextVerticalMargin;
        //botMsgCell.bottomMarginConstraint.constant = ChatCellTextVerticalMargin;
        [botMsgCell.chatTextBackground.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        [botMsgCell.chatTextBackground.layer setBorderWidth:0.5f];
        
        CGRect r = [botMsgCell.chatTextLabel.text boundingRectWithSize:CGSizeMake(self.chatCollectionView.frame.size.width, 0)
                                                                options:NSStringDrawingUsesLineFragmentOrigin
                                                             attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.0f]}
                                                                context:nil];
        botMsgCell.chatTextHeightConstraint.constant = botMsgCell.frame.size.height;
        NSLog(@"Width of text %@ is %f", botMsgCell.chatTextLabel.text, r.size.width);
        botMsgCell.chatTextWidthConstraint.constant = MIN(r.size.width + 2 * ChatCellTextHorizontalMargin, self.chatCollectionView.frame.size.width);
        NSLog(@"Chosen width is %f", botMsgCell.chatTextWidthConstraint.constant);
        botMsgCell.chatTextLabel.text = [sectionData.messages objectAtIndex:indexPath.row];

        cell = botMsgCell;
    }
    
    NSAssert(cell, @"Unexpected nil cell!");
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    // TODO: Update with real data!
    return [self.mockData count];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    NSAssert([self.mockData count] > indexPath.section, @"Unexpected section count!");
    NSAssert(indexPath.row == 0, @"Unexpected indexPath row for section header!");
    
    MockSectionData *sectionData = [self.mockData objectAtIndex:indexPath.section];
    
    TimestampCollectionViewCell *sectionHeader = (TimestampCollectionViewCell*)[self.chatCollectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                                                           withReuseIdentifier:TimestampCellReuseID
                                                                                                                                  forIndexPath:indexPath];
    sectionHeader.timestampLabel.text = sectionData.timestamp;
    
    NSAssert(sectionHeader, @"Unexpected nil cell!");
    return sectionHeader;
}


#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Update these sizes
    MockSectionData *sectionData = [self.mockData objectAtIndex:indexPath.section];
    NSString* msgStr = [sectionData.messages objectAtIndex:indexPath.row];
    CGRect r = [msgStr boundingRectWithSize:CGSizeMake(self.chatCollectionView.frame.size.width, 0)
                                    options:NSStringDrawingUsesLineFragmentOrigin
                                 attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.0f]}
                                    context:nil];
    CGSize ret = CGSizeMake(self.chatCollectionView.frame.size.width, r.size.height + ChatCellTextVerticalMargin * 2);
    return ret;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    // TODO: Update these sizes
    return CGSizeMake(self.chatCollectionView.frame.size.width, 30);
}

//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section;
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section;
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section;
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section;


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // TODO: Send/save msg
    NSString *chatMsg = textField.text;
    MockSectionData *sectionData = [self.mockData objectAtIndex:self.mockData.count - 1];
    [sectionData.messages addObject:chatMsg];
    [sectionData.messages addObject:chatMsg];
    [self.chatCollectionView reloadData];
    textField.text = @"";
    
    return YES;
}


@end
