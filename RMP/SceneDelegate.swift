//
//  SceneDelegate.swift
//  RMP
//
//  Created by David Klopp on 02.01.20.
//  Copyright © 2020 David Klopp. All rights reserved.
//

import UIKit

#if targetEnvironment(macCatalyst)
let kResetToolbarItemIdentifier = NSToolbarItem.Identifier(rawValue: "ResetItem")
let kDoneToolbarItemIdentifier = NSToolbarItem.Identifier(rawValue: "DoneItem")
let kTitleToolbarItemIdentifier = NSToolbarItem.Identifier(rawValue: "TitleItem")
#endif


class SceneDelegate: UIResponder, UIWindowSceneDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let window = window else { return }
        guard let splitViewController = window.rootViewController as? UISplitViewController else { return }

        splitViewController.delegate = self

        // Mac specific layout.
        #if targetEnvironment(macCatalyst)
        splitViewController.primaryBackgroundStyle = .sidebar

        // Hide the titlebar and add a toolbar
        guard let windowScene = (scene as? UIWindowScene) else { return }
        if let titlebar = windowScene.titlebar {
            let toolbar = NSToolbar(identifier: "toolbar")
            toolbar.delegate = self
            toolbar.allowsUserCustomization = false

            titlebar.titleVisibility = .hidden
            titlebar.toolbar = toolbar
        }
        #else
        splitViewController.preferredDisplayMode = .allVisible
        splitViewController.view.backgroundColor = .lightGray
        #endif
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    // MARK: - Split view

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController else { return false }
        if topAsDetailController.basicNeed == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }
}

#if targetEnvironment(macCatalyst)
extension SceneDelegate: NSToolbarDelegate {
        func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {

            guard let window = window else { return nil }
            guard let splitViewController = window.rootViewController as? UISplitViewController else { return nil }
            guard let navigationController = splitViewController.viewControllers.first as? UINavigationController else { return nil }
            guard let masterController = navigationController.topViewController as? MasterViewController else { return nil }

            var item: UIBarButtonItem? = nil
            if itemIdentifier == kTitleToolbarItemIdentifier {
                item = UIBarButtonItem(title: "Reiss Motivation Profile", style: .plain, target: nil, action: nil)
            } else if itemIdentifier == kResetToolbarItemIdentifier {
                item = UIBarButtonItem(barButtonSystemItem: .refresh, target: masterController, action: #selector(masterController.resetTest))
            } else if itemIdentifier == kDoneToolbarItemIdentifier {
                item = UIBarButtonItem(title: NSLocalizedString("RESULT", comment: ""), style: .plain, target: masterController, action: #selector(masterController.finishTest))
            }
            return NSToolbarItem(itemIdentifier: itemIdentifier, barButtonItem: item!)
        }


        func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
            return [kResetToolbarItemIdentifier, NSToolbarItem.Identifier.flexibleSpace,
                    kTitleToolbarItemIdentifier, NSToolbarItem.Identifier.flexibleSpace,
                    kDoneToolbarItemIdentifier]
        }

        func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
            return self.toolbarDefaultItemIdentifiers(toolbar)
        }
    }
#endif

