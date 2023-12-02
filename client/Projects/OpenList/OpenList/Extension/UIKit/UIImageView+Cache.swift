//
//  UIImage+Cache.swift
//  OpenList
//
//  Created by 김영균 on 12/2/23.
//

import UIKit

extension UIImageView {
	@MainActor
	func loadImage(urlString: String) {
		Task {
			guard let data = await ImageLoader.shared.downloadImage(taskKey: self, urlString: urlString) else { return }
			self.image = UIImage(data: data)
		}
	}
	
	@MainActor
	func cancelLoadImage() {
		ImageLoader.shared.cancelIfPossible(taskKey: self)
	}
}
