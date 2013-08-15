//
//  ChaptersViewController.m
//  example
//
//  Created by Michael Nisi on 12.08.13.
//  Copyright (c) 2013 Michael Nisi. All rights reserved.
//

#import "ChaptersViewController.h"
#import <MNAVChapters.h>

@interface ChaptersViewController ()
@property (nonatomic) NSArray *chapters;
@property (nonatomic) NSOperationQueue *queue;
@end

@implementation ChaptersViewController

- (NSOperationQueue *)queue {
    if (!_queue) {
        _queue = [NSOperationQueue new];
    }
    return _queue;
}

- (void)setEpisode:(NSDictionary *)episode {
    _episode = episode;
    
    __weak UITableView *tableView = self.tableView;
    [self.queue addOperationWithBlock:^{
        NSURL *url = [NSURL URLWithString:[episode valueForKey:@"href"]];
        AVAsset *asset = [AVAsset assetWithURL:url];
        MNAVChapters *parser = [MNAVChapters new];
        _chapters = [parser chaptersFromAsset:asset];
        dispatch_async(dispatch_get_main_queue(), ^{
            [tableView reloadData];
        });
    }];
}

# pragma mark - UIViewController

- (void)didMoveToParentViewController:(UIViewController *)parent {
   if (!parent) _chapters = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.chapters.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MNAVChapter *chapter = [self.chapters objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier = @"chapterCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = chapter.title;
    cell.imageView.image = chapter.artwork;
    
    return cell;
}

@end
