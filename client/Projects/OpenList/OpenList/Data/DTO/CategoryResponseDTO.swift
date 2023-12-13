//
//  CategoryResponseDTO.swift
//  OpenList
//
//  Created by Hoon on 11/30/23.
//

import Foundation

struct MainCategoryResponseDTO: Decodable {
	let name: String
}

typealias SubCategoryResponseDTO = MainCategoryResponseDTO
typealias MinorCategoryResponseDTO = MainCategoryResponseDTO
