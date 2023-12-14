//
//  UIDevice+safeAreaHeight.swift
//  OpenList
//
//  Created by 김영균 on 11/24/23.
//

import UIKit

extension UIDevice {
	static var safeAreaTopHeight: CGFloat {
		guard let mainWindowScene = UIApplication.shared.connectedScenes
			.first(where: { $0 is UIWindowScene }) as? UIWindowScene,
				let mainWindow = mainWindowScene.windows.first else {
			return 0
		}
		return mainWindow.safeAreaInsets.top
	}
}
