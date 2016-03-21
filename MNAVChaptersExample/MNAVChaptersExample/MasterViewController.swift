//
//  MasterViewController.swift
//  MNAVChaptersExample
//
//  Created by Michael Nisi on 19/03/16.
//  Copyright © 2016 Michael Nisi. All rights reserved.
//

import UIKit

struct Item {
  let title: String
  let url: String
}

func loadItems(name: String) -> [Item] {
  let bundle = NSBundle.mainBundle()
  let path = bundle.pathForResource(name, ofType: "json")!
  let url = NSURL(fileURLWithPath: path)
  let data = NSData(contentsOfURL: url)
  let json = try! NSJSONSerialization.JSONObjectWithData(
    data!, options: .AllowFragments) as! NSArray
  return json.map {
    let title = $0["title"] as! String
    let url = $0["url"] as! String
    return Item(title: title, url: url)
  }
}

class MasterViewController: UITableViewController {

  var detailViewController: DetailViewController? = nil

  lazy var items: [Item] = loadItems("episodes")

  override func viewDidLoad() {
    super.viewDidLoad()

    if let split = self.splitViewController {
      let controllers = split.viewControllers
      self.detailViewController = (
        controllers[controllers.count - 1] as! UINavigationController
      ).topViewController as? DetailViewController
    }
  }

  override func viewWillAppear(animated: Bool) {
    self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
    super.viewWillAppear(animated)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK: - Segues

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showDetail" {
      if let indexPath = self.tableView.indexPathForSelectedRow {
        let item = items[indexPath.row]
        let controller = (
          segue.destinationViewController as! UINavigationController
        ).topViewController as! DetailViewController
        controller.detailItem = item
        controller.navigationItem.leftBarButtonItem =
          self.splitViewController?.displayModeButtonItem()
        controller.navigationItem.leftItemsSupplementBackButton = true
      }
    }
  }

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
    return items.count
  }

  override func tableView(
    tableView: UITableView,
    cellForRowAtIndexPath indexPath: NSIndexPath
  ) -> UITableViewCell {
    let id = "EpisodeCellID"
    let cell = tableView.dequeueReusableCellWithIdentifier(id, forIndexPath: indexPath
    )
    let item = items[indexPath.row]
    cell.textLabel!.text = item.title
    return cell
  }
}
