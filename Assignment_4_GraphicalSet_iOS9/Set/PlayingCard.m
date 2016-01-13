//
//  PlayingCard.m
//  Set
//
//  Created by Hannah Troisi on 1/1/16.
//  Copyright © 2016 Hannah Troisi. All rights reserved.
//

#import "PlayingCard.h"

@implementation PlayingCard

@synthesize suit = _suit;

#pragma mark - Getter / Setter Overrides

- (NSString *)suit
{
  return _suit ? _suit : @"?";
}

- (void)setSuit:(NSString *)suit
{
  if ([[[self class] validSuits] containsObject:suit]) {
    _suit = suit;
  }
}

- (void)setRank:(NSUInteger)rank
{
  if (rank <= [[self class] maxRank]) {
    _rank = rank;
  }
}

- (NSString *)contents
{
  NSArray *rankStrings = [[self class] rankStrings];
  return [rankStrings[self.rank] stringByAppendingString:self.suit];
}


#pragma mark - Instance Methods

- (int)match:(NSArray *)otherCards
{
  int score = 0;
  
  for (PlayingCard *otherCard in otherCards) {
    if (self.suit == otherCard.suit) {
      score += 1;
    }
    if (self.rank == otherCard.rank) {
      score += 4;
    }
  }
  
  return score;
}

- (NSString *)description
{
  return self.contents;// [[super description] stringByAppendingString:self.contents];
}

#pragma mark - Class Methods

+ (NSUInteger)maxRank
{
  return [[self rankStrings] count] - 1;
}

+ (NSArray *)rankStrings
{
  return @[@"?",@"A",@"2",@"3",@"4",@"5",@"6",
           @"7",@"8",@"9",@"10",@"J",@"Q",@"K"];
}

+ (NSArray *)validSuits
{
  return @[@"♦︎",@"♥︎",@"♠︎",@"♣︎"];
}

@end