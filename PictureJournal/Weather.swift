//
//  Weather.swift
//  PictureJournal
//
//  Created by Adam on 4/28/18.
//  Copyright © 2018 Adam. All rights reserved.
//

import Foundation
import UIKit

struct Weather
{	
	let summary : String
	let icon : String
	let tempLow : Int
	let tempHigh : Int
	
	init(_ summary : String, _ icon : String, _ tempLow : Int, _ tempHigh : Int) {
		self.summary = summary
		self.icon = icon
		self.tempLow = tempLow
		self.tempHigh = tempHigh
	}
	
	public var weatherRangeString : String {
		return "\(self.tempLow)°/\(self.tempHigh)°"
	}
}
