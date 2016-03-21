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

  func application(
    application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?
  ) -> Bool {
    let svc = self.window!.rootViewController as! UISplitViewController
    let i = svc.viewControllers.count - 1
    let nav = svc.viewControllers[i] as! UINavigationController
    nav.topViewController!.navigationItem.leftBarButtonItem = svc.displayModeButtonItem()
    svc.delegate = self
    svc.preferredDisplayMode = .AllVisible
    return true
  }

  // MARK: - Split view

  func splitViewController(
    splitViewController: UISplitViewController,
    collapseSecondaryViewController secondaryViewController:UIViewController,
    ontoPrimaryViewController primaryViewController:UIViewController
  ) -> Bool {
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

