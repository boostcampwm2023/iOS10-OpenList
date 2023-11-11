//
//  SampleUseCase.swift
//  OpenList
//
//  Created by 김영균 on 11/11/23.
//

import Foundation

protocol SampleUseCase {}

final class DefaultSampleUseCase: SampleUseCase {
	private let sampleRepository: SampleRepository
	
	init(sampleRepository: SampleRepository) {
		self.sampleRepository = sampleRepository
	}
}
