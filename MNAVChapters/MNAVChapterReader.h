//
//  MNAVChapters.h
//  MNAVChapters
//
//  Created by Michael Nisi on 02.08.13.
//  Copyright (c) 2013 Michael Nisi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CMTime.h>
#import <AVFoundation/AVFoundation.h>

@interface MNAVChapter : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *url;
@property (nonatomic) CMTime time;
@property (nonatomic) CMTime duration;
@property (nonatomic) UIImage *artwork;
- (BOOL)isEqualToChapter:(MNAVChapter *)aChapter;
- (MNAVChapter *)initWithTime:(CMTime)time duration:(CMTime)duration;
+ (MNAVChapter *)chapterWithTime:(CMTime)time duration:(CMTime)duration;
@end

@interface MNAVChapterReader : NSObject
+ (NSArray *)chaptersFromAsset:(AVAsset *)asset;
@end

# pragma mark - Internal

@protocol MNAVChapterReader <NSObject>
- (NSArray *)chaptersFromAsset:(AVAsset *)asset;
@end

@interface MNAVChapterReaderMP3 : NSObject <MNAVChapterReader>
- (MNAVChapter *)chapterFromFrame:(NSData *)data;
@end

@interface MNAVChapterReaderMP4 : NSObject <MNAVChapterReader>
@end
