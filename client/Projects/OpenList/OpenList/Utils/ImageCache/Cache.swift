//
//  ImageCacher.swift
//  OpenList
//
//  Created by 김영균 on 12/2/23.
//

import Foundation

final class Cache {
	private let cache: NSCache<NSString, NSData>
	private let fileManager: FileManager
	private let cacheQueue: DispatchQueue = .init(label: "kr.codesquad.boostcamp8.OpenList.Cache")
	
	init(cache: NSCache<NSString, NSData>, fileManager: FileManager) {
		self.cache = cache
		self.fileManager = fileManager
	}
}

// MARK: - Memory Cache
extension Cache {
	func setCountLimit(_ count: Int) {
		cache.countLimit = count
	}
	
	func setMemoryCache(data: Data, key: String) {
		cacheQueue.sync {
			cache.setObject(data as NSData, forKey: key as NSString)
		}
	}
	
	func getMemoryCache(key: String) -> Data? {
		return cache.object(forKey: key as NSString) as? Data
	}
}

// MARK: - Disk Cache
extension Cache {
	func setDiskCache(data: Data, key: String) {
		guard let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else { return }
		let fileURL = cacheDirectory.appendingPathComponent(key)
		try? data.write(to: fileURL)
	}
	
	func getDiskCache(key: String) -> Data? {
		guard let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else { return nil }
		let fileURL = cacheDirectory.appendingPathComponent(key)
		return try? Data(contentsOf: fileURL)
	}
}
