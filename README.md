# MNAVChapters - read chapter metadata of audiovisual assets

[![Version](http://cocoapod-badges.herokuapp.com/v/MNAVChapters/badge.png)](http://cocoadocs.org/docsets/MNAVChapters)
[![Platform](http://cocoapod-badges.herokuapp.com/p/MNAVChapters/badge.png)](http://cocoadocs.org/docsets/MNAVChapters)

The `MNAVChapters` iOS library reads chapter metadata of audiovisual assets. It reads chapters from [MPEG-4](http://en.wikipedia.org/wiki/MPEG-4_Part_14) and specifically [MP3](http://en.wikipedia.org/wiki/MP3) files. Although the [id3v2](http://id3.org/id3v2-chapters-1.0) standard specifies the chapter frame since 2005, I couldn't find a C or Objective-C library that parses this frame correctly.

This modest implementation in Objective-C has been inspired by a [post](http://auphonic.com/blog/2013/07/03/chapter-marks-and-enhanced-podcasts/) over on the [auphonic](https://auphonic.com/) blog.

## Usage

    AVAsset *asset = [self assetWithResource:@"auphonic_chapters_demo" ofType:@"mp3"];
    NSArray *chapters = [[MNAVChapterReader new] chaptersFromAsset:asset];

Please the note that this is blocking and thus should not run in the main loop.

## MNAVChapter

    @interface MNAVChapter : NSObject
    @property (nonatomic) NSString *title;
    @property (nonatomic) NSString *url;
    @property (nonatomic) CMTime time;
    @property (nonatomic) CMTime duration;
    @property (nonatomic) UIImage *artwork;
    - (BOOL)isEqualToChapter:(MNAVChapter *)aChapter;
    - (MNAVChapter *)initWithTime:(CMTime)time duration:(CMTime)duration;
    + (MNAVChapter *)chapterWithTime:(CMTime)time duration:(CMTime)duration;
    @end

## Installation

MNAVChapters is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

    pod "MNAVChapters"

## License

[MIT License](https://raw.github.com/michaelnisi/metata/master/LICENSE)

