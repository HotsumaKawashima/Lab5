#include <stdlib.h>
#import <Foundation/Foundation.h>


@interface Question : NSObject {
  NSString  *question;
  NSInteger  answer;
  NSDate    *startTime;
  NSDate    *endTime;
  NSInteger  rightValue;
  NSInteger  leftValue;
}

@property (nonatomic, assign) NSString  *question;
@property (nonatomic)         NSInteger  answer;
@property (nonatomic, assign) NSDate    *startTime;
@property (nonatomic, assign) NSDate    *endTime;
@property (nonatomic)         NSInteger  rightValue;
@property (nonatomic)         NSInteger  leftValue;

- (NSTimeInterval)timeToAnswer;
- (void)generateQuestion;

@end

@implementation Question

@synthesize question;
@synthesize answer;
@synthesize startTime;
@synthesize endTime;
@synthesize rightValue;
@synthesize leftValue;

- (instancetype)init
{
  self = [super init];
  if (self) {
    srand((unsigned)time(NULL));
    self.rightValue = rand()%101;
    self.leftValue = rand()%101;
    self.startTime = [NSDate date];
  }
  return self;
}

- (NSInteger)answer
{
  endTime = [NSDate date];
  return answer;
}

- (NSTimeInterval)timeToAnswer
{
  return [endTime timeIntervalSinceDate:startTime];
}

- (void)generateQuestion
{
}

@end

@interface QuestionFactory : NSObject {
}

- (Question *)generateRandomQuestion;

@end

@implementation QuestionFactory

- (instancetype)init
{
  self = [super init];
  if (self) {
  }
  return self;
}

- (Question *)generateRandomQuestion
{
  NSArray *questionSubclassNames = [NSArray arrayWithObjects:@"AdditionQuestion", @"SubtractionQuestion", nil];
  srand((unsigned)time(NULL));
  int index = rand()%([questionSubclassNames count]);
  return [[NSClassFromString([questionSubclassNames objectAtIndex:index]) alloc] init];
}

@end

@interface AdditionQuestion : Question {
}

@end

@implementation AdditionQuestion

- (instancetype)init
{
  self = [super init];
  if (self) {
    [self generateQuestion];
  }
  return self;
}

- (void)generateQuestion
{
  answer = rightValue + leftValue;
  question = [NSString stringWithFormat:@"%d + %d ?", (int)rightValue, (int)leftValue];
}

@end

@interface SubtractionQuestion : Question {
}

@end

@implementation SubtractionQuestion

- (instancetype)init
{
  self = [super init];
  if (self) {
    [self generateQuestion];
  }
  return self;
}

- (void)generateQuestion
{
  answer = rightValue - leftValue;
  question = [NSString stringWithFormat:@"%d - %d ?", (int)rightValue, (int)leftValue];
}

@end

@interface QuestionManager : NSObject {
  NSMutableArray *questions;
}

@property (nonatomic, assign) NSMutableArray *questions;

- (instancetype)init;
- (NSString *)timeOutput;

@end

@implementation QuestionManager

@synthesize questions;

- (instancetype)init
{
  self = [super init];
  if (self) {
    self.questions = [NSMutableArray array];
  }
  return self;
}

- (NSString *)timeOutput
{
  NSInteger total = 0;
  for (AdditionQuestion *q in questions) {
      total += [q timeToAnswer];
  }

  if([questions count] == 0) {
    return [NSString stringWithFormat:@"total time: %ds, average time: %ds", (int)total, (int)(total)];
  }

  return [NSString stringWithFormat:@"total time: %ds, average time: %ds", (int)total, (int)(total / [questions count])];
}

@end

@interface InputHandler : NSObject {
}

- (instancetype)init;
- (NSString *)read;

@end

@implementation InputHandler

- (instancetype)init
{
  self = [super init];
  return self;
}

- (NSString *)read
{
  char buf[10];
  fgets(buf, 10, stdin);
  NSString *strInput = [NSString stringWithUTF8String:buf];
  return [strInput stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}


@end

@interface ScoreKeeper : NSObject {
  NSInteger right;
  NSInteger wrong;
}

@property (nonatomic, assign) NSInteger right;
@property (nonatomic, assign) NSInteger wrong;

- (instancetype)init;
- (NSString *)result;

@end

@implementation ScoreKeeper

@synthesize right;
@synthesize wrong;

- (instancetype)init
{
  self = [super init];
  if (self) {
    self.wrong = 0;
    self.right = 0;
  }
  return self;
}

- (NSString *)result
{
  return [NSString stringWithFormat:@"score: %d right, %d wrong ---- %d\%", right, wrong, (int)(right * 100.0 / (wrong + right))];
}


@end

int main(int argc, const char * argv[]) {
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

  BOOL gameOn = YES;
  NSLog(@"MATHS!\n\n\n");
  NSString *right = @"Right!\n";
  NSString *wrong = @"Wrong!\n";
  ScoreKeeper  *scoreKeeper  = [[ScoreKeeper alloc] init];
  InputHandler *inputHandler = [[InputHandler alloc] init];
  QuestionManager *questionManager = [[QuestionManager alloc] init];
  QuestionFactory *questionFactory = [[QuestionFactory alloc] init];

  while (gameOn) {
    Question *question = [questionFactory generateRandomQuestion];
    [question generateQuestion];
    [questionManager.questions addObject:question];
    NSLog([question question]);

    NSString *trimmedString = [inputHandler read];
    if ([trimmedString isEqualToString:@"q"]) { break; }

    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *number = [formatter numberFromString: trimmedString];

    int answer = (int)[question answer];
    if (number != nil && [number integerValue] == answer) {
      scoreKeeper.right = scoreKeeper.right + 1;
      NSLog(right);
    } else {
      scoreKeeper.wrong = scoreKeeper.wrong + 1;
      NSLog(wrong);
    }

    NSLog([scoreKeeper result]);
    NSLog([questionManager timeOutput]);
  }

  [pool drain];
  return 0;
}

