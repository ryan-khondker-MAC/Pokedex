//
//  PokemonResource.swift
//  Pokedex
//
//  Created by Mac on 2/3/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import Foundation

struct PokemonResource {
    var resource: Resource
    var id: Int
    
    init(url: String, name: String, id: Int) {
        self.resource = Resource(url: url, name: name)
        self.id = id
    }
}
