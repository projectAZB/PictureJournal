//
//  BaseViewController.swift
//  PictureJournal
//
//  Created by Adam on 4/18/18.
//  Copyright © 2018 Adam. All rights reserved.
//

import UIKit

class BaseViewController : UIViewController
{
	var activityIndicatorView : UIView?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if let nav = self.navigationController {
			nav.navigationBar.barTintColor = Colors.AlizarinCrimson
			nav.navigationBar.backgroundColor = Colors.AlizarinCrimson
			nav.navigationBar.isTranslucent = false
		}
	}
	
}
