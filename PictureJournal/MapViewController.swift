//
//  MapViewController.swift
//  PictureJournal
//
//  Created by Adam on 5/1/18.
//  Copyright © 2018 Adam. All rights reserved.
//

import Foundation
import UIKit
import MapKit

protocol MapViewControllerDelegate : AnyObject
{
	func onDismissWithEntry(_ entry : Entry)
}

class MapViewController : BaseViewController
{
	@IBOutlet weak var mapView: MKMapView!
	
	weak var delegate : MapViewControllerDelegate?
	
	var annotationsShowed : Bool = false
	
	var annotations : [MKPointAnnotation] = [MKPointAnnotation]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.mapView.delegate = self
		
		for entry in EntriesManager.shared().entries {
			if let latitude = entry.latitude, let longitude = entry.longitude {
				let annotation = ABPointAnnotation(entry: entry)
				annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
				self.annotations.append(annotation)
			}
		}
	}
}

extension MapViewController : MKMapViewDelegate
{
	func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
		if !annotationsShowed {
			self.annotationsShowed = true
			mapView.showAnnotations(self.annotations, animated: true)
		}
	}
	
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		if annotation is MKUserLocation {
			return nil;
		}
		else {
			let pinIdent = "Pin";
			var pinView: MKPinAnnotationView;
			if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: pinIdent) as? ABAnnotationView {
				dequeuedView.annotation = annotation;
				dequeuedView.entry = (annotation as! ABPointAnnotation).entry
				pinView = dequeuedView;
			} else {
				pinView = ABAnnotationView(annotation: annotation, reuseIdentifier: pinIdent, entry: (annotation as! ABPointAnnotation).entry);
				
			}
			return pinView;
		}
	}
	
	func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
		guard let abview = view as? ABAnnotationView, let entry = abview.entry else {
			print("Annotation view not subclass")
			return
		}
		self.dismiss(animated: true) {
			self.delegate?.onDismissWithEntry(entry)
		}
	}
	
}

class ABPointAnnotation : MKPointAnnotation
{
	var entry : Entry!
	
	override init() {
		super.init()
	}
	
	convenience init(entry : Entry) {
		self.init()
		self.entry = entry
	}
}

class ABAnnotationView : MKPinAnnotationView
{
	var entry : Entry?
	
	override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
		super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
	}
	
	convenience init(annotation: MKAnnotation?, reuseIdentifier: String?, entry : Entry) {
		self.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
		self.entry = entry
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
}
