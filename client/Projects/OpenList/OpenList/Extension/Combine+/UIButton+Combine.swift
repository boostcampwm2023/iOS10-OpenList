//
//  UIButton+Combine.swift
//  OpenList
//
//  Created by Hoon on 11/15/23.
//

import Combine
import UIKit

extension UIButton {
	var tapPublisher: AnyPublisher<Void, Never> {
		controlPublisher(for: .touchUpInside)
			.map { _ in }
			.eraseToAnyPublisher()
	}
}
