//
//  Pokemon.swift
//  Pokedex
//
//  Created by Mac on 2/1/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

struct Pokemon {
    var name: String?
    var id: Int?
    var forms: [Resource]?
    var stats: [Stat]?
    var weight: Int?
    var moves: [Move]?
    var sprites: Sprites?
    var locationAreaEncounters: String?
    var height: Int?
    var isDefault: Bool?
    var speciesResource: Resource?
    var order: Int?
    var gameIndices: [GameIndex]?
    var baseExperience: Int?
    var types: [Type]?
    
    init?(dictionary: [String: Any]) {
        if let name = dictionary["name"] as? String {
            self.name = name.components(separatedBy: "-").joined(separator: " ")
        }
        
        if let id = dictionary["id"] as? Int {
            self.id = id
        }
        
        if let forms = dictionary["forms"] as? [[String: Any]] {
            var formsConverted: [Resource] = []
            forms.forEach {
                form in
                guard let formUrl = form["url"] as? String,
                let formName = form["name"] as? String else { return }
                formsConverted.append(Resource(url: formUrl, name: formName))
            }
            self.forms = formsConverted
        }
        
        if let stats = dictionary["stats"] as? [[String: Any]] {
            var statsConverted: [Stat] = []
            stats.forEach {
                stat in
                guard let statResource = stat["stat"] as? [String: Any] else { return }
                guard let statUrl = statResource["url"] as? String,
                let statName = statResource["name"] as? String,
                let effort = stat["effort"] as? Int,
                let baseStat = stat["base_stat"] as? Int else { return }
                statsConverted.append(Stat(statResource: Resource(url: statUrl, name: statName), effort: effort, baseStat: baseStat))
            }
            self.stats = statsConverted
        }
        
        self.weight = dictionary["weight"] as? Int
        
        if let moves = dictionary["moves"] as? [[String: Any]] {
            var movesConverted: [Move] = []
            moves.forEach {
                move in
                guard let versionGroupDetails = move["version_group_details"] as? [[String: Any]] else { return }
                var versionGroupDetailsConverted: [MoveVersionGroupDetail] = []
                versionGroupDetails.forEach {
                    versionGroupDetail in
                    guard let moveLearnMethodResource = versionGroupDetail["move_learn_method"] as? [String: Any],
                    let versionGroupResource = versionGroupDetail["version_group"] as? [String: Any] else { return }
                    guard let moveLearnMethodUrl = moveLearnMethodResource["url"] as? String,
                    let moveLearnMethodName = moveLearnMethodResource["name"] as? String,
                    let levelLearnedAt = versionGroupDetail["level_learned_at"] as? Int,
                    let versionGroupUrl = versionGroupResource["url"] as? String,
                    let versionGroupName = versionGroupResource["name"] as? String else { return }
                    versionGroupDetailsConverted.append(MoveVersionGroupDetail(moveLearnMethodResource: Resource(url: moveLearnMethodUrl, name: moveLearnMethodName), levelLearnedAt: levelLearnedAt, moveVersionGroupInto: Resource(url: versionGroupUrl, name: versionGroupName)))
                }
                guard let moveResource = move["move"] as? [String: Any] else { return }
                guard let moveUrl = moveResource["url"] as? String,
                let moveName = moveResource["name"] as? String else { return }
                movesConverted.append(Move(versionGroupDetails: versionGroupDetailsConverted, moveResource: Resource(url: moveUrl, name: moveName)))
            }
            self.moves = movesConverted
        }
        
        if let sprites = dictionary["sprites"] as? [String: Any] {
            let backFemale = sprites["back_female"] as? String
            let backShinyFemale = sprites["back_shiny_female"] as? String
            let backDefault = sprites["back_default"] as? String
            let backShiny = sprites["back_shiny"] as? String
            let frontFemale = sprites["front_female"] as? String
            let frontShinyFemale = sprites["front_shiny_female"] as? String
            let frontDefault = sprites["front_default"] as? String
            let frontShiny = sprites["front_shiny"] as? String
            self.sprites = Sprites(backFemale: backFemale, backShinyFemale: backShinyFemale, backDefault: backDefault, backShiny: backShiny, frontFemale: frontFemale, frontShinyFemale: frontShinyFemale, frontDefault: frontDefault, frontShiny: frontShiny)
        }
        
        self.locationAreaEncounters = dictionary["location_area_encounters"] as? String
        
        self.height = dictionary["height"] as? Int
        
        self.isDefault = dictionary["is_default"] as? Bool
        
        if let speciesResource = dictionary["species"] as? [String: Any] {
            if let speciesUrl = speciesResource["url"] as? String,
            let speciesName = speciesResource["name"] as? String {
                self.speciesResource = Resource(url: speciesUrl, name: speciesName)
            }
        }
        
        self.order = dictionary["order"] as? Int
        
        if let gameIndices = dictionary["game_indices"] as? [[String: Any]] {
            var gameIndicesConverted: [GameIndex] = []
            gameIndices.forEach {
                gIndex in
                guard let versionResource = gIndex["version"] as? [String: Any] else { return }
                guard let versionUrl = versionResource["url"] as? String,
                let versionName = versionResource["name"] as? String,
                let index = gIndex["game_index"] as? Int else { return }
                gameIndicesConverted.append(GameIndex(versionResource: Resource(url: versionUrl, name: versionName), gameIndex: index))
            }
            self.gameIndices = gameIndicesConverted
        }
        
        self.baseExperience = dictionary["base_experience"] as? Int
        
        if let types = dictionary["types"] as? [[String: Any]] {
            var typesConverted: [Type] = []
            types.forEach {
                t in
                guard let typeResource = t["type"] as? [String: Any] else { return }
                guard let slot = t["slot"] as? Int,
                let typeUrl = typeResource["url"] as? String,
                let typeName = typeResource["name"] as? String else { return }
                typesConverted.append(Type(slot: slot, typeResource: Resource(url: typeUrl, name: typeName)))
            }
            self.types = typesConverted
        }
    }
    
}
