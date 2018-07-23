//
//  Helpers.swift
//  PictureJournal
//
//  Created by Adam on 4/27/18.
//  Copyright © 2018 Adam. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

struct Helpers {
	static func stringFromArray(_ tags : [String]) -> String {
		var label : String = ""
		for index in 0..<tags.count {
			if (index == tags.count - 1) {
				label += tags[index]
			}
			else {
				label += (tags[index] + ", ")
			}
		}
		return label
	}
	
	static func arrayFromString(_ string : String) -> [String] {
		var strings : [String] = [String]()
		let substrings : [Substring] = string.split(separator: ",")
		for substring in substrings {
			strings.append(String(substring).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
		}
		return strings
	}
	
	static func locationNameFromPlacemark(_ placemark : CLPlacemark?) -> String? {
		guard let placemark = placemark else {
			return nil
		}
		var labelString : String = ""
		if let city = placemark.locality {
			labelString = labelString + city + ", "
		}
		if let state = placemark.administrativeArea {
			labelString = labelString + state + ", "
		}
		if let country = placemark.country {
			labelString = labelString + country
		}
		if labelString.isEmpty {
			labelString = Strings.NoLocation
		}
		return labelString
	}
	
	static func monthNameForInt(_ month : Int) -> String {
		switch month {
		case 1:
			return "January"
		case 2:
			return "February"
		case 3:
			return "March"
		case 4:
			return "April"
		case 5:
			return "May"
		case 6:
			return "June"
		case 7:
			return "July"
		case 8:
			return "August"
		case 9:
			return "September"
		case 10:
			return "October"
		case 11:
			return "November"
		case 12:
			return "December"
		default:
			return "Not a valid month"
		}
	}
	
}

extension UIViewController
{
	class func displayActivityIndicatorOnView(_ view : UIView) -> UIView {
		let bgView : UIView = UIView(frame: view.bounds)
		bgView.backgroundColor = UIColor.black
		bgView.alpha = 0.6
		let ai : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
		ai.startAnimating()
		ai.center = bgView.center
		
		DispatchQueue.main.async {
			bgView.addSubview(ai)
			view.addSubview(bgView)
		}
		
		return bgView
	}
	
	class func removeActivityIndicator(_ ai : UIView?) {
		DispatchQueue.main.async {
			if let _ = ai {
				ai!.removeFromSuperview()
			}
		}
	}
}

extension UIImage
{	
	func addImagePadding(x: CGFloat, y: CGFloat) -> UIImage? {
		let width : CGFloat = size.width + x
		let height : CGFloat = size.height + y
		UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 0)
		let origin : CGPoint = CGPoint(x: (width - size.width) / 2, y: (height - size.height) / 2)
		draw(at: origin)
		let imageWithPadding = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return imageWithPadding
	}
}

extension Date
{
	func toString( dateFormat format  : String ) -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = format
		return dateFormatter.string(from: self)
	}
}

extension String
{
	func toDate( dateFormat format  : String) -> Date {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = format
		dateFormatter.timeZone = TimeZone.current
		return dateFormatter.date(from: self)!
	}
}
