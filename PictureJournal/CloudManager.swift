//
//  CloudManager.swift
//  PictureJournal
//
//  Created by Adam on 4/30/18.
//  Copyright © 2018 Adam. All rights reserved.
//

import Foundation
import CloudKit
import UIKit

class CloudManager
{
	static let EntryRecordType : String = "Entry"
	
	let container : CKContainer
	let privateDB : CKDatabase
	
	private static var sharedManager : CloudManager = {
		let manager : CloudManager = CloudManager()
		return manager
	}()
	
	init() {
		self.container = CKContainer.default()
		self.privateDB = self.container.privateCloudDatabase
	}
	
	class func shared() -> CloudManager {
		return sharedManager
	}
	
	func deleteEntry(_ entry : Entry, withCompletionHandler handler : @escaping (_ success : Bool, _ error : Error?) -> ()) {
		if let recordName = entry.recordName {
			self.privateDB.delete(withRecordID: CKRecordID(recordName: recordName)) { (record, error) in
				if let error = error {
					handler(false, error)
					return
				}
				EntriesManager.shared().removeEntry(entry)
				handler(true, nil)
			}
		}
		else {
			print("No Record Name for Entry")
			handler(false, NSError.init(domain: "No Record Name", code: 666, userInfo: nil) as Error)
		}
	}
	
	private func createEntry(_ entry : Entry, withCompletionHandler handler : @escaping (_ success : Bool, _ entry : Entry?, _ error : Error?) -> ()) {
		self.privateDB.save(entry.createCKRecord()) { (record, error) in
			if let error = error {
				handler(false, nil, error)
				return
			}
			if let r = record {
				EntriesManager.shared().addEntry(Entry(entryRecord: r))
				handler(true, Entry(entryRecord: r), nil)
				return
			}
			handler(true, nil, nil)
			return
		}
	}
	
	func createOrUpdateEntry(_ entry : Entry, withCompletionHandler handler : @escaping (_ success : Bool, _ entry : Entry?, _ error : Error?) -> ()) {
		if let recordName = entry.recordName {
			self.privateDB.fetch(withRecordID: CKRecordID(recordName: recordName)) { (record, error) in
				if let record = record, error == nil {
					entry.updateCKRecord(record)
					self.privateDB.save(record, completionHandler: { (record2, error2) in
						if let error2 = error2 {
							handler(false, nil, error2)
							return
						}
						if let r2 = record2 {
							EntriesManager.shared().updateEntry(Entry(entryRecord: r2))
							handler(true, Entry(entryRecord: r2), nil)
							return
						}
						handler(true, nil, nil)
						return
					})
				}
				else {
					print("Error fetching CKRecord")
					handler(false, nil, error)
				}
			}
		}
		else {
			createEntry(entry, withCompletionHandler: handler)
		}
	}
	
	func fetchEntriesWithCompletionHandler(_ handler : @escaping (_ success : Bool, _ error : Error?) -> ()) {
		let query : CKQuery = CKQuery(recordType: CloudManager.EntryRecordType, predicate: NSPredicate(value: true))
		self.privateDB.perform(query, inZoneWith: nil) {(results, error) in
			if let error = error {
				handler(false, error)
				return
			}
			var entries : [Entry] = [Entry]()
			results?.forEach({ (record : CKRecord) in
				entries.append(Entry(entryRecord: record))
			})
			
			EntriesManager.shared().setEntries(entries)
			handler(true, nil)
		}
	}
	
	func registerForEntrySilentSubscription() {
		if !UserDefaults.standard.bool(forKey: Keys.SubRegistered) { //if they aren't registered
			let uuid : UUID = UIDevice().identifierForVendor!
			let identifier : String  = "\(uuid)-change"
			
			let notificationInfo = CKNotificationInfo()
			notificationInfo.shouldSendContentAvailable = true
			
			let subscription = CKQuerySubscription(recordType: CloudManager.EntryRecordType,
												   predicate: NSPredicate(value: true),
												   subscriptionID: identifier,
												   options: [.firesOnRecordUpdate, .firesOnRecordCreation, .firesOnRecordDeletion])
			subscription.notificationInfo = notificationInfo
			self.privateDB.save(subscription) { (subscription, error) in
				if let err = error {
					print("Subscription failed \(err.localizedDescription)\((err as NSError).code)")
					if (err as NSError).code == 15 { //subscription duplication
						UserDefaults.standard.set(true, forKey: Keys.SubRegistered)
					}
				}
				else {
					print("Subscription Set Up")
					UserDefaults.standard.set(true, forKey: Keys.SubRegistered)
				}
			}
		}
		else {
			print("Already Subscribed")
		}
	}
}
