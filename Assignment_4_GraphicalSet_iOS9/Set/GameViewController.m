//
//  GameViewController.m
//  Set
//
//  Created by Hannah Troisi on 1/1/16.
//  Copyright © 2016 Hannah Troisi. All rights reserved.
//

#import "GameViewController.h"
#import "SetCardView.h"
#import "SetCard.h"
#import "CardCollectionViewCell.h"
#import "CardPileCollectionViewLayout.h"

@interface GameViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@end

@implementation GameViewController
{
  UIToolbar *_toolBar;
  UICollectionViewFlowLayout *_flowLayout;
  CardPileCollectionViewLayout *_customLayout;
  UIPinchGestureRecognizer *_pinchGR;
  UIPanGestureRecognizer *_panGR;
  UITapGestureRecognizer *_tapGR;
  UICollectionViewTransitionLayout *_transitionLayout;
}


#pragma mark - Class Methods

// subclass must implement
+ (Class)gameClass
{
  NSAssert(NO, @"This should not be reached - abstract class");
  return Nil;
}

// subclass must implement
+ (Class)deckClass
{
  NSAssert(NO, @"This should not be reached - abstract class");
  return Nil;
}

// subclass must implement
+ (Class)cardViewClass
{
  NSAssert(NO, @"This should not be reached - abstract class");
  return Nil;
}

// subclass must implement
+ (NSUInteger)numCardsInMatch
{
  NSAssert(NO, @"This should not be reached - abstract class");
  return 0;
}

+ (NSDictionary *)attributesDictionary
{
  NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
  [paragraphStyle setAlignment:NSTextAlignmentCenter];
  
  NSDictionary *attributes = @{ NSForegroundColorAttributeName  : [UIColor whiteColor],
                                NSFontAttributeName             : [UIFont preferredFontForTextStyle:UIFontTextStyleBody],
                                NSParagraphStyleAttributeName   : paragraphStyle};
  return attributes;
}


#pragma mark - Properties

// lazy instantiation for _game so that we can set it to nil when dealing
- (MatchingGame *)game
{
  if (!_game) {
    Deck *deck = [[[[self class] deckClass] alloc] init];
    _game = [[[[self class] gameClass] alloc] initWithCardCount:50 usingDeck:deck];  // FIXME: hardcoded card count
  }
  
  return _game;
}


#pragma mark - Lifecycle

- (instancetype)init
{
  self = [super initWithNibName:nil bundle:nil];
  
  if (self) {

  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  // create scoreLabel
  self.scoreLabel = [[UILabel alloc] init];
  self.scoreLabel.text = @"Score: 0";
  self.scoreLabel.textColor = [UIColor whiteColor];
  self.scoreLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
  
  // create dealButton
  self.dealButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [self.dealButton setImage:[self backgroundImageForDealButton] forState:UIControlStateNormal];
  [self.dealButton addTarget:self action:@selector(touchDealButton) forControlEvents:UIControlEventTouchUpInside];
  [self.dealButton setTintColor:[UIColor whiteColor]];
  
  // CollectionFlowLayout
  
  _flowLayout = [[UICollectionViewFlowLayout alloc] init];
  _flowLayout.itemSize = CGSizeMake(60, 100);  // FIXME:
  _flowLayout.minimumInteritemSpacing = 5;
  _flowLayout.minimumLineSpacing = 5;
  _flowLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
  
  _customLayout = [[CardPileCollectionViewLayout alloc] init];
  
  _transitionLayout = [[UICollectionViewTransitionLayout alloc] initWithCurrentLayout:_flowLayout nextLayout:_customLayout];
  
  self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_flowLayout];
  self.collectionView.backgroundColor = [UIColor redColor];
  self.collectionView.delegate = self;
  self.collectionView.dataSource = self;
  self.collectionView.scrollEnabled = NO;
  [self.collectionView registerClass:[CardCollectionViewCell class] forCellWithReuseIdentifier:@"card"];
  
  _pinchGR = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
  _panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
  _panGR.enabled = NO;
  _tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
  _tapGR.enabled = NO;
  
  [self.collectionView addGestureRecognizer:_pinchGR];
  [self.collectionView addGestureRecognizer:_panGR];
  [self.collectionView addGestureRecognizer:_tapGR];
  
  _toolBar = [[UIToolbar alloc] init];
  _toolBar.backgroundColor = [UIColor purpleColor];
  _toolBar.alpha =  0;
  
  [self.view addSubview:_toolBar];
  [self.view addSubview:self.collectionView];
  
  [self updateScore];

  // add subviews to view
//  [self.view addSubview:self.buttonGridView];
  [self.view addSubview:self.scoreLabel];
  [self.view addSubview:self.dealButton];
}

- (void)viewWillLayoutSubviews
{
  [super viewWillLayoutSubviews];
  
  CGSize boundsSize = self.view.bounds.size;
  
  _toolBar.frame = CGRectMake(0,
                              CGRectGetMinY(self.tabBarController.tabBar.frame) - 40,
                              boundsSize.width,
                              40);
  
  // set frame for buttonGridView
  self.collectionView.frame = CGRectMake( 0,
                                      CGRectGetMaxY(self.navigationController.navigationBar.frame),
                                      boundsSize.width,
                                      CGRectGetMinY(_toolBar.frame) - CGRectGetMaxY(self.navigationController.navigationBar.frame));
  
  // set frame for scoreLabel
  self.scoreLabel.frame = CGRectMake(20,
                                     self.view.bounds.size.height - 40 - 54,
                                     self.view.bounds.size.width - 40,
                                     20);
  
  // set frame for dealButton
  [self.dealButton sizeToFit];
  CGRect dealButtonFrame = self.dealButton.frame;
  dealButtonFrame.origin = CGPointMake(self.view.bounds.size.width - 60,
                                       self.view.bounds.size.height - 44 - 54);
  self.dealButton.frame = dealButtonFrame;
}


#pragma mark - User Actions

- (void)touchDealButton
{
  // save game score & other metadata to NSUserDefaults
  if (self.game.score && self.game.startTimestamp) {
    [self saveGameWithScore:self.game.score gameType:self.game.gameName start:self.game.startTimestamp];
  }
  
  // remove current game & gameCommentary History
  self.game = nil;
  
  // update UI
  [self updateScore];
  
  [self.collectionView reloadData];
}


#pragma mark - Instance Methods

- (void)updateScore
{
  // update game score
  self.scoreLabel.text = [NSString stringWithFormat:@"Score: %ld", (long)self.game.score];
}

- (void)touchCardButtonAtIndex:(NSUInteger)cardButtonIndex
{
  // update game model
  [self.game choseCardAtIndex:cardButtonIndex];
  
  // update UI
  [self updateScore];
}




#pragma mark - UICollectionViewDelegate Protocol Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  [self touchCardButtonAtIndex:indexPath.item];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
  [(CardCollectionViewCell *)cell fadeIn];
}


#pragma mark - UICollectionViewDataSource Protocol Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
  // reloadItemsAtIndexPath FIXME: // containsObjectIdenticalTo or use isSelected
  return [self.game.cards count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  Card *card = [self.game cardAtIndex:indexPath.item];
  CardCollectionViewCell *newCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"card" forIndexPath:indexPath];
  newCell.card = card;
  
  return newCell;
}


#pragma mark - Gesture Handling

- (void)handleTapGesture:(UIPanGestureRecognizer *)sender
{
//  NSLog(@"TAPPED");
  
  [_collectionView setCollectionViewLayout:_flowLayout animated:YES];
  _collectionView.allowsSelection = YES;
  _panGR.enabled = NO;
  _tapGR.enabled = NO;
  _pinchGR.enabled = YES;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)sender
{
//  NSLog(@"PANNING");
  
  static CGPoint originalCenter;
  
  if (sender.state == UIGestureRecognizerStateBegan) {
    
    originalCenter = sender.view.center;
    
  } else if (sender.state == UIGestureRecognizerStateChanged) {
    
    CGPoint translation = [sender translationInView:sender.view.superview];
    sender.view.center = CGPointMake(originalCenter.x + translation.x, originalCenter.y + translation.y);
    
  }
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)sender
{
//  NSLog(@"Pinching");
  
  if ([sender numberOfTouches] != 2)
    return;
  
  if (sender.state == UIGestureRecognizerStateBegan) {
    
    CGPoint pinchPoint = [sender locationInView:sender.view];
    _customLayout.itemOffset = UIOffsetMake(pinchPoint.x , pinchPoint.y );  //FIXME: center
    
    [_collectionView setCollectionViewLayout:_transitionLayout];  // FIXME: use transition Layout
    
  } else if (sender.state == UIGestureRecognizerStateChanged) {
    
    // Update the custom layout parameter and invalidate.
    _transitionLayout.transitionProgress = 1 - sender.scale;
//    NSLog(@"%f", sender.scale);
    
    [_customLayout invalidateLayout];
    
  } else if (sender.state == UIGestureRecognizerStateEnded |
             sender.state == UIGestureRecognizerStateCancelled |
             sender.state == UIGestureRecognizerStateFailed) {
    
//    _transitionLayout.transitionProgress = 1;
//    [_customLayout invalidateLayout];
    
//    _collectionView.allowsSelection = NO;
    _pinchGR.enabled = NO;
    _panGR.enabled = YES;
    _tapGR.enabled = YES;
    
  }
}



#pragma mark - NSUser Defaults

static const int MAX_NUM_SAVED_SCORES = 10;

- (void)saveGameWithScore:(NSInteger)score gameType:(NSString *)game start:(NSDate *)startDate
{
  // create game dictionary with 4 metadata keys
  NSDictionary *gameData = @{@"gameType": game,
                             @"score": [NSNumber numberWithInteger:score],
                             @"start": startDate,
                             @"end": [NSDate date]};
  
  // get gameDataArray from NSUserDefaults
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSMutableArray *gameDataArray = [[defaults objectForKey:@"gameDataArray"] mutableCopy];
  
  // check that gameDataArray isn't nil
  if (!gameDataArray) {
    gameDataArray = [[NSMutableArray alloc] init];
  }
  
  // add game dictionary to gameDataArray
  [gameDataArray addObject:gameData];
  
  // sort gameDataArray by key "score"
  [gameDataArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
    
    NSInteger score1 = [[obj1 objectForKey:@"score"] integerValue];
    NSInteger score2 = [[obj2 objectForKey:@"score"] integerValue];
    
    if ( score1 < score2 ) {
      return (NSComparisonResult)NSOrderedDescending;
    } else if ( score1 > score2 ) {
      return (NSComparisonResult)NSOrderedAscending;
    }
    return (NSComparisonResult)NSOrderedSame;
    
  }];
  
  // if gameDataArray has more than 15 scores, trim it
  if ( [gameDataArray count] > MAX_NUM_SAVED_SCORES ) {
     gameDataArray = [[gameDataArray subarrayWithRange:NSMakeRange(0, MAX_NUM_SAVED_SCORES)] mutableCopy];
  }
  
  // save updated gameDataArray to NSUserDefaults
  [defaults setObject:gameDataArray forKey:@"gameDataArray"];
}


#pragma mark - Helper Drawing Methods

- (UIImage *)backgroundImageForDealButton
{
  NSAttributedString *dealBtnTitle = [[NSAttributedString alloc] initWithString:@"Deal"
                                                                    attributes:[[self class] attributesDictionary]];
  
  // returns the minimum size required to draw the contents of the string
  CGSize textSize = [dealBtnTitle size];
  
  // sizing for roundedRect
  CGFloat cornerRadius = 5.0;
  CGFloat lineWidth = 1.0;
  CGFloat padding = (lineWidth + cornerRadius) * 2;
  
  CGSize bufferSize     = CGSizeMake(textSize.width + padding, textSize.height + padding);
  CGRect roundRectRect  = CGRectMake(0, 0, bufferSize.width, bufferSize.height);
  CGPoint titleOrigin   = CGPointMake((roundRectRect.size.height - textSize.height)/2.0,
                                      (roundRectRect.size.height - textSize.height)/2.0);
  
  // create a CGContext with the correct buffer size
  UIGraphicsBeginImageContextWithOptions(bufferSize, NO, 0);
  
  // set stroke & fill
  [[UIColor whiteColor] set];
  
  // draw rounded rect bezier path
  [[UIBezierPath bezierPathWithRoundedRect:roundRectRect cornerRadius:cornerRadius] stroke];
  
  // draw title
  [dealBtnTitle drawAtPoint:titleOrigin];
  
  // get an image from the current CGContext
  UIImage *buttonImage = UIGraphicsGetImageFromCurrentImageContext();
  
  // end the context
  UIGraphicsEndImageContext();
  
  return buttonImage;
}

@end
