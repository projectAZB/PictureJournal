//
//  EntriesManager.swift
//  PictureJournal
//
//  Created by Adam on 5/1/18.
//  Copyright © 2018 Adam. All rights reserved.
//

import Foundation

class EntriesManager
{
	var entries : [Entry] = [Entry]()
	
	private static var sharedManager : EntriesManager = {
		let manager : EntriesManager = EntriesManager()
		return manager
	}()
	
	init() {}
	
	class func shared() -> EntriesManager {
		return sharedManager
	}
	
	public func sync(_ handler : @escaping (_ success : Bool, _ error : Error?)->()) {
		CloudManager.shared().fetchEntriesWithCompletionHandler(handler)
	}
	
	public func setEntries(_ entries : [Entry]) {
		self.entries = entries
		self.writeEntriesToFile()
	}
	
	public func removeEntry(_ entry : Entry) {
		var indexToDelete : Int = -1
		for index in 0..<self.entries.count {
			if self.entries[index].recordName == entry.recordName {
				indexToDelete = index
				break
			}
		}
		if indexToDelete >= 0 {
			self.entries.remove(at: indexToDelete)
		}
		self.writeEntriesToFile()
	}
	
	public func addEntry(_ entry : Entry) {
		self.entries.append(entry)
		self.writeEntriesToFile()
	}
	
	public func updateEntry(_ entry : Entry) {
		for index in 0..<self.entries.count {
			if self.entries[index].recordName == entry.recordName {
				self.entries[index] = entry
			}
		}
		self.writeEntriesToFile()
	}
	
	public func writeEntriesToFile() {
		if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
			let fileURL = dir.appendingPathComponent(Filenames.Entries)
			if let encodedData = try? JSONEncoder().encode(self.entries) {
				do {
					try encodedData.write(to: fileURL)
				}
				catch {
					print("Error encoding data")
				}
			}
		}
	}
	
	public func readEntriesFromFile() {
		if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
			let fileURL : URL = dir.appendingPathComponent(Filenames.Entries)
			if let readEntries = try? JSONDecoder().decode([Entry].self, from: Data(contentsOf: fileURL)) {
				self.entries = readEntries
			}
		}
	}
}
