//
//  DetailViewController.swift
//  MNAVChaptersExample
//
//  Created by Michael Nisi on 19/03/16.
//  Copyright © 2016 Michael Nisi. All rights reserved.
//

import UIKit
import os.log

private let log = OSLog(subsystem: "ink.codes.MNAVChapters", category: "app")

func chaptersFromAsset(asset: AVAsset) -> [MNAVChapter]? {
  return MNAVChapterReader.chapters(from: asset) as? [MNAVChapter]
}

func update(target: DetailViewController, url: URL) {
  let asset =  AVURLAsset(url: url, options: nil)
  
  guard let chapters = chaptersFromAsset(asset: asset) else {
    os_log("no chapters in asset: %@", log: log, type: .error, asset)
    return
  }
  
  dispatchPrecondition(condition: .onQueue(.main))
  
  target.sections = [chapters]
  target.collectionView.reloadData()
}

class DetailViewController: UICollectionViewController {
  
  private static var chapterCellID = "ChapterCellID"
  fileprivate var sections: [[MNAVChapter]] = [[]]
  
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
    
    os_log("using: %@", log: log, type: .debug, dir as CVarArg)
    
    let targetURL = dir.appendingPathComponent(url.lastPathComponent)
    
    guard !fm.fileExists(atPath: (targetURL.path)) else {
      return update(target: self, url: targetURL)
    }
    
    task = URLSession.shared.downloadTask(with: url as URL) { 
      [weak self] srcURL, res, er in
      guard er == nil else { 
        os_log("could not download: %@", log: log, type: .error, er! as CVarArg)
        return 
      }
      
      do {
        try fm.copyItem(at: srcURL!, to: targetURL)
      } catch let er {
        os_log("copy failed: %@", log: log, er as CVarArg)
      }
      
      guard let target = self else { return }
      
      update(target: target, url: targetURL)
    }
    
    task?.resume()
  }

  var detailItem: Item? {
    didSet {
      self.configureView()
    }
  }
}

// MARK: - UIViewController

extension DetailViewController {
  
  private func configureLayout() {
    let l = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
    l.itemSize = CGSize(width: 200, height: 200)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    collectionView.register(
      UINib(nibName: "ChapterCell", bundle: .main), 
      forCellWithReuseIdentifier:DetailViewController.chapterCellID)
    
    configureLayout()
  }
}

// MARK: - UICollectionViewDataSource

extension DetailViewController {
  
  override func collectionView(
    _ collectionView: UICollectionView, 
    numberOfItemsInSection section: Int) -> Int {
    return sections[section].count
  }
  
  override func collectionView(
    _ collectionView: UICollectionView, 
    cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: DetailViewController.chapterCellID, 
      for: indexPath
    ) as! ChapterCell
    let chapter = sections[indexPath.section][indexPath.row]
    cell.titleLabel?.text = chapter.title
    cell.imageView?.image = chapter.artwork
    
    return cell
  }
}
