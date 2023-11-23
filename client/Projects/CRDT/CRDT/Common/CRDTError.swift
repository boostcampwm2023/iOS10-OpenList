//
//  CRDTError.swift
//  crdt
//
//  Created by 김영균 on 11/22/23.
//

import Foundation

/// An error that occurs during the CRDT Operation
public enum CRDTError: Error {
	/// The context in which the error occurred.
	public struct Context: Sendable {
		/// A description of what went wrong, for debugging purposes.
		public let debugDescription: String
		
		/// The underlying error which caused this error, if any.
		public let underlyingError: (Error)?
		
		/// Creates a new context with the given path of coding keys and a
		/// description of what went wrong.
		///
		/// - parameter debugDescription: A description of what went wrong, for
		///   debugging purposes.
		/// - parameter underlyingError: The underlying error which caused this
		///   error, if any.
		init(debugDescription: String, underlyingError: (Error)? = nil) {
			self.debugDescription = debugDescription
			self.underlyingError = underlyingError
		}
	}
	case inCompatibleType(Any, CRDTError.Context)
	case notOverrided(CRDTError.Context)
	case typeIsNil(from: Any?, CRDTError.Context)
	case downCast(from: Any?, CRDTError.Context)
	case invalidOperationType(CRDTError.Context)
	case documentCastFailure(CRDTError.Context)
}
