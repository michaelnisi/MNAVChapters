//
//  MNMetadataParserTests.m
//  metataTests
//
//  Created by Michael Nisi on 01.08.13.
//  Copyright (c) 2013 Michael Nisi. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <AVFoundation/AVFoundation.h>
#import "MNAVChapterReader.h"

@interface ChaptersTests : XCTestCase
@property (nonatomic) NSArray *auphonic_chapters;
@end

@implementation ChaptersTests

- (NSArray *)auphonic_chapters {
    if (!_auphonic_chapters) {
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
                                     duration:CMTimeMake(52500, 3000)]
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
        
        _auphonic_chapters = chapters;
    }
    
    return _auphonic_chapters;
}

- (void)testMP3 {
    AVAsset *asset = [self assetWithResource:@"auphonic_chapters_demo" ofType:@"mp3"];
    MNAVChapterReader *parser = [MNAVChapterReader new];
    NSArray *actual = [parser chaptersFromAsset:asset];
    NSArray *expected = self.auphonic_chapters;
    XCTAssertTrue([actual isEqualToArray:expected], @"");
}

- (void)testMP4 {
    AVAsset *asset = [self assetWithResource:@"auphonic_chapters_demo" ofType:@"m4a"];
    MNAVChapterReader *parser = [MNAVChapterReader new];
    NSArray *actual = [parser chaptersFromAsset:asset];
    NSArray *expected = self.auphonic_chapters;
    XCTAssertTrue([actual isEqualToArray:expected], @"");
}

- (AVAsset *)assetWithResource:(NSString *)resource ofType:(NSString *)type {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:resource ofType:type];
    NSURL *url = [NSURL fileURLWithPath:path];
    
    return [AVURLAsset assetWithURL:url];
}

@end
