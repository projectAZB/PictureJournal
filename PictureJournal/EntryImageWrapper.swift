//
//  EntryImageWrapper.swift
//  PictureJournal
//
//  Created by Adam on 5/1/18.
//  Copyright © 2018 Adam. All rights reserved.
//

import Foundation
import UIKit

enum DataError : Error {
	case DecodingFailure
	case EncodingFailure
}

public struct EntryImageWrapper : Codable
{
	public let image: UIImage
	
	public enum CodingKeys: String, CodingKey {
		case image
	}
	
	public init(image: UIImage) {
		self.image = image
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let data = try container.decode(Data.self, forKey: CodingKeys.image)
		guard let image = UIImage(data: data) else {
			throw DataError.DecodingFailure
		}
		
		self.image = image
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		guard let data = UIImageJPEGRepresentation(self.image, 0.75) else {
			throw DataError.EncodingFailure
		}
		
		try container.encode(data, forKey: CodingKeys.image)
	}
}
