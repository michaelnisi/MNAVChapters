# MNAVChapters - read chapter marks

The **MNAVChapters** iOS library reads chapter metadata of audiovisual assets. It reads chapters from [MPEG-4](http://en.wikipedia.org/wiki/MPEG-4_Part_14) and specifically [MP3](http://en.wikipedia.org/wiki/MP3) files. Although the [id3v2](http://id3.org/id3v2-chapters-1.0) standard specifies the chapter frame since 2005, I couldn't find a C or Objective-C library that parses this frame correctly.

This modest Objective-C implementation has been inspired by a [post](http://auphonic.com/blog/2013/07/03/chapter-marks-and-enhanced-podcasts/) over on the [auphonic](https://auphonic.com/) blog.

[![Build Status](https://secure.travis-ci.org/michaelnisi/MNAVChapters.svg)](http://travis-ci.org/michaelnisi/MNAVChapters)

## MNAVChapter

A chapter within a media file.

### Accessing Chapter Information

- `title`

The title of the chapter.

```objc
(nonatomic, copy) NSString *title;
```

- `url`

An URL string of the chapter.

```objc
(nonatomic, copy) NSString *url;
```

- `time`

The start time of the chapter.

```objc
(nonatomic) CMTime time;
```

- `duration`

The duration of the chapter.

```objc
(nonatomic) CMTime duration;
```

- `artwork`

An embedded chapter image.

```objc
(nonatomic) UIImage *artwork;
```

## MNAVChapterReader

The parser which reads [chapter](#mnavchapter) marks from timed audiovisual media. It attempts to read chapter information from assets with `"org.mp4ra"` or `"org.id3"` meta data formats.

### Reading Chapters from an Asset

- `+ chaptersFromAsset:`

Make sense of an `AVAsset` object and, if possible, return an array of [chapters](#mnavchapter).

```objc
+ (NSArray *)chaptersFromAsset:(AVAsset *)asset;
```

Here is an example of reading chapter marks from one the [auphonic](https://auphonic.com/) demo files:

```objc
AVAsset *asset = [self assetWithResource:@"auphonic_chapters_demo" ofType:@"mp3"];
NSArray *chapters = [[MNAVChapterReader chaptersFromAsset:asset];
```

## Install

Add the **MNAVChapters** Xcode project to your workspace or, to create a release build and use the object files in the build directory, do:

```
$ make
```

If you have [xctool](https://github.com/facebook/xctool) installed, you can also run the tests from the command-line:

```
$ make test
```

## Example

This repo contains an Xcode workspace to provide an easy to use example written in [Swift](https://swift.org/). When you are running the app for the first time and tap on one of the episodes, be patient, it will have to download the media files, which, depending on your network, might take some time. Once received, the files are kept in `"/Downloads"` and, on further requests, will load from there.

## License

[MIT License](https://raw.github.com/michaelnisi/MNAVChapters/master/LICENSE)
