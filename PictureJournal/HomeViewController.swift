//
//  ViewController.swift
//  PictureJournal
//
//  Created by Adam on 4/18/18.
//  Copyright © 2018 Adam. All rights reserved.
//

import UIKit

class HomeViewController: BaseViewController, MapViewControllerDelegate
{
	private var selectedYear : Int = 0 {
		didSet {
			self.tableView.reloadData()
		}
	}
	
	private var entryDateManager : EntryDateManager?
	
	private var entries : [Entry] = [Entry]() {
		didSet {
			self.entryDateManager = EntryDateManager(entries: entries)
			let previousSegCount = self.yearSegControl.numberOfSegments
			self.yearSegControl.removeAllSegments()
			for index in 0..<self.entryDateManager!.yearsSortedKeys.count {
				let key : String = String(self.entryDateManager!.yearsSortedKeys[index])
				self.yearSegControl.insertSegment(withTitle: key, at: index, animated: true)
			}
			if (self.yearSegControl.numberOfSegments > 0 && previousSegCount != self.yearSegControl.numberOfSegments) { //in case of lost segment switch
				self.yearSegControl.selectedSegmentIndex = self.entryDateManager!.yearsSortedKeys.count - 1
				//this will trigger the reloading of data
				self.selectedYear = self.entryDateManager!.yearsSortedKeys[self.entryDateManager!.yearsSortedKeys.count - 1]
			}
			else {
				self.tableView.reloadData()
			}
		}
	}
	
	func resetEntries() {
		self.entries.removeAll()
		self.entries.append(contentsOf: EntriesManager.shared().entries)
	}
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var mapImageView: UIImageView!
	@IBOutlet weak var bottomBar: UIView!
	@IBOutlet weak var yearSegControl: UISegmentedControl!
	
	var search : UISearchController!
	
	var searchText : String?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let leftButton : UIBarButtonItem = UIBarButtonItem(image: Images.GearWhite, style: .plain, target: self, action: #selector(onGearPressed))
		leftButton.tintColor = UIColor.white
		self.navigationItem.leftBarButtonItem = leftButton
		
		let rightButton : UIBarButtonItem = UIBarButtonItem(image: Images.AddWhite, style: .plain, target: self, action: #selector(onAddPressed))
		rightButton.tintColor = UIColor.white
		self.navigationItem.rightBarButtonItem = rightButton
		
		self.search = UISearchController(searchResultsController: nil)
		search.searchResultsUpdater = self
		search.searchBar.tintColor = UIColor.white
		search.searchBar.isTranslucent = false
		search.searchBar.delegate = self
		search.delegate = self
		self.navigationItem.searchController = search;
		
		self.mapImageView.isUserInteractionEnabled = true
		let mapTap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onMapPressed))
		self.mapImageView.addGestureRecognizer(mapTap)
		
		self.tableView.separatorInset = .zero
		self.tableView.delegate = self
		self.tableView.dataSource = self
		self.tableView.tableFooterView = UIView(frame: .zero)
		
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		resetEntries()
	}
	
	@objc func onGearPressed() {
		let entryVC : SettingsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: StoryboardVCIds.SettingsViewController) as! SettingsViewController
		entryVC.modalPresentationStyle = .fullScreen
		self.present(entryVC, animated: true, completion: nil)
	}
	
	@objc func onAddPressed() {
		let entryVC : EntryViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: StoryboardVCIds.EntryViewController) as! EntryViewController
		entryVC.modalPresentationStyle = .fullScreen
		self.present(entryVC, animated: true, completion: nil)
	}
	
	@objc func onMapPressed() {
		let mapVC : MapViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: StoryboardVCIds.MapViewController) as! MapViewController
		mapVC.modalPresentationStyle = .popover
		mapVC.modalTransitionStyle = .crossDissolve
		mapVC.delegate = self
		guard let popController = mapVC.popoverPresentationController else {
			return
		}
		popController.delegate = self
		popController.sourceView = self.view
		let mapRect : CGRect = bottomBar.convert(self.mapImageView.frame, to: self.view)
		popController.sourceRect = CGRect(x: mapRect.midX, y: mapRect.origin.y, width: 0, height: 0	)
		popController.canOverlapSourceViewRect = false
		popController.permittedArrowDirections = .down
		mapVC.preferredContentSize = CGSize(width: self.view.frame.width - 16.0, height: self.tableView.frame.size.height - 16.0)
		
		self.present(mapVC, animated: true, completion: nil)
	}
	
	@IBAction func yearSegValueChanged(_ sender: Any) {
		self.selectedYear = self.entryDateManager!.yearsSortedKeys[(sender as! UISegmentedControl).selectedSegmentIndex]
	}
	
	
	//MapViewControllerDelegate
	func onDismissWithEntry(_ entry: Entry) {
		self.segueToEntry(entry)
	}

}

extension HomeViewController : UIPopoverPresentationControllerDelegate {
	func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
		
	}
	
	func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
		return UIModalPresentationStyle.none
	}
}

extension HomeViewController : UITableViewDataSource, UITableViewDelegate, EntryCellDelegate
{
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return EntryCell.Height
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		if self.selectedYear > 0, let sections = self.entryDateManager?.countMonthsInYear(self.selectedYear) {
			return sections
		}
		return 0
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if self.selectedYear > 0, self.entryDateManager?.countMonthsInYear(self.selectedYear) ?? 0 > 0, let months : [Int] = self.entryDateManager?.getOrderedMonthsInYear(self.selectedYear) {
			
			let view : UIView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 28.0))
			view.backgroundColor = Colors.LilyWhite
			let label : UILabel = UILabel.init(frame: CGRect(x: 8.0, y: 4.0, width: view.frame.size.width - 8.0, height: 20.0))
			label.textColor = UIColor.black
			label.font = UIFont.boldSystemFont(ofSize: 16.0)
			label.text = Helpers.monthNameForInt(months[section])
			view.addSubview(label)
			return view
		}
		else {
			return nil
		}
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if self.selectedYear > 0, self.entryDateManager?.countMonthsInYear(self.selectedYear) ?? 0 > 0, let months = self.entryDateManager?.getOrderedMonthsInYear(self.selectedYear), let days : [EntryViewModel] = self.entryDateManager?.getDaysForMonthAndYear(months[section], self.selectedYear) {
			return days.count
		}
		return 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell : EntryCell = tableView.dequeueReusableCell(withIdentifier: EntryCell.EntryCellID, for: indexPath) as! EntryCell
		cell.textView.textContainerInset = .zero
		cell.thumbnailImageView.layer.cornerRadius = 5.0
		cell.thumbnailImageView.layer.masksToBounds = true
		cell.delegate = self
		
		if self.selectedYear > 0, self.entryDateManager?.countMonthsInYear(self.selectedYear) ?? 0 > 0, let months = self.entryDateManager?.getOrderedMonthsInYear(self.selectedYear), let days = self.entryDateManager?.getDaysForMonthAndYear(months[indexPath.section], self.selectedYear) {
			let evm : EntryViewModel = days[indexPath.row]
			cell.configure(evm)
		}
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if (editingStyle == UITableViewCellEditingStyle.delete) {
			let entryCell : EntryCell = tableView.cellForRow(at: indexPath) as! EntryCell
			self.activityIndicatorView = UIViewController.displayActivityIndicatorOnView(self.view)
			CloudManager.shared().deleteEntry(entryCell.entry) { (success, error) in
				UIViewController.removeActivityIndicator(self.activityIndicatorView)
				if success {
					DispatchQueue.main.async {
						self.resetEntries()
					}
				}
				else {
					print("Error deleting entry", error!)
				}
			}
		}
	}
	
	func onCellTapped(entry : Entry) {
		self.segueToEntry(entry)
	}
	
	private func segueToEntry(_ entry : Entry) {
		let entryVC : EntryViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: StoryboardVCIds.EntryViewController) as! EntryViewController
		entryVC.modalPresentationStyle = .fullScreen
		entryVC.passedEntry = entry
		self.present(entryVC, animated: true, completion: nil)
	}
}

protocol EntryCellDelegate : AnyObject {
	func onCellTapped(entry : Entry)
}

class EntryCell : UITableViewCell
{
	static let Height : CGFloat = 88.0
	static let EntryCellID : String = "entryCell"
	
	weak var delegate : EntryCellDelegate?
	
	@IBOutlet weak var thumbnailImageView: UIImageView!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var textView: UITextView!
	@IBOutlet weak var tagsLabel: UILabel!
	@IBOutlet weak var weatherIcon: UIImageView!
	@IBOutlet weak var weatherLabel: UILabel!
	
	var entry : Entry!
	
	func configure(_ viewModel : EntryViewModel) {
		self.entry = viewModel.entry
		self.thumbnailImageView.image = viewModel.image
		self.dateLabel.text = viewModel.dateString
		self.textView.text = viewModel.text
		self.tagsLabel.text = viewModel.tagsString
		self.weatherIcon.image = viewModel.weatherIconForCell
		self.weatherLabel.text = viewModel.weatherRangeStringForCell
		let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
		self.contentView.addGestureRecognizer(tap)
	}
	
	@objc func cellTapped() {
		self.delegate?.onCellTapped(entry: self.entry)
	}
}

extension HomeViewController : UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate
{
	func willPresentSearchController(_ searchController: UISearchController) {
		if let searchText = searchController.searchBar.text?.lowercased(), searchText.isEmpty, self.searchText != nil {
			searchController.dismiss(animated: false, completion: nil)
			self.searchText = nil
			self.resetEntries()
		}
	}
	
	func willDismissSearchController(_ searchController: UISearchController) {
		self.searchText = searchController.searchBar.text
	}
	
	func didDismissSearchController(_ searchController: UISearchController) {
		searchController.searchBar.text = self.searchText
	}
	
	func updateSearchResults(for searchController: UISearchController) {
		
	}
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		guard let searchText = searchBar.text?.lowercased(), searchText.count > 0 else {
			return
		}
		let filteredEntries = EntriesManager.shared().entries.filter { entry -> Bool in
			if entry.text.lowercased().contains(searchText) {
				return true
			}
			else {
				for tag in entry.tags {
					if tag.lowercased().contains(searchText) {
						return true
					}
				}
			}
			return false
		}
		self.entries.removeAll()
		self.entries.append(contentsOf: filteredEntries)
		self.search.isActive = false
	}
}

