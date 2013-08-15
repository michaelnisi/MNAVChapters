//
//  MNID3ParserTests.m
//  metata
//
//  Created by Michael Nisi on 08.08.13.
//  Copyright (c) 2013 Michael Nisi. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#import "MNAVChapters.h"

@interface ChaptersMP3Tests : XCTestCase
@property (nonatomic) NSArray *actualChapters;
@property (nonatomic) NSArray *expectedChapters;
@end

@implementation ChaptersMP3Tests

- (void)setUp {
    NSArray *chapters;
    chapters = @[
                 [MNAVChapter chapterWithTime:CMTimeMake(0, 1)
                                 duration:CMTimeMake(15000, 1000)],
                 [MNAVChapter chapterWithTime:CMTimeMake(15000, 1000)
                                 duration:CMTimeMake(7000, 1000)],
                 [MNAVChapter chapterWithTime:CMTimeMake(22000, 1000)
                                 duration:CMTimeMake(12000, 1000)],
                 [MNAVChapter chapterWithTime:CMTimeMake(34000, 1000)
                                 duration:CMTimeMake(11000, 1000)],
                 [MNAVChapter chapterWithTime:CMTimeMake(45000, 1000)
                                 duration:CMTimeMake(15000, 1000)],
                 [MNAVChapter chapterWithTime:CMTimeMake(60000, 1000)
                                 duration:CMTimeMake(16000, 1000)],
                 [MNAVChapter chapterWithTime:CMTimeMake(76000, 1000)
                                 duration:CMTimeMake(18000, 1000)],
                 [MNAVChapter chapterWithTime:CMTimeMake(94000, 1000)
                                 duration:CMTimeMake(17500, 1000)],
                 [MNAVChapter chapterWithTime:CMTimeMake(111500, 1000)
                                 duration:CMTimeMake(7497, 1000)] // duration:CMTimeMake(52500, 3000)
                 ];
    
    NSArray *dicts;
    dicts = @[@{@"title":@"Intro",
                @"url":@"https://auphonic.com/"},
              @{@"title":@"Creating a new production",
                @"url":@"https://auphonic.com/engine/upload/"},
              @{@"title":@"Sound analysis"},
              @{@"title":@"Adaptive leveler",
                @"url":@"https://auphonic.com/audio_examples#leveler"},
              @{@"title":@"Global loudness normalization",
                @"url":@"https://auphonic.com/audio_examples#loudnorm"},
              @{@"title":@"Audio restoration algorithms",
                @"url":@"https://auphonic.com/audio_examples#denoise"},
              @{@"title":@"Output file formats",
                @"url":@"http://auphonic.com/blog/5/"},
              @{@"title":@"External services",
                @"url":@"http://auphonic.com/blog/16/"},
              @{@"title":@"Get a free account!",
                @"url":@"https://auphonic.com/accounts/register"}];
    
    NSUInteger i = 0;
    for (MNAVChapter *chapter in chapters) {
        [chapter setValuesForKeysWithDictionary:dicts[i++]];
    }
    
    _expectedChapters = chapters;
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"auphonic_chapters_demo" ofType:@"mp3"];
    NSURL *url = [NSURL fileURLWithPath:path];
    AVAsset *asset = [AVURLAsset assetWithURL:url];
    MNAVChapterReaderMP3 *parser = [MNAVChapterReaderMP3 new];
    _actualChapters = [parser chaptersFromAsset:asset];
}

- (void)tearDown {
    _expectedChapters = nil;
    _actualChapters = nil;
}

- (void)testTitle {
    MNAVChapter *expected;
    NSUInteger i = 0;
    for (MNAVChapter *actual in _actualChapters) {
        expected = _expectedChapters[i++];
        XCTAssertTrue([actual.title isEqualToString:expected.title], @"");
    }
    XCTAssertTrue(i > 0, @"should run");
}

- (void)testTime {
    MNAVChapter *expected;
    NSUInteger i = 0;
    for (MNAVChapter *actual in _actualChapters) {
        expected = _expectedChapters[i++];
        XCTAssertTrue(actual.time.value == expected.time.value, @"");
        XCTAssertTrue(CMTIME_COMPARE_INLINE(actual.time, ==, expected.time), @"");
    }
    XCTAssertTrue(i > 0, @"should run");
}

- (void)testDuration {
    MNAVChapter *expected;
    NSUInteger i = 0;
    for (MNAVChapter *actual in _actualChapters) {
        expected = _expectedChapters[i++];
        XCTAssertTrue(actual.duration.value == expected.duration.value, @"");
        XCTAssertTrue(CMTIME_COMPARE_INLINE(actual.duration, ==, expected.duration), @"");
    }
    XCTAssertTrue(i > 0, @"should run");
}

- (void)testURL {
    MNAVChapter *expected;
    NSUInteger i = 0;
    for (MNAVChapter *actual in _actualChapters) {
        expected = _expectedChapters[i++];
        XCTAssertTrue(actual.url == expected.url ||
                      [actual.url isEqualToString:expected.url], @"");
    }
    XCTAssertTrue(i > 0, @"should run");
}

- (void)testImage {
    MNAVChapter *expected;
    NSUInteger i = 0;
    for (MNAVChapter *actual in _actualChapters) {
        expected = _expectedChapters[i++];
        XCTAssertNotNil(actual.artwork, @"");
        XCTAssertTrue([actual.artwork isKindOfClass:[UIImage class]], @"");
    }
    XCTAssertTrue(i > 0, @"should run");
}

- (void)testIntro {
    NSData *data = [self dataWithName:@"1"];
    MNAVChapterReaderMP3 *parser = [MNAVChapterReaderMP3 new];
    MNAVChapter *actual = [parser chapterFromFrame:data];
    MNAVChapter *expected = _expectedChapters[0];
    XCTAssertTrue([actual isEqualToChapter:expected]);
}
                   
- (NSData *)dataWithName:(NSString *)name {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:name ofType:nil];
    NSURL *url = [NSURL fileURLWithPath:path];
    
    return [NSData dataWithContentsOfURL:url];
}

@end
