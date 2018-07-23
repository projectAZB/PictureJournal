//
//  EVC+ML.swift
//  PictureJournal
//
//  Created by Adam on 5/1/18.
//  Copyright © 2018 Adam. All rights reserved.
//

import Foundation
import UIKit
import Vision

extension EntryViewController
{
	func detectObjectsInImage(_ image : UIImage) {
		
		guard let ciimage : CIImage = CIImage(image: image) else {
			fatalError("Image improperly formatted")
		}
		
		// Load the ML model through its generated class
		guard let inceptionModel = try? VNCoreMLModel(for: MobileNet().model) else {
			fatalError("Can't load Inception ML model")
		}
		
		//create a vision request with a completion handler
		let objectRequest = VNCoreMLRequest(model: inceptionModel) { (vnrequest, error) in
			
			guard let results = vnrequest.results as? [VNClassificationObservation] else {
				fatalError("Unexpected result type from VNCoreMLRequest")
			}
			
			DispatchQueue.main.async {
				if let firstTag = results[0].identifier.split(separator: ",").first {
					self.tags.append(String(firstTag).replacingOccurrences(of: "_", with: " "))
				}
				else {
					self.tags.append(results[0].identifier.replacingOccurrences(of: "_", with: " "))
				}
			}
		}
		
		guard let placesModel = try? VNCoreMLModel(for: GoogLeNetPlaces().model) else {
			fatalError("Can't load GoogLeNetPlaces ML model")
		}
		
		//create a vison request with a completion handler
		let placesRequest = VNCoreMLRequest(model: placesModel) { (vnrequest, error) in
			
			guard let results = vnrequest.results as? [VNClassificationObservation] else {
				fatalError("Unexpected result type from VNCoreMLRequest")
			}
			
			DispatchQueue.main.async {
				if let firstTag = results[0].identifier.split(separator: ",").first {
					self.tags.append(String(firstTag).replacingOccurrences(of: "_", with: " "))
				}
				else {
					self.tags.append(results[0].identifier.replacingOccurrences(of: "_", with: " "))
				}
			}
		}
		
		//Run the core ML model classifier on the global dispatch queue
		let handler : VNImageRequestHandler = VNImageRequestHandler(ciImage: ciimage)
		DispatchQueue.global(qos: .userInteractive).async {
			do {
				try handler.perform([objectRequest, placesRequest])
			}
			catch {
				print(error)
			}
		}
		
	}
}
