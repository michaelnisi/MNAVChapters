//
//  MNAVChapters.m
//  MNAVChapters
//
//  Created by Michael Nisi on 02.08.13.
//  Copyright (c) 2013 Michael Nisi. All rights reserved.
//

#import "MNAVChapterReader.h"
#import <UIKit/UIKit.h>

# pragma mark - MNAVChapterReader

static NSString *const MNAVMetadataFormatApple = @"com.apple.itunes";
static NSString *const MNAVMetadataFormatMP4 = @"org.mp4ra";
static NSString *const MNAVMetadataFormatID3 = @"org.id3";

@implementation MNAVChapterReader

- (NSArray *)chaptersFromAsset:(AVAsset *)asset {
    NSArray *formats = asset.availableMetadataFormats;
    id <MNAVChapterReader> parser = nil;
    NSArray *result = nil;
    for (NSString *format in formats) {
        if ([format isEqualToString:MNAVMetadataFormatMP4]) {
            parser = [MNAVChapterReaderMP4 new];
        } else if ([format isEqualToString:MNAVMetadataFormatID3]) {
            parser = [MNAVChapterReaderMP3 new];
        }
        result = [parser chaptersFromAsset:asset];
    }
    return result;
}

@end

# pragma mark - MNAVChapter

@implementation MNAVChapter

- (BOOL)isEqual:(id)object {
    return [self isEqualToChapter:object];
}

- (BOOL)isEqualToChapter:(MNAVChapter *)aChapter {
    return [self.title isEqualToString:aChapter.title]
        && (self.url == aChapter.url || [self.url isEqualToString:aChapter.url])
        && CMTIME_COMPARE_INLINE(self.time, ==, aChapter.time);
        // && CMTIME_COMPARE_INLINE(self.duration, ==, aChapter.duration);
}

- (MNAVChapter *)initWithTime:(CMTime)time duration:(CMTime)duration {
    self = [super init];
    if (self) {
        self.time = time;
        self.duration = duration;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"chapter: %@, %@, %lld, %lld]",
            self.title, self.url, self.time.value, self.duration.value];
}

+ (MNAVChapter *)chapterWithTime:(CMTime)time duration:(CMTime)duration {
    return [[self alloc] initWithTime:time duration:duration];
}

@end

# pragma mark - MNAVChapterReaderMP4

@implementation MNAVChapterReaderMP4
- (NSArray *)chaptersFromAsset:(AVAsset *)asset {
    NSArray *languages = [self languagesForAsset:asset];
    NSArray *groups = [asset chapterMetadataGroupsBestMatchingPreferredLanguages:languages];
    NSUInteger chapterCount = groups.count;
    NSMutableArray *chapters = [[NSMutableArray alloc] initWithCapacity:chapterCount];
    for (AVTimedMetadataGroup *group in groups) {
        MNAVChapter *chapter = [MNAVChapter new];
        chapter.title = [self titleFromGroup:group];
        chapter.artwork = [self imageFromGroup:group];
        chapter.url = [self urlFromGroup:group forTitle:chapter.title];
        chapter.time = [self timeFromGroup:group];
        chapter.duration = [self durationFromGroup:group];
        [chapters addObject:chapter];
    }
    return chapters;
}

- (NSArray *)languagesForAsset:(AVAsset *)asset {
    NSArray *preferred = [NSLocale preferredLanguages];
    NSMutableArray *languages = [NSMutableArray arrayWithArray:preferred];
    NSArray *locales = [asset availableChapterLocales];
    for (NSLocale *locale in locales) {
        [languages addObject:[locale localeIdentifier]];
    }
    return languages;
}

- (CMTime)timeFromGroup:(AVTimedMetadataGroup *)group {
    NSArray *items = [self itemsFromArray:group.items withKey:@"title"];
    AVMetadataItem *item = items[0];
    return item.time;
}

- (CMTime)durationFromGroup:(AVTimedMetadataGroup *)group {
    NSArray *items = [self itemsFromArray:group.items withKey:@"title"];
    AVMetadataItem *item = items[0];
    return item.duration;
}

- (NSString *)urlFromGroup:(AVTimedMetadataGroup *)group forTitle:(NSString *)title {
    NSArray *items = [self itemsFromArray:group.items withKey:@"title"];
    NSString *href = nil;
    for (AVMetadataItem *item in items) {
        if ([item.stringValue isEqualToString:title] && item.extraAttributes) {
            href = item.extraAttributes[@"HREF"];
            if (href) break;
        }
    }
    return href;
}

- (NSString *)titleFromGroup:(AVTimedMetadataGroup *)group {
    AVMetadataItem *item = [self itemsFromArray:group.items withKey:@"title"][0];
    return item.stringValue;
}

- (UIImage *)imageFromGroup:(AVTimedMetadataGroup *)group {
    NSArray *itemArray = [self itemsFromArray:group.items withKey:@"artwork"];
    if ([itemArray count] > 0) {
        AVMetadataItem *item = itemArray[0];
        return [UIImage imageWithData:item.dataValue];
    }
    return NULL;
}

- (NSArray *)itemsFromArray:(NSArray *)items withKey:(NSString *)key {
    return [AVMetadataItem metadataItemsFromArray:items withKey:key keySpace:nil];
}
@end

# pragma mark - MNAVChapterReaderMP3

#define SUBDATA(data,loc,len) [data subdataWithRange:NSMakeRange(loc, len)]

typedef NS_ENUM(NSUInteger, ID3Frame) {
    ID3FrameEncoding = 1,
    ID3FrameShortDescription = 1,
    ID3FramePictureType = 1,
    ID3FrameFlags,
    ID3FrameLanguage,
    ID3FrameSize,
    ID3FrameID = 4,
    ID3FrameFrame = 10
};

typedef NS_ENUM(NSUInteger, ID3Header) {
    ID3HeaderSize = 4
};

typedef NS_ENUM(NSUInteger, ID3TextEncoding) {
    ID3TextEncodingISO,
    ID3TextEncodingUTF16
};

static NSString *const MNAVMetadataID3MetadataKeyChapter = @"CHAP";

unsigned long is_set(char *bytes, long size);
long btoi(char* bytes, long size, long offset);

@implementation MNAVChapterReaderMP3

- (NSArray *)chaptersFromAsset:(AVAsset *)asset {
    NSArray *its = [asset metadataForFormat:MNAVMetadataFormatID3];
    NSArray *items = [AVMetadataItem metadataItemsFromArray:its
                                                    withKey:MNAVMetadataID3MetadataKeyChapter
                                                   keySpace:MNAVMetadataFormatID3];
    
    NSMutableArray *chapters = [NSMutableArray new];
    for (AVMetadataItem *item in items) {
        [chapters addObject:[self chapterFromFrame:item.dataValue]];
    }
    
    return [chapters sortedArrayUsingComparator:
            ^NSComparisonResult(MNAVChapter *a, MNAVChapter *b) {
                return CMTimeCompare(a.time, b.time);
            }];
}

- (MNAVChapter *)chapterFromFrame:(NSData *)data {
    NSUInteger index = [self dataToTermInData:data].length;
    
    NSData *startTimeData = SUBDATA(data, index, ID3HeaderSize);
    NSData *endTimeData = SUBDATA(data, index += ID3HeaderSize, ID3HeaderSize);
    NSData *startOffsetData = SUBDATA(data, index += ID3HeaderSize, ID3HeaderSize);
    NSData *endOffsetData = SUBDATA(data, index += ID3HeaderSize, ID3HeaderSize);
    
    NSInteger startTime = btoi((char *)startTimeData.bytes, startTimeData.length, 0);
    NSInteger endTime = btoi((char *)endTimeData.bytes, endTimeData.length, 0);
    
    BOOL hasStartOffset = is_set((char *)startOffsetData.bytes, startOffsetData.length);
    assert(!hasStartOffset);
    // NSUInteger startOffset = btoi((char *)startOffsetData.bytes, startOffsetData.length, 0);
    
    BOOL hasEndOffset = is_set((char *)endOffsetData.bytes, endOffsetData.length);
    assert(!hasEndOffset);
    // NSUInteger endOffset = btoi((char *)endOffsetData.bytes, endOffsetData.length, 0);
    
    MNAVChapter *chapter = [MNAVChapter new];
    
    chapter.time = CMTimeMake(startTime, 1000);
    chapter.duration = CMTimeMake(endTime - startTime, 1000);
    chapter.title = [self titleInData:data];
    chapter.url = [self userURLInData:data];
    chapter.artwork = [self imageInData:data];
    
    return chapter;
}

- (UIImage *)imageInData:(NSData *)data {
    UIImage *result = nil;
    
    @try {
        NSRange range = [self rangeOfFrameWithID:AVMetadataID3MetadataKeyAttachedPicture inData:data];
        unsigned long loc = range.location;
        
        NSData *sizeData = SUBDATA(data, loc + ID3FrameID, ID3FrameSize);
        NSInteger size =  btoi((char *)sizeData.bytes, sizeData.length, 0);
        
        // NSData *encData = SUBDATA(data, loc + ID3_FRAME_SIZE, ID3_FRAME_ENCODING);
        // NSInteger encValue = btoi((char *)encData.bytes, encData.length, 0);
        // NSInteger encoding = [self textEncoding:encValue];
        
        NSData *content = SUBDATA(data, loc + ID3FrameFrame + ID3FrameEncoding, size - ID3FrameEncoding);
        
        NSData *mimeTypeData = [self dataToTermInData:content];
        // NSString *mimeType = [NSString stringWithUTF8String:mimeTypeData.bytes];
        
        NSUInteger index = mimeTypeData.length + ID3FrameEncoding + ID3FramePictureType;
        
        
        index = index + [self dataToTermInData:content].length + 2; // WTF?
        
        NSData *imageData = SUBDATA(content, index, content.length - index);
        result = [UIImage imageWithData:imageData];
    }
    @catch (NSException *exception) {
        //
    }
    @finally {
        return result;
    }
}

- (NSString *)userURLInData:(NSData *)data {
    NSString *result = nil;
    
    @try {
        NSRange range = [self rangeOfFrameWithID:AVMetadataID3MetadataKeyUserURL inData:data];
        unsigned long loc = range.location;
        
        NSData *sizeData = SUBDATA(data, loc + ID3FrameID, ID3FrameSize);
        NSInteger size =  btoi((char *)sizeData.bytes, sizeData.length, 0);
        
        NSData *encData = SUBDATA(data, loc + ID3FrameSize, ID3FrameEncoding);
        NSInteger encValue = btoi((char *)encData.bytes, encData.length, 0);
        NSInteger encoding = [self textEncoding:encValue];
        
        NSData *content = SUBDATA(data, loc + ID3FrameFrame + ID3FrameEncoding, size - ID3FrameEncoding);
        NSUInteger index = [self dataToTermInData:content].length;
        NSData *url = SUBDATA(content, index, size - index - ID3FrameEncoding);
        NSString *str = [[NSString alloc] initWithBytes:url.bytes length:url.length encoding:encoding];
        
        result = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    } @catch (NSException * e) {
        //
    } @finally {
        return result;
    }
}

- (NSString *)titleInData:(NSData *)data {
    NSString *result = nil;
    @try {
        NSRange range = [self rangeOfFrameWithID:AVMetadataID3MetadataKeyTitleDescription inData:data];
        unsigned long loc = range.location;
        NSData *sizeData = SUBDATA(data, loc + ID3FrameID, ID3FrameSize);
        NSUInteger size =  btoi((char *)sizeData.bytes, sizeData.length, 0);
        NSData *titleData = SUBDATA(data, loc + ID3FrameFrame + ID3FrameEncoding, size - ID3FrameEncoding);
        result = [[NSString alloc] initWithBytes:titleData.bytes
                                          length:titleData.length
                                        encoding:NSUTF16StringEncoding];
    }
    @catch (NSException *exception) {
        //
    }
    @finally {
        return result;
    }
}

- (NSRange)rangeOfFrameWithID:(NSString *)frameID inData:(NSData *)data {
    NSData *d = [NSData dataWithBytes:[frameID UTF8String] length:ID3FrameID];
    return [data rangeOfData:d options:NSDataSearchBackwards range:NSMakeRange(0, data.length)];
}

- (NSData *)dataToTermInData:(NSData *)data {
    NSUInteger maxLength = 1;
    uint8_t buffer[maxLength];
    BOOL terminated = NO;
    NSInputStream *stream = [NSInputStream inputStreamWithData:data];
    NSMutableData *result = [NSMutableData new];
    [stream open];
    while([stream read:buffer maxLength:maxLength] > 0 && !terminated) {
        [result appendBytes:buffer length:1];
        terminated = *(char *)buffer == '\0';
    }
    [stream close];
    
    return result;
}

- (NSInteger)textEncoding:(NSInteger)i {
    return i == ID3TextEncodingISO ? NSISOLatin1StringEncoding : NSUTF16StringEncoding;
}

@end

#pragma mark - utils

unsigned long is_set(char *bytes, long size) {
    unsigned int result = 0x00;
    while (size-- && !result) {
        result = bytes[size] != '\xff';
    }
    return result;
}

long btoi(char* bytes, long size, long offset) {
    int i;
    unsigned int result = 0x00;
    for(i = 0; i < size; i++) {
        result = result << 8;
        result = result | (unsigned char) bytes[offset + i];
    }
    return result;
}
