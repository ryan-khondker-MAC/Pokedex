//
//  ParsingErrors.swift
//  Pokedex
//
//  Created by Mac on 2/5/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import Foundation

enum ParsingErrors : Error {
    case objectNotDictionary
    case noObjectForKey(String)
    case badData
    case invalidID
}
