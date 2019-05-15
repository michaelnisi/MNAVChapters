//
//  AppDelegate.swift
//  MNAVChaptersExample
//
//  Created by Michael Nisi on 19/03/16.
//  Copyright © 2016 Michael Nisi. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    let svc = self.window!.rootViewController as! UISplitViewController
    let i = svc.viewControllers.count - 1
    let nav = svc.viewControllers[i] as! UINavigationController
    nav.topViewController!.navigationItem.leftBarButtonItem = svc.displayModeButtonItem
    svc.delegate = self
    svc.preferredDisplayMode = .allVisible
    return true
  }

  // MARK: - Split view

  func splitViewController(_ splitViewController: UISplitViewController,
                           collapseSecondary secondaryViewController: UIViewController,
                           onto primaryViewController: UIViewController) -> Bool {
    guard let sec = secondaryViewController as? UINavigationController else {
      return false
    }
    guard let top = sec.topViewController as? DetailViewController else {
      return false
    }
    if top.detailItem == nil {
      return true
    }
    return false
  }
}

