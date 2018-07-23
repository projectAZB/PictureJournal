//
//  SettingsViewController.swift
//  PictureJournal
//
//  Created by Adam on 5/1/18.
//  Copyright © 2018 Adam. All rights reserved.
//

import Foundation
import UIKit
import LocalAuthentication

class SettingsViewController : BaseViewController, AuthenticateViewControllerDelegate
{
	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var syncButton: UIButton!
	@IBOutlet weak var enableTouchButton: UIButton!
	
	private var touchIdEnabled : Bool = false {
		didSet {
			if touchIdEnabled {
				self.enableTouchButton.setImage(Images.DisableTouchID, for: .normal)
			}
			else {
				self.enableTouchButton.setImage(Images.EnableTouchID, for: .normal)
			}
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.cancelButton.setImage(Images.CancelWhite.addImagePadding(x: 16.0, y: 16.0), for: .normal)
		self.touchIdEnabled = UserDefaults.standard.bool(forKey: Keys.TouchID)
	}
	
	@IBAction func onCancelPressed(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func onSyncPressed(_ sender: Any) {
		self.activityIndicatorView = UIViewController.displayActivityIndicatorOnView(self.view)
		EntriesManager.shared().sync { (success, error) in
			UIViewController.removeActivityIndicator(self.activityIndicatorView)
		}
	}
	
	@IBAction func onTouchPressed(_ sender: Any) {
		if self.touchIdEnabled { //"disable" was touched
			self.touchIdEnabled = false
			UserDefaults.standard.set(false, forKey: Keys.TouchID) //disable touch id
		}
		else {
			let context = LAContext()
			var error : NSError?
			if !context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
				self.present(Alerts.noTouchIdAlert(), animated: true, completion: nil)
				return
			}
			
			let authVC : AuthenticateViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "auth") as! AuthenticateViewController
			authVC.delegate = self
			authVC.fromSettings = true
			authVC.modalTransitionStyle = .crossDissolve
			self.present(authVC, animated: true) {
				
			}
		}
	}
	
	func finished(success: Bool) {
		if success {
			self.touchIdEnabled = true
			UserDefaults.standard.set(true, forKey: Keys.TouchID) //set touch id enabled
		}
	}
	
}
