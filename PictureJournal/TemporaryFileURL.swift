//
//  TemporaryFileURL.swift
//  PictureJournal
//
//  Created by Adam on 4/30/18.
//  Copyright © 2018 Adam. All rights reserved.
//

import Foundation

public protocol ManagedURL {
	var contentURL : URL { get }
	func keepAlive()
}

public extension ManagedURL {
	public func keepAlive() { }
}

extension URL : ManagedURL {
	public var contentURL : URL { return self }
}

public class TemporaryFileURL : ManagedURL {
	public var contentURL: URL
	
	public init(_ ext : String) {
		self.contentURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString).appendingPathExtension(ext)
	}
	
	deinit {
		DispatchQueue.global(qos: .utility).async {
			[contentURL = self.contentURL] in
			try? FileManager.default.removeItem(at: contentURL)
		}
	}
}
