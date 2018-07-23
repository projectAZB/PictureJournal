//
//  AppDelegate.swift
//  PictureJournal
//
//  Created by Adam on 4/18/18.
//  Copyright © 2018 Adam. All rights reserved.
//

import UIKit
import CloudKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?


	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		EntriesManager.shared().readEntriesFromFile()
		let _ = CloudManager.shared()
		
		self.window = UIWindow(frame: UIScreen.main.bounds)
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let initialVC : UIViewController
		if UserDefaults.standard.bool(forKey: Keys.TouchID) { //check to see if touch id is enabled
			initialVC = storyboard.instantiateViewController(withIdentifier: StoryboardVCIds.AuthenticateViewController)
		}
		else {
			initialVC = storyboard.instantiateViewController(withIdentifier: StoryboardVCIds.NavViewController)
		}
		self.window?.rootViewController = initialVC
		//sets our window up in front
		self.window?.makeKeyAndVisible()
		
		application.registerForRemoteNotifications()
		
		CloudManager.shared().registerForEntrySilentSubscription()
		
		return true
	}
	
	func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
		let aps = userInfo["aps"] as! [String : Any]
		
		if let ca_int = aps["content-available"] as? Int, ca_int == 1 {
			//pull data
			CloudManager.shared().fetchEntriesWithCompletionHandler { (success, error) in
				DispatchQueue.main.async {
					if success {
						if let topController = UIApplication.shared.keyWindow?.rootViewController {
							if let nav = topController as? UINavigationController {
								if let homeVC = nav.visibleViewController as? HomeViewController {
									homeVC.resetEntries()
									completionHandler(.newData)
									return
								}
							}
						}
						print("Reloaded Entries")
						completionHandler(.newData)
						return
					}
					else {
						print("Error getting entries \(error?.localizedDescription ?? "Nothing")")
						completionHandler(.failed)
						return
					}
				}
			}
		}
	}
	
	func unlock() {
		guard let window = UIApplication.shared.keyWindow,
			let rootViewController = window.rootViewController else {
			return
		}
		
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let vc = storyboard.instantiateViewController(withIdentifier: StoryboardVCIds.NavViewController)
		vc.view.frame = rootViewController.view.frame
		vc.view.layoutIfNeeded()
		
		UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
			window.rootViewController = vc
		}, completion: { completed in
			window.makeKeyAndVisible()
		})
	}
}

