//
//  APIClient.swift
//  PictureJournal
//
//  Created by Adam on 4/26/18.
//  Copyright © 2018 Adam. All rights reserved.
//

import Foundation

enum APIClientError : Error {
	case JSONError
	case NetworkError
	case DataError
}

class APIClient
{
	private static var sharedClient : APIClient = {
		let apiClient = APIClient()
		return apiClient
	}()
	
	private init() {
		
	}
	
	class func shared() -> APIClient {
		return sharedClient
	}
	
	private func jsonFromUrlString(_ urlString : String, _ completionBlock : @escaping (_ success : Bool, _ data : [String : Any]?, _ error : APIClientError?) -> ()) {
		let session = URLSession.shared
		guard let url : URL = URL(string: urlString) else {
			completionBlock(false, nil, nil)
			return
		}
		let task = session.dataTask(with: url) { (data, urlResponse, error) in
			if let _ = error {
				print("\(error!.localizedDescription)")
				completionBlock(false, nil, APIClientError.NetworkError)
			}
			else {
				guard let data = data else {
					completionBlock(false, nil, APIClientError.DataError)
					return
				}
				if let jsonData = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : AnyObject] {
					guard let _ = jsonData else {
						completionBlock(false, nil, APIClientError.JSONError)
						return
					}
					completionBlock(true, jsonData!, nil)
				}
				else {
					completionBlock(false, nil, APIClientError.JSONError)
				}
			}
		}
		task.resume()
	}
	
	public func getWeatherData(_ urlString : String, _ completionBlock : @escaping (_ success : Bool, _ weather : Weather?, _ error : APIClientError?) -> ()) {
		self.jsonFromUrlString(urlString) { (success, data, error) in
			DispatchQueue.main.async { //get back to the main queue to return
				if success {
					if let _ = data {
						let weather : Weather? = Parser.parseWeatherData(data!)
						completionBlock(success, weather, nil)
					}
					else {
						completionBlock(false, nil, APIClientError.DataError)
					}
				}
				else {
					completionBlock(success, nil, error)
				}
			}
		}
	}
}
