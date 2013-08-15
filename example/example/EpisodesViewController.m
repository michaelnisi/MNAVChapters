//
//  ViewController.m
//  example
//
//  Created by Michael Nisi on 11.08.13.
//  Copyright (c) 2013 Michael Nisi. All rights reserved.
//

#import "EpisodesViewController.h"
#import "ChaptersViewController.h"

@interface EpisodesViewController ()
@property (nonatomic) NSArray *items;
@end

@implementation EpisodesViewController

- (NSArray *)items {
    if (!_items) {
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSString *path = [bundle pathForResource:@"episodes" ofType:@"plist"];
        NSURL *url = [NSURL fileURLWithPath:path];
        _items = [NSArray arrayWithContentsOfURL:url];
    }
    return _items;
}

# pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
}

# pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *item = [self.items objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier = @"episodeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [item objectForKey:@"title"];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toChapters"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        ChaptersViewController *dest = segue.destinationViewController;
        dest.episode = self.items[indexPath.row];
    }
}

@end
