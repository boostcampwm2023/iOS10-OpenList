//
//  Device.swift
//  OpenList
//
//  Created by wi_seong on 11/23/23.
//

import UIKit

enum Device {
	static let id = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
}
