//
//  Constants.swift
//  PictureJournal
//
//  Created by Adam on 4/18/18.
//  Copyright © 2018 Adam. All rights reserved.
//

import Foundation
import UIKit

struct Filenames {
	static let Entries : String = "entries.json"
}

struct StoryboardVCIds {
	static let EntryViewController : String = "entry"
	static let SettingsViewController : String = "settings"
	static let MapViewController : String = "map"
	static let AuthenticateViewController : String = "auth"
	static let HomeViewController : String = "home"
	static let NavViewController : String = "nav"
}

struct Colors {
	static let AlizarinCrimson : UIColor = UIColor(red: 255.0 / 255.0, green: 43.0 / 255.0, blue: 56.0 / 255.0, alpha: 1.0)
	static let LilyWhite : UIColor = UIColor(red: 235.0 / 255.0, green: 235.0 / 255.0, blue: 235.0 / 255.0, alpha: 1.0)
}

struct Images {
	static let GearWhite : UIImage = UIImage(named: "gearWhite")!
	static let AddWhite : UIImage = UIImage(named: "plusWhite")!
	static let TrashWhite : UIImage = UIImage(named: "trashWhite")!
	static let CancelWhite : UIImage = UIImage(named: "cancelWhite")!
	static let Cloudy : UIImage = UIImage(named: "cloudy")!
	static let Rain : UIImage = UIImage(named: "rain")!
	static let Snow : UIImage = UIImage(named: "snow")!
	static let Sun : UIImage = UIImage(named: "sun")!
	static let Wind : UIImage = UIImage(named: "wind")!
	static let Fog : UIImage = UIImage(named: "fog")!
	static let Thermometer : UIImage = UIImage(named: "thermometer")!
	static let Tags : UIImage = UIImage(named: "tags")!
	static let Location : UIImage = UIImage(named: "location")!
	static let Calendar : UIImage = UIImage(named: "calendar")!
	static let EnableTouchID : UIImage = UIImage(named: "enableTouchID")!
	static let DisableTouchID : UIImage = UIImage(named: "disableTouchID")!
	static let TouchID : UIImage = UIImage(named: "touchID")!
}

struct CloudKitKeys {
	static let dateString : String = "dateString"
	static let image : String = "image"
	static let latitude : String = "latitude"
	static let longitude : String = "longitude"
	static let tags : String = "tags"
	static let text : String = "text"
	static let weatherIcon : String = "weatherIcon"
	static let weatherTempRange : String = "weatherTempRange"
	static let locationName : String = "locationName"
}

struct Keys {
	static let TouchID : String = "TouchID"
	static let SubRegistered : String = "Registered"
	static let DarkSkyKey : String = "695f1fc143e1b1d65bcd8810169c0325"
}

struct APIs {
	static let DarkSkyCall : String = "https://api.darksky.net/forecast/\(Keys.DarkSkyKey)/%.4f,%.4f,%@?exclude=currently,flags,hourly"
}

struct Strings {
	static let LongDateFormat : String = "yyyy-MM-dd'T'HH:mm:ss"
	static let DateFormat : String = "MMMM dd, yyyy"
	static let NoLocation : String = "*No location data for this photo*"
	static let TextViewPlaceholder : String = "Compose your entry here..."
}
