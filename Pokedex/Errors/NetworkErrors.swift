//
//  NetworkErrors.swift
//  Pokedex
//
//  Created by Mac on 2/5/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import Foundation

enum NetworkErrors : Error {
    case httpError(code: Int)
    case badUrl
    case badResponse
    case noData
}
