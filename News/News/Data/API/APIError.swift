//
//  APIError.swift
//  Test2
//
//  Created by yangsu.baek on 2024/02/29.
//

import Foundation

enum APIError: Error {
    case decodingError
    case errorCode(Int)
    case unknown
}


extension APIError : LocalizedError {
    var errorDescription: String? {
        switch self {
        case.decodingError :
            return "Failed to decode the object from service"
        case .errorCode(let code):
            return "\(code) - Somthine went wrong"  //response.statusCode
        case .unknown :
            return "The error is unknown"
        }
    }
}
