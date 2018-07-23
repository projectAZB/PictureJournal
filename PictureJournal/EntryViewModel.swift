//
//  EntryViewModel.swift
//  PictureJournal
//
//  Created by Adam on 5/1/18.
//  Copyright © 2018 Adam. All rights reserved.
//

import Foundation
import UIKit

struct EntryViewModel
{
	static func entryVMsFromEntries(_ entries : [Entry]) -> [EntryViewModel] {
		var entryVMs : [EntryViewModel] = [EntryViewModel]()
		for entry in entries {
			entryVMs.append(EntryViewModel(entry))
		}
		return entryVMs
	}
	
	public let entry : Entry
	
	public var text : String {
		return self.entry.text
	}
	
	public var image : UIImage {
		return self.entry.imageWrapper!.image
	}
	
	public var dateString : String {
		return self.entry.date.toString(dateFormat: Strings.DateFormat)
	}
	
	public var locationName : String {
		if let ls = self.entry.locationName {
			return ls
		}
		return "*No location data available for this photo*"
	}
	
	public var tagsString : String {
		return Helpers.stringFromArray(self.entry.tags)
	}
	
	init(_ entry : Entry) {
		self.entry = entry
	}
	
	public var weatherRangeString : String {
		if let weatherRange = self.entry.weatherTempRange {
			return weatherRange
		}
		return "*No weather data available for this photo*"
	}
	
	public var weatherRangeStringForCell : String {
		if let weatherRange = self.entry.weatherTempRange {
			return weatherRange
		}
		return ""
	}
	
	public var weatherIcon : UIImage {
		if let w = self.entry.weatherIcon {
			return EntryViewModel.imageFromWeatherIconString(w)
		}
		return Images.Cloudy
	}
	
	public var weatherIconForCell : UIImage? {
		if let w = self.entry.weatherIcon {
			return EntryViewModel.imageFromWeatherIconString(w)
		}
		return nil
	}
	
	private static func imageFromWeatherIconString(_ w : String) -> UIImage
	{
		if w.contains("cloudy") {
			return Images.Cloudy
		}
		else if w.contains("rain") {
			return Images.Rain
		}
		else if w.contains("clear") {
			return Images.Sun
		}
		else if w.contains("fog") {
			return Images.Fog
		}
		else if w.contains("snow") {
			return Images.Snow
		}
		else if w.contains("wind") {
			return Images.Wind
		}
		else {
			return Images.Cloudy
		}
	}
}
