//
//  EntryViewController.swift
//  PictureJournal
//
//  Created by Adam on 4/26/18.
//  Copyright © 2018 Adam. All rights reserved.
//

import Foundation
import UIKit
import Photos
import CoreLocation

class EntryViewController : BaseViewController
{
	@IBOutlet weak var trashButton: UIButton!
	@IBOutlet weak var editButton: UIButton!
	
	@IBOutlet weak var weatherBar: UIView!
	@IBOutlet weak var weatherIcon: UIImageView!
	@IBOutlet weak var weatherLabel: UILabel!
	
	@IBOutlet weak var entryImageView: UIImageView!
	
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var dateIcon: UIImageView!
	
	@IBOutlet weak var locationLabel: UILabel!
	@IBOutlet weak var locationIcon: UIImageView!
	
	@IBOutlet weak var entryTextView: UITextView!
	
	private func getTextViewContent() -> String {
		return entryTextView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
	}
	
	@IBOutlet weak var tagsBar: UIView!
	@IBOutlet weak var tagsIcon: UIImageView!
	@IBOutlet weak var tagsLabel: UILabel!
	
	var tags : [String] = [String]() {
		didSet {
			self.tagsLabel.text = Helpers.stringFromArray(tags)
		}
	}
	
	private lazy var labels : [UILabel] = {
		return [weatherLabel, dateLabel, locationLabel, tagsLabel]
	}()
	
	private func blackOutLabels() {
		for label in labels {
			label.alpha = 1.0
		}
	}
	
	lazy var keyboardToolbar : UIToolbar = {
		let keyboard : UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44.0))
		keyboard.backgroundColor = UIColor.white
		let doneButton : UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(dismissKeyboard))
		doneButton.tintColor = UIColor.black
		keyboard.setItems([UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil), doneButton], animated: false)
		return keyboard
	}()
	
	@objc func dismissKeyboard() {
		self.entryTextView.resignFirstResponder()
	}
	
	private var inEditMode = false {
		didSet {
			self.entryImageView.isUserInteractionEnabled = inEditMode
			self.entryTextView.isEditable = inEditMode
			self.entryTextView.isSelectable = inEditMode
			if inEditMode {
				self.trashButton.setImage(Images.TrashWhite.addImagePadding(x: 16.0, y: 16.0), for: .normal)
				self.editButton.setTitle("SAVE", for: .normal)
			}
			else {
				self.trashButton.setImage(Images.CancelWhite.addImagePadding(x: 16.0, y: 16.0), for: .normal)
				self.editButton.setTitle("EDIT", for: .normal)
			}
		}
	}
	
	lazy var imagePicker : UIImagePickerController = {
		let picker = UIImagePickerController()
		picker.sourceType = .photoLibrary
		return picker
	}()
	
	var passedEntry : Entry?
	
	var currentEntry : Entry? {
		didSet {
			if let ce = currentEntry {
				let cevm : EntryViewModel = EntryViewModel(ce)
				self.entryImageView.backgroundColor = UIColor.black
				self.entryImageView.image = cevm.image
				self.dateLabel.text = cevm.dateString
				self.weatherIcon.image = cevm.weatherIcon
				self.weatherLabel.text = cevm.weatherRangeString
				self.locationLabel.text = cevm.locationName
			}
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.weatherIcon.contentMode = .scaleAspectFit
		self.weatherIcon.image = Images.Thermometer
		self.locationIcon.contentMode = .scaleAspectFit
		self.locationIcon.image = Images.Location
		self.dateIcon.contentMode = .scaleAspectFit
		self.dateIcon.image = Images.Calendar
		
		self.tagsIcon.contentMode = .scaleAspectFit
		self.tagsIcon.image = Images.Tags
		let tagTap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tagAreaTapped))
		self.tagsBar.addGestureRecognizer(tagTap)
		
		self.entryTextView.textContainerInset = UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0)
		self.entryTextView.layer.cornerRadius = 4.0
		self.entryTextView.layer.masksToBounds = true
		self.entryTextView.delegate = self
		self.entryTextView.textColor = UIColor.lightGray
		self.entryTextView.text = Strings.TextViewPlaceholder
		self.entryTextView.inputAccessoryView = self.keyboardToolbar
		
		self.entryImageView.contentMode = .scaleAspectFit
		self.entryImageView.clipsToBounds = true
		self.entryImageView.isUserInteractionEnabled = true
		let imageTap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onImageTapped))
		self.entryImageView.addGestureRecognizer(imageTap)
		
		self.imagePicker.delegate = self
		
		self.trashButton.addTarget(self, action: #selector(onTrashTapped), for: .touchUpInside)
		self.editButton.addTarget(self, action: #selector(onEditTapped), for: .touchUpInside)
		
		
		if let pe = self.passedEntry {
			self.inEditMode = false
			blackOutLabels()
			self.currentEntry = pe
			self.entryTextView.text = pe.text
			self.tags = pe.tags
			self.entryTextView.textColor = UIColor.black
		}
		else {
			self.inEditMode = true
			self.weatherLabel.text = "Add a photo to get weather info"
			self.tagsLabel.text = "Add a photo to get intelligent tags"
		}
	}
	
	@objc func tagAreaTapped() {
		let alert = UIAlertController(title: "Add Photo Tags", message: "Add tags, separated by commas, to better identify your photo", preferredStyle: .alert)
		let inputAction = UIAlertAction(title: "Done", style: .default) { (action) in
			let textField = alert.textFields![0] as UITextField
			if let text = textField.text {
				self.tags = Helpers.arrayFromString(text)
			}
		}
		alert.addTextField { (textField) in
			if self.tags.count > 0 {
				textField.text = Helpers.stringFromArray(self.tags)
			}
			else {
				textField.placeholder = "Enter tags here..."
			}
		}
		alert.addAction(inputAction)
		self.present(alert, animated: true, completion: nil)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
		NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
	}
	
	@objc func onTrashTapped() {
		if self.inEditMode {
			let alert = UIAlertController(title: "Are you sure you want to discard your changes?", message: nil, preferredStyle: .alert)
			let yes : UIAlertAction = UIAlertAction(title: "Yes", style: .default) { (action) in
				self.dismiss(animated: true, completion: nil)
			}
			let no : UIAlertAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
			alert.addAction(yes)
			alert.addAction(no)
			self.present(alert, animated: true, completion: nil)
		}
		else { //nothing to save, can safely dismiss
			self.dismiss(animated: true, completion: nil)
		}
	}
	
	//the save zone
	@objc func onEditTapped() {
		if self.inEditMode { //if it was editing
			guard let ce = self.currentEntry, let _ = ce.imageWrapper?.image else {
				self.present(Alerts.missingPictureAlert(), animated: true, completion: nil)
				return
			}
			if getTextViewContent().isEmpty || getTextViewContent() == Strings.TextViewPlaceholder {
				self.present(Alerts.missingEntryAlert(), animated: true, completion: nil)
				return
			}
			if self.tags.count == 0 {
				self.present(Alerts.missingTagsAlert(), animated: true, completion: nil)
				return
			}
			
			//image was entered, text entered, and tags entered
			let entry : Entry = Entry(recordName: ce.recordName, text: getTextViewContent(), image: ce.imageWrapper!.image, date: ce.date, tags: self.tags, latitude: ce.latitude, longitude: ce.longitude, locationName: ce.locationName, weatherIcon: ce.weatherIcon, weatherTempRange: ce.weatherTempRange)
			self.activityIndicatorView = UIViewController.displayActivityIndicatorOnView(self.view)
			CloudManager.shared().createOrUpdateEntry(entry) { (success, entry, error) in
				UIViewController.removeActivityIndicator(self.activityIndicatorView)
				if success {
					DispatchQueue.main.async {
						self.inEditMode = !self.inEditMode
						self.currentEntry = entry
					}
				}
				else {
					if (error! as NSError).code == 9 {
						self.present(Alerts.iCloudSignedOutAlert(), animated: true, completion: nil)
						return
					}
					else {
						print("Failure saving \((error! as NSError).code)")
					}
				}
			}
		}
		else {
			self.inEditMode = !self.inEditMode
		}
	}
	
	@objc func onImageTapped() {
		let status = PHPhotoLibrary.authorizationStatus()
		
		if status == .notDetermined {
			PHPhotoLibrary.requestAuthorization({status in
				if status == PHAuthorizationStatus.authorized {
					print("Photo Library Authorized")
					self.present(self.imagePicker, animated: true, completion: nil)
				}
				else {
					print("Photo Library Not Authorized")
				}
			})
		}
		else if status == .denied {
			
			self.present(Alerts.noPhotoAccessAlert(), animated: true, completion: nil)
		}
		else {
			self.present(self.imagePicker, animated: true, completion: nil)
		}
		
	}
	
}

extension EntryViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		
		defer {
			picker.dismiss(animated: true, completion: nil)
		}
		
		guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
			return
		}
		
		self.tags.removeAll()
		self.detectObjectsInImage(image)
		
		let metadata : PHAsset? = info[UIImagePickerControllerPHAsset] as? PHAsset
		if let asset = metadata {
			guard let date = asset.creationDate else {
				fatalError("No date on photo")
			}
			if let location = asset.location {
				let urlString : String = NSString(format: APIs.DarkSkyCall as NSString, Double(location.coordinate.latitude), Double(location.coordinate.longitude), date.toString(dateFormat: Strings.LongDateFormat)) as String
				self.activityIndicatorView = UIViewController.displayActivityIndicatorOnView(self.view)
				CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
					if let error = error { //handle error
						print("Error geocoding location", error)
					}
					else { //get placemark
						APIClient.shared().getWeatherData(urlString) { (success, weather, error2) in
							UIViewController.removeActivityIndicator(self.activityIndicatorView)
							var recordName : String?
							if let ce = self.currentEntry {
								recordName = ce.recordName
							}
							self.currentEntry = Entry(recordName: recordName, text: "", image: image, date: date, tags: [String](), latitude: Double(location.coordinate.latitude), longitude: Double(location.coordinate.longitude), locationName: Helpers.locationNameFromPlacemark(placemarks?.first), weatherIcon: weather?.icon, weatherTempRange: weather?.weatherRangeString)
							if let err = error2 {
								print("Error getting weather data", err)
							}
						}
					}
				}
			}
			else {
				var recordName : String?
				if let ce = self.currentEntry {
					recordName = ce.recordName
				}
				self.currentEntry = Entry(recordName: recordName, text: "", image: image, date: date, tags: [String](), latitude: nil, longitude: nil, locationName : nil, weatherIcon: nil, weatherTempRange: nil)
			}
			
			blackOutLabels()
		}
	}
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		defer {
			picker.dismiss(animated: true, completion: nil)
		}
	}
}

extension EntryViewController : UITextViewDelegate
{
	func textViewDidBeginEditing(_ textView: UITextView) {
		if textView.textColor == UIColor.lightGray {
			textView.text = ""
			textView.textColor = UIColor.black
		}
	}
}

extension EntryViewController
{
	@objc func keyboardWillShow(_ notification : Notification) {
		if let keyboardFrame : NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
			let height = keyboardFrame.cgRectValue.height
			UIViewPropertyAnimator(duration: 0.3, curve: .easeOut) {
				var newFrame : CGRect = self.view.frame
				newFrame.origin.y = -height
				self.view.frame = newFrame
				}.startAnimation()
		}
	}
	
	@objc func keyboardWillHide(_ notification: NSNotification?) {
		UIViewPropertyAnimator(duration: 0.3, curve: .easeOut) {
			var newFrame : CGRect = self.view.frame
			newFrame.origin.y = 0
			self.view.frame = newFrame
			}.startAnimation()
	}
}
