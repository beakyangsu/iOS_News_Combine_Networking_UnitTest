//
//  ResultState.swift
//  Test2
//
//  Created by yangsu.baek on 2024/02/29.
//

import Foundation

enum ResultState{
    case loading
    case success
    case failed(error: Error)
}
