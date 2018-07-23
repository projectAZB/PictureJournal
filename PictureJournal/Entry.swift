//
//  Entry.swift
//  PictureJournal
//
//  Created by Adam on 4/26/18.
//  Copyright © 2018 Adam. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import CloudKit

struct Entry : Codable
{
	var recordName : String?
	var text : String
	var imageWrapper : EntryImageWrapper?
	var date : Date
	var tags : [String]
	var latitude : Double?
	var longitude : Double?
	var locationName : String?
	var weatherIcon : String?
	var weatherTempRange : String?
	
	init(recordName : String?, text : String, image : UIImage, date : Date, tags : [String], latitude : Double?, longitude : Double?, locationName : String?, weatherIcon : String?, weatherTempRange : String?) {
		self.recordName = recordName
		self.text = text
		self.imageWrapper = EntryImageWrapper(image: image)
		self.date = date
		self.tags = tags
		self.latitude = latitude
		self.longitude = longitude
		self.locationName = locationName
		self.weatherIcon = weatherIcon
		self.weatherTempRange = weatherTempRange
	}
	
	init(entryRecord : CKRecord) {
		self.recordName = entryRecord.recordID.recordName
		self.text = entryRecord[CloudKitKeys.text] as! String
		self.date = (entryRecord[CloudKitKeys.dateString] as! String).toDate(dateFormat: Strings.LongDateFormat)
		self.tags = entryRecord[CloudKitKeys.tags] as! [String]
		self.latitude = entryRecord[CloudKitKeys.latitude] as? Double
		self.longitude = entryRecord[CloudKitKeys.longitude] as? Double
		self.locationName = entryRecord[CloudKitKeys.locationName] as? String
		self.weatherIcon = entryRecord[CloudKitKeys.weatherIcon] as? String
		self.weatherTempRange = entryRecord[CloudKitKeys.weatherTempRange] as? String
		if let asset = entryRecord[CloudKitKeys.image] as? CKAsset,
			let data = try? Data(contentsOf: asset.fileURL),
			let image = UIImage(data: data) {
			self.imageWrapper = EntryImageWrapper(image: image)
		}
	}
	
	public func updateCKRecord(_ entryRecord : CKRecord) {
		entryRecord[CloudKitKeys.text] = self.text as NSString
		entryRecord[CloudKitKeys.dateString] = self.date.toString(dateFormat: Strings.LongDateFormat) as NSString
		entryRecord[CloudKitKeys.tags] = self.tags as NSArray
		if let lat = self.latitude, let long = self.longitude, let locationName = self.locationName {
			entryRecord[CloudKitKeys.latitude] = NSNumber(value: lat)
			entryRecord[CloudKitKeys.longitude] = NSNumber(value: long)
			entryRecord[CloudKitKeys.locationName] = locationName as NSString
		}
		if let icon = self.weatherIcon, let range = self.weatherTempRange {
			entryRecord[CloudKitKeys.weatherIcon] = icon as NSString
			entryRecord[CloudKitKeys.weatherTempRange] = range as NSString
		}
		do {
			let data = UIImageJPEGRepresentation(self.imageWrapper!.image, 0.75)
			let tempURL : URL = TemporaryFileURL("jpg").contentURL
			try data?.write(to: tempURL, options: .atomicWrite)
			let asset : CKAsset = CKAsset(fileURL: tempURL)
			entryRecord[CloudKitKeys.image] = asset
		}
		catch {
			print("Error writing data", error)
		}
	}
	
	public func createCKRecord() -> CKRecord {
		let entryRecordID : CKRecordID = CKRecordID(recordName: UUID().uuidString)
		let entryRecord : CKRecord = CKRecord(recordType: CloudManager.EntryRecordType, recordID: entryRecordID)
		self.updateCKRecord(entryRecord)
		
		return entryRecord
	}
	
	public var description : String {
		var description : String = ""
		description += "Text: \(self.text)\n"
		description += "Date: \(self.date.toString(dateFormat: Strings.DateFormat))\n"
		if let lat = self.latitude, let long = self.longitude, let locationName = self.locationName {
			description += "Latitude: \(lat)\n"
			description += "Longitude: \(long)\n"
			description += "Location Name: \(locationName)"
		}
		if let icon = self.weatherIcon, let range = self.weatherTempRange {
			description += "Icon: \(icon)\n"
			description += "Range: \(range)\n"
		}
		return description
	}
}
