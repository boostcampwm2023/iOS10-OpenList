//
//  ImageLoader.swift
//  OpenList
//
//  Created by 김영균 on 12/2/23.
//

import CustomNetwork
import Foundation

enum ImageLoadError: Error {
	case unsupportedURL
	case taskNotFound
}

final class ImageLoader {
	static let shared: ImageLoader = .init()
	
	private let cache: Cache
	private var tasks: [AnyHashable: Task<Data, Error>] = [:]
	private let taskQueue = DispatchQueue(label: "kr.codesquad.boostcamp8.OpenList.ImageLoader")
	
	private init() {
		cache = Cache(cache: .init(), fileManager: .default)
		// 캐시 개수 제한.
		// 함께 체크리스트에서 가장 많이 이미지 캐싱을 사용할텐데
		// 최대 100개 정도의 프로필정도는 캐싱해두고 나머지는 메모리에서 삭제합니다.
		cache.setCountLimit(100)
	}
}

extension ImageLoader {
	private func imageDownLoadTask<T: Hashable>(taskKey: T, urlString: String) -> Task<Data, Error> {
		// URL이 유효한지 확인합니다.
		guard let url = URL(string: urlString), url.scheme != nil else {
			return .detached { throw ImageLoadError.unsupportedURL }
		}
		
		var urlRequestBuilder = URLRequestBuilder(url: urlString)
		urlRequestBuilder.setMethod(.get)
		urlRequestBuilder.addHeader(field: "Content-Type", value: "application/json")
		let service = NetworkService(customSession: .init(), urlRequestBuilder: urlRequestBuilder)
		let task = Task { try await service.request() }
		taskQueue.sync {
			tasks[taskKey] = task
		}
		return task
	}
	
	/// 이미지를 간단한 캐싱 방법으로 가져옵니다.(이미지URL로 메모리 및 디스크 캐싱합니다.)
	///
	///  UIImageView를 확장하여 사용할 수 있습니다.
	///  ```swift
	///  extension UIImageView {
	///  @MainActor
	///  func loadImage(urlString: String) {
	///	  Task {
	///	    guard let data = await ImageLoader.shared.downloadImage(taskKey: self,  urlString: urlString) else { return }
	///	    self.image = UIImage(data: data)
	///	  }
	/// }
	/// ```
	///
	/// - Parameters:
	///   - taskKey: task를 저장할 키 값입니다. 	`Hashable` 해야합니다.
	///   - urlString: 이미지의 주소입니다. ex): {scheme}://{host}/path/image.jpeg
	///
	func downloadImage<T: Hashable>(taskKey: T, urlString: String) async -> Data? {
		// /가 포함되면 파일을 저장할 수 없어 `/`를 제거하여 키 값으로 사용합니다.
		let key = urlString.replacingOccurrences(of: "/", with: "")
		
		if let memoryCachedData = cache.getMemoryCache(key: key) {
			return memoryCachedData
		}
		
		if let diskCachedData = cache.getDiskCache(key: key) {
			cache.setMemoryCache(data: diskCachedData, key: key)
			return diskCachedData
		}
		
		do {
			let fetchedData = try await imageDownLoadTask(taskKey: taskKey, urlString: urlString).value
			cache.setMemoryCache(data: fetchedData, key: key)
			cache.setDiskCache(data: fetchedData, key: key)
			return fetchedData
		} catch {
			return nil
		}
	}
	
	/// 이미지 다운로드를 취소합니다.
	/// - Parameter taskKey: 취소할 task의 키 값입니다. `Hashable` 해야합니다.
	/// - Throws: `taskKey`에 해당하는 task가 없을 경우 `ImageLoadError.taskNotFound`를 던집니다.s
	func cancel<T: Hashable>(taskKey: T) throws {
		guard let task = tasks[taskKey] else { throw ImageLoadError.taskNotFound }
		task.cancel()
		taskQueue.sync {
			_ = tasks.removeValue(forKey: taskKey)
		}
	}
	
	/// 이미지 다운로드를 취소합니다.
	/// - Parameter taskKey: 취소할 task의 키 값입니다. `Hashable` 해야합니다.
	func cancelIfPossible<T: Hashable>(taskKey: T) {
		guard let task = tasks[taskKey] else { return }
		task.cancel()
		taskQueue.sync {
			_ = tasks.removeValue(forKey: taskKey)
		}
	}
}
