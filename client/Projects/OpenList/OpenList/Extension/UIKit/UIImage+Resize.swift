//
//  UIImage+Resize.swift
//  OpenList
//
//  Created by wi_seong on 11/27/23.
//

import UIKit

extension UIImage {
	func resizeImage(size: CGSize) -> UIImage {
		let originalSize = self.size
		let ratio: CGFloat = {
			if originalSize.width > originalSize.height {
				return 1 / (size.width / originalSize.width)
			} else {
				return 1 / (size.height / originalSize.height)
			}
		}()

		return UIImage(cgImage: self.cgImage!, scale: self.scale * ratio, orientation: self.imageOrientation)
	}
}
