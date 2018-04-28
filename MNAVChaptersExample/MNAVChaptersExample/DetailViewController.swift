//
//  DetailViewController.swift
//  MNAVChaptersExample
//
//  Created by Michael Nisi on 19/03/16.
//  Copyright © 2016 Michael Nisi. All rights reserved.
//

import UIKit

func chaptersFromAsset(asset: AVAsset) -> [MNAVChapter]? {
  return MNAVChapterReader.chapters(from: asset) as? [MNAVChapter]
}

func update(target: DetailViewController, url: URL) {
  let asset =  AVURLAsset(url: url, options: nil)
  guard let chapters = chaptersFromAsset(asset: asset) else {
    return print("Oh snap!")
  }
  DispatchQueue.main.async  {
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
  
  var task: URLSessionTask?

  func configureView() {
    guard let str = detailItem?.url else { return }
    guard let url = URL(string: str) else { return }
    guard url != task?.originalRequest?.url else { return }
    
    task?.cancel()
    
    let fm = FileManager.default
    let dir = try! fm.url(
      for: .cachesDirectory,
      in: .userDomainMask,
      appropriateFor: nil,
      create: true
    )
    print(dir)
    let targetURL = dir.appendingPathComponent(url.lastPathComponent)
    guard !fm.fileExists(atPath: (targetURL.path)) else {
      return update(target: self, url: targetURL)
    }
    
    let sess = URLSession.shared
    task = sess.downloadTask(with: url as URL) { [weak self] srcURL, res, er in
      guard er == nil else { return print(er!) }
      do {
        try fm.copyItem(at: srcURL!, to: targetURL)
      } catch let er {
        print(er)
      }
      guard let target = self else { return }
      update(target: target, url: targetURL)
    }
    task?.resume()
  }
  
  var chapters: [MNAVChapter]?
  
  // MARK: - Table View
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(
    _ tableView: UITableView,
    numberOfRowsInSection section: Int
  ) -> Int {
    return chapters?.count ?? 0
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let id = "ChapterCellID"
    let cell = tableView.dequeueReusableCell(
      withIdentifier: id, for: indexPath as IndexPath
    )
    let chapter = chapters![indexPath.row]
    cell.textLabel?.text = chapter.title
    cell.imageView?.image = chapter.artwork
    return cell
  }
}
