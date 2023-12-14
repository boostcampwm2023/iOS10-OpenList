//
//  UITextField+Combine
//  OpenList
//
//  Created by Hoon on 11/15/23.
//

import Combine
import UIKit

extension UITextField {
	var valuePublisher: AnyPublisher<String, Never> {
		controlPublisher(for: .editingChanged)
			.compactMap { $0 as? UITextField }
			.map { $0.text.orEmpty }
			.eraseToAnyPublisher()
	}
}
