//
//  AuthenticateViewController.swift
//  PictureJournal
//
//  Created by Adam on 5/3/18.
//  Copyright © 2018 Adam. All rights reserved.
//

import Foundation
import UIKit
import LocalAuthentication

protocol AuthenticateViewControllerDelegate : AnyObject
{
	func finished(success : Bool)
}

class AuthenticateViewController : UIViewController
{
	weak var delegate : AuthenticateViewControllerDelegate?
	
	var fromSettings : Bool = false
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.authenticateUser()
	}
	
	func authenticateUser() {
		let context = LAContext()
		var error: NSError?
		
		if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
			let reason = "TouchID is needed in order to access journal entries"
			
			context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
				[unowned self] success, authenticationError in
				
				DispatchQueue.main.async {
					if success {
						self.delegate?.finished(success: true)
						self.dismissAuth()
					} else {
						self.present(Alerts.wrongTouchIdAlert(), animated: true, completion: {
							self.delegate?.finished(success: false)
							self.dismissAuth()
						})
					}
				}
			}
		}
		else {
			DispatchQueue.main.async {
				self.present(Alerts.noTouchIdAlert(), animated: true) {
					self.delegate?.finished(success: false)
					self.dismissAuth()
				}
			}
		}
	}
	
	func dismissAuth() {
		if fromSettings {
			self.dismiss(animated: true, completion: nil)
		}
		else {
			(UIApplication.shared.delegate as! AppDelegate).unlock()
		}
	}
}
