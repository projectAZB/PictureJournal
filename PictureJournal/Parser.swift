//
//  Parser.swift
//  PictureJournal
//
//  Created by Adam on 4/28/18.
//  Copyright © 2018 Adam. All rights reserved.
//

import Foundation

class Parser {
	
	static func parseWeatherData(_ data : [String : Any]) -> Weather? {
		let daily : [String : Any]? = data["daily"] as? [String : Any]
		guard let _ = daily else {
			return nil
		}
		let dataArray : [[String : Any]]? = daily!["data"] as? [[String : Any]]
		guard let _ = dataArray else {
			return nil
		}
		let day : [String : Any]? = dataArray!.first
		guard let _ = day else {
			return nil
		}
		let summary : String = day!["summary"] as? String ?? ""
		let icon : String = day!["icon"] as? String ?? ""
		let tempLow : Int = (day!["temperatureMin"] as? NSNumber ?? NSNumber(value: 0.0)).intValue
		let tempHigh : Int = (day!["temperatureMax"] as? NSNumber ?? NSNumber(value: 0.0)).intValue
		return Weather(summary, icon, tempLow, tempHigh)
	}
	
}
