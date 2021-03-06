//
//  SetMatchingGame.m
//  Set
//
//  Created by Hannah Troisi on 1/1/16.
//  Copyright © 2016 Hannah Troisi. All rights reserved.
//

#import "SetMatchingGame.h"
#import "SetCard.h"

@implementation SetMatchingGame


#pragma mark - Lifecycle

- (instancetype)initWithCardCount:(NSUInteger)count usingDeck:(Deck *)deck
{
  self = [super initWithCardCount:count usingDeck:deck];
  
  if (self) {
    self.gameName = @"Set";
  }
  
  return self;
}


#pragma mark - Instance Methods

static const int MISMATCH_PENALTY = 1;
static const int MATCH_BONUS = 2;

- (void)choseCardAtIndex:(NSUInteger)index
{
  // create game start timestamp if game not already started
  if (!self.startTimestamp) {
    self.startTimestamp = [NSDate date];
  }

  Card *card = [self.cards objectAtIndex:index];
  
  // reset lastMatched & lastScore properties?
  if ( ([self.lastMatched count] >= 2) && (self.lastScore > 0) ) {
    // successful match
    [self.lastMatched removeAllObjects];
    
  } else if ( ([self.lastMatched count] >= 2) && (self.lastScore < 0) ){
    // unsuccessful match
    [self.lastMatched removeObjectsInRange:NSMakeRange(0, 2)]; //remove first 2 objects
  }
  
  self.lastScore = 0;
  
  // only allow unmatched cards to be chosen
  if (!card.isMatched) {
    
    // if the card is already chosen, unchose it
    if (card.isChosen) {
      card.chosen = NO;
      [self.lastMatched removeObjectIdenticalTo:card];
      
    } else {
      
      // add card to the lastMatched array
      [self.lastMatched addObject:card];
      
      // check that 2 other cards are chosen
      int numChosenCards = 0;
      NSMutableArray *chosenCards = [[NSMutableArray alloc] init];
      
      for (Card *otherCard in self.cards) {
        if (otherCard.isChosen && !otherCard.isMatched) {
          numChosenCards++;
          [chosenCards addObject:otherCard];
        }
      }
      
      // if 2 cards are chosen
      if (numChosenCards == 2) {
        
        // match cards against eachother
        int matchScore = [card match:[chosenCards copy]];
        
        NSArray *cardSet = [chosenCards arrayByAddingObject:card];
        
        // if match
        if (matchScore) {
          // adjust game score
          self.lastScore = matchScore * MATCH_BONUS;
          self.score += self.lastScore;
          // mark cards as matched
          for (SetCard *card in cardSet) {
            card.matched = YES;
          }
        } else {
          // adjust game score
          self.lastScore -= MISMATCH_PENALTY;
          self.score += self.lastScore;
          // mark cards as unchosen
          for (SetCard *card in cardSet) {
            card.chosen = NO;
          }
        }
      }
      
      // mark chosen card as chosen
      card.chosen = YES;
    }
  }
}

@end
