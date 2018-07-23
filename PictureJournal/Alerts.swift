//
//  Alerts.swift
//  PictureJournal
//
//  Created by Adam on 5/1/18.
//  Copyright © 2018 Adam. All rights reserved.
//

import Foundation
import UIKit

struct Alerts {
	
	static func missingPictureAlert() -> UIAlertController {
		let alert = UIAlertController(title: "Picture Required", message: "Add a picture to save", preferredStyle: .alert)
		let ok : UIAlertAction = UIAlertAction(title: "Ok", style: .default) { (action) in
		}
		alert.addAction(ok)
		return alert
	}
	
	static func missingEntryAlert() -> UIAlertController {
		let alert = UIAlertController(title: "Entry Required", message: "Add a text entry to save", preferredStyle: .alert)
		let ok : UIAlertAction = UIAlertAction(title: "Ok", style: .default) { (action) in
		}
		alert.addAction(ok)
		return alert
	}
	
	static func wrongTouchIdAlert() -> UIAlertController {
		let alert = UIAlertController(title: "TouchID Authentication Failed", message: nil, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default))
		return alert
	}
	
	static func noTouchIdAlert() -> UIAlertController {
		let alert = UIAlertController(title: "TouchID Capability Required", message: "Your device doesn't have TouchID, so this feature is unavailable", preferredStyle: .alert)
		let ok : UIAlertAction = UIAlertAction(title: "Ok", style: .default) { (action) in
		}
		alert.addAction(ok)
		return alert
	}
	
	static func missingTagsAlert() -> UIAlertController {
		let alert = UIAlertController(title: "Tags Required", message: "Add tags to save", preferredStyle: .alert)
		let ok : UIAlertAction = UIAlertAction(title: "Ok", style: .default) { (action) in
		}
		alert.addAction(ok)
		return alert
	}
	
	static func iCloudSignedOutAlert() -> UIAlertController {
		let alert = UIAlertController(title: "You aren't signed into iCloud, if you want to do so, click Settings", message: nil, preferredStyle: .alert)
		let yes : UIAlertAction = UIAlertAction(title: "Settings", style: .default) { (action) in
			let settingsUrl : NSURL? = NSURL(string: UIApplicationOpenSettingsURLString)
			if let url = settingsUrl {
				DispatchQueue.main.async {
					UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
				}
			}
		}
		let no : UIAlertAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
		alert.addAction(yes)
		alert.addAction(no)
		return alert
	}
	
	static func noPhotoAccessAlert() -> UIAlertController {
		let alert = UIAlertController(title: "You denied access to this application, if you want to change this tap yes to go to settings.", message: nil, preferredStyle: .alert)
		let yes : UIAlertAction = UIAlertAction(title: "Yes", style: .default) { (action) in
			let settingsUrl : NSURL? = NSURL(string: UIApplicationOpenSettingsURLString)
			if let url = settingsUrl {
				DispatchQueue.main.async {
					UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
				}
			}
		}
		let no : UIAlertAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
		alert.addAction(yes)
		alert.addAction(no)
		return alert
	}
}
