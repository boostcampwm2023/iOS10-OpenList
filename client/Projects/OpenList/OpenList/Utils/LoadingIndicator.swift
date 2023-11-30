//
//  LoadingIndicator.swift
//  OpenList
//
//  Created by Hoon on 11/30/23.
//

import UIKit

final class LoadingIndicator {
	static func showLoading() {
		DispatchQueue.main.async {
			guard
				let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
				let window = windowScene.windows.last
			else { return }
			
			let loadingIndicatorView: UIActivityIndicatorView
			if let existedView = window.subviews.first(where: { $0 is UIActivityIndicatorView }) as? UIActivityIndicatorView {
				loadingIndicatorView = existedView
			} else {
				loadingIndicatorView = UIActivityIndicatorView(style: .large)
				loadingIndicatorView.frame = window.frame
				loadingIndicatorView.color = .primary1
				window.addSubview(loadingIndicatorView)
			}
			
			loadingIndicatorView.startAnimating()
		}
	}
	
	static func hideLoading() {
		DispatchQueue.main.async {
			guard
				let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
				let window = windowScene.windows.last
			else { return }
			window.subviews.filter({ $0 is UIActivityIndicatorView }).forEach { $0.removeFromSuperview() }
		}
	}
}
