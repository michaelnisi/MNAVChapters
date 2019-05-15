//
//  MasterViewController.swift
//  MNAVChaptersExample
//
//  Created by Michael Nisi on 19/03/16.
//  Copyright © 2016 Michael Nisi. All rights reserved.
//

import UIKit

struct Item: Codable {
  let title: String
  let url: String
}

func loadItems(name: String) throws -> [Item] {
  let bundle = Bundle.main
  let path = bundle.path(forResource: name, ofType: "json")!
  let url = URL(fileURLWithPath: path)
  let data = try Data(contentsOf: url)
  let decoder = JSONDecoder()

  return try decoder.decode([Item].self, from: data)
}

class MasterViewController: UITableViewController {

  var detailViewController: DetailViewController? = nil

  lazy var items: [Item] = try! loadItems(name: "episodes")

  override func viewDidLoad() {
    super.viewDidLoad()

    if let split = self.splitViewController {
      let controllers = split.viewControllers
      self.detailViewController = (
        controllers[controllers.count - 1] as! UINavigationController
      ).topViewController as? DetailViewController
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
    super.viewWillAppear(animated)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK: - Segues

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showDetail" {
      if let indexPath = self.tableView.indexPathForSelectedRow {
        let item = items[indexPath.row]
        let controller = (
          segue.destination as! UINavigationController
        ).topViewController as! DetailViewController
        controller.detailItem = item
        controller.navigationItem.leftBarButtonItem =
          self.splitViewController?.displayModeButtonItem
        controller.navigationItem.leftItemsSupplementBackButton = true
      }
    }
  }

  // MARK: - Table View

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }


  override func tableView(
    _ tableView: UITableView,
    numberOfRowsInSection section: Int
  ) -> Int {
    return items.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let id = "EpisodeCellID"
    let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
    let item = items[indexPath.row]
    cell.textLabel!.text = item.title
    return cell
  }
}
