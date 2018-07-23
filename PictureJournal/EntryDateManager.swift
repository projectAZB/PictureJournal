//
//  EntryDateManager.swift
//  PictureJournal
//
//  Created by Adam on 5/2/18.
//  Copyright © 2018 Adam. All rights reserved.
//

import Foundation

struct EntryAndComponents {
	let components : DateComponents
	let entry : Entry
	
	init(entry : Entry, components : DateComponents) {
		self.entry = entry
		self.components = components
	}
}

struct EntryDateManager
{
	//top level dictionary with year string i.e. "2018" as the key,
	//value is another dictionary with month i.e. "01" as the key,
	//value is another dictionary with day i.e. "31" as the key,
	//value is an array of sorted day entries
					 //sorted entries
	typealias Days = [EntryAndComponents]
	typealias Months = [Int : Days?]
	typealias Years = [Int : Months?]
	
	let entries : [Entry]
	
	var years : Years!
	
					//key is a concatenation of month and year
	var evcCache : [String : [EntryViewModel]] = [String : [EntryViewModel]]()
	var monthsCache : [String : [Int]] = [String : [Int]]()
	
	var yearsSortedKeys : [Int] {
		return years.keys.sorted()
	}
	
	init(entries : [Entry]) {
		self.entries = entries
		process_entries()
	}
	
	mutating func process_entries() {
		var entriesAndComponents : [EntryAndComponents] = [EntryAndComponents]()
		for index in 0..<self.entries.count {
			let entry : Entry = self.entries[index]
			let date : Date = entry.date
			let components : DateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
			let entryAndComponents : EntryAndComponents = EntryAndComponents(entry: entry, components: components)
			entriesAndComponents.append(entryAndComponents)
		}
		
		var yearsResult = Years()
		
		for index in 0..<entriesAndComponents.count {
			
			let ec : EntryAndComponents = entriesAndComponents[index]
			guard let year = ec.components.year, let month = ec.components.month else {
				fatalError("Incorrect date components")
			}
			
			if var months : Months = yearsResult[year] as? Months { //year exists, traverse deeper
				if var days : Days = months[month] as? Days { //month exists, traverse deeper
					days.append(ec)
					months[month] = days
					yearsResult[year] = months
				}
				else { //days array doesn't exist
					//create days array
					let days : Days = [ec]
					//add to month object
					months[month] = days
					//set the year object
					yearsResult[year] = months
				}
			}
			else { //year doesn't exist, create it
				//create day array
				let days : Days = [ec]
				//create month object
				let months : Months = [month : days]
				//finally, create year object
				yearsResult[year] = months
			}
		}
		
		//store the finished years result
		self.years = yearsResult
	}
	
	func countMonthsInYear(_ yearInt : Int) -> Int {
		if self.years.count == 0 {
			return 0
		}
		guard let months = self.years[yearInt] as? Months else {
			fatalError("Accessing invalid year")
		}
		return months.count
	}
	
	//get sections
	mutating func getOrderedMonthsInYear(_ yearInt : Int) -> [Int] {
		if self.years.count == 0 {
			return [Int]()
		}
		guard let months = self.years[yearInt] as? Months else {
			fatalError("Accessing invalid year")
		}
		
		if let monthKeysSorted : [Int] = monthsCache["\(yearInt)"] {
			return monthKeysSorted
		}
		
		let monthKeysSorted : [Int] = months.keys.sorted(by: <)
		self.monthsCache["\(yearInt)"] = monthKeysSorted
		return monthKeysSorted
	}
	
	mutating func getDaysForMonthAndYear(_ monthInt : Int, _ yearInt : Int) -> [EntryViewModel] {
		guard let months : Months = self.years[yearInt] as? Months else {
			fatalError("Accessing invalid year")
		}
		
		guard let days : Days = months[monthInt] as? Days else {
			fatalError("Accessing invalid month")
		}
		
		//cache to avoid constantly
		if let orderedEVs : [EntryViewModel] = self.evcCache["\(monthInt)\(yearInt)"] {
			return orderedEVs
		}
		
		var orderedECs : [EntryAndComponents] = days.sorted { (ec1, ec2) -> Bool in
			if ec1.components.day! < ec2.components.day! {
				return true
			}
			else if ec1.components.day! > ec2.components.day! {
				return false
			}
			else { //==
				if ec1.components.hour! < ec2.components.hour! {
					return true
				}
				else if ec1.components.hour! > ec2.components.hour! {
					return false
				}
				else { //==
					if ec1.components.minute! < ec2.components.minute! {
						return true
					}
					else if ec1.components.minute! > ec2.components.minute! {
						return false
					}
					else {
						if ec1.components.second! < ec2.components.second! {
							return true
						}
						else {
							return false
						}
					}
				}
			}
		}
		
		var entryVMs : [EntryViewModel] = [EntryViewModel]()
		for index in 0..<orderedECs.count {
			entryVMs.append(EntryViewModel(orderedECs[index].entry))
		}
		self.evcCache["\(monthInt)\(yearInt)"] = entryVMs
		return entryVMs
	}
	
}
