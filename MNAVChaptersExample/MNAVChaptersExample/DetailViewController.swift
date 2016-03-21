//
//  DetailViewController.swift
//  MNAVChaptersExample
//
//  Created by Michael Nisi on 19/03/16.
//  Copyright © 2016 Michael Nisi. All rights reserved.
//

import UIKit

func chaptersFromAsset(asset: AVAsset) -> [MNAVChapter]? {
  return MNAVChapterReader.chaptersFromAsset(asset) as? [MNAVChapter]
}

func update(target: DetailViewController, url: NSURL) {
  let asset =  AVURLAsset(URL: url)
  guard let chapters = chaptersFromAsset(asset) else {
    return print("Oh snap!")
  }
  dispatch_async(dispatch_get_main_queue()) {
    target.chapters = chapters
    target.tableView.reloadData()
  }
}

class DetailViewController: UITableViewController {

  // MARK: - API

  var detailItem: Item? {
    didSet {
      self.configureView()
    }
  }

  // MARK: - Internals
  
  var task: NSURLSessionTask?

  func configureView() {
    guard let str = detailItem?.url else { return }
    guard let url = NSURL(string: str) else { return }
    guard url != task?.originalRequest?.URL else { return }
    
    task?.cancel()
    
    let fm = NSFileManager.defaultManager()
    let dir = try! fm.URLForDirectory(
      .DocumentDirectory,
      inDomain: .UserDomainMask,
      appropriateForURL: nil,
      create: true
    )
    let targetURL = dir.URLByAppendingPathComponent(url.lastPathComponent!)
    guard !fm.fileExistsAtPath((targetURL.path)!) else {
      return update(self, url: targetURL)
    }
    
    let sess = NSURLSession.sharedSession()
    task = sess.downloadTaskWithURL(url) { [weak self] srcURL, res, er in
      guard er == nil else { return print(er) }
      do {
        try fm.copyItemAtURL(srcURL!, toURL: targetURL)
      } catch let er {
        print(er)
      }
      guard let target = self else { return }
      update(target, url: targetURL)
    }
    task?.resume()
  }
  
  var chapters: [MNAVChapter]?
  
  // MARK: - Table View
  
  override func numberOfSectionsInTableView(
    tableView: UITableView
  ) -> Int {
    return 1
  }
  
  override func tableView(
    tableView: UITableView,
    numberOfRowsInSection section: Int
  ) -> Int {
    return chapters?.count ?? 0
  }
  
  override func tableView(
    tableView: UITableView,
    cellForRowAtIndexPath indexPath: NSIndexPath
    ) -> UITableViewCell {
    let id = "ChapterCellID"
    let cell = tableView.dequeueReusableCellWithIdentifier(
      id, forIndexPath: indexPath
    )
    let chapter = chapters![indexPath.row]
    cell.textLabel!.text = chapter.title
    cell.imageView?.image = chapter.artwork
    return cell
  }
}
