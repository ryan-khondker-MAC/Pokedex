//
//  NetworkService.swift
//  Pokedex
//
//  Created by Mac on 2/1/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class NetworkService {
    static let baseApiUrl = "https://pokeapi.co/api/v2/"
    
    class func getPokemonResources(urlAsString: String, completion: @escaping ([PokemonResource]?, Error?) -> ()) {
        guard let url = URL(string: urlAsString) else {
            completion(nil, NetworkErrors.badUrl)
            return
        }
        
        let session = URLSession.shared
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) {
            (data, response, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(nil, NetworkErrors.badResponse)
                return
            }
            guard httpResponse.statusCode == 200 else {
                completion(nil, NetworkErrors.httpError(code: httpResponse.statusCode))
                return
            }
            guard let data = data else {
                completion(nil, NetworkErrors.noData)
                return
            }
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data)
                guard let dictionary = jsonObject as? [String: Any] else {
                    completion(nil, ParsingErrors.objectNotDictionary)
                    return
                }
                var results: [[String: Any]] = []
                if urlAsString.contains("limit=") {
                    guard let pokemonArray = dictionary["results"] as? [[String: Any]] else {
                        completion(nil, ParsingErrors.noObjectForKey("results"))
                        return
                    }
                    pokemonArray.forEach {
                        pokemonResource in
                        results.append(pokemonResource)
                    }
                } else {
                    guard let pokemonArray = dictionary["pokemon"] as? [[String: Any]] else {
                        completion(nil, ParsingErrors.noObjectForKey("pokemon"))
                        return
                    }
                    pokemonArray.forEach {
                        pokemon in
                        guard let pokemonResource = pokemon["pokemon"] as? [String: Any] else {
                            completion(nil, ParsingErrors.noObjectForKey("pokemon"))
                            return
                        }
                        results.append(pokemonResource)
                    }
                }
                let pokemonResources: [PokemonResource] = results.flatMap {
                    pokemonResource in
                    guard let name = pokemonResource["name"] as? String else {
                        completion(nil, ParsingErrors.noObjectForKey("name"))
                        return nil
                    }
                    guard let url = pokemonResource["url"] as? String else {
                        completion(nil, ParsingErrors.noObjectForKey("url"))
                        return nil
                    }
                    // extracting the ID from the URL
                    // we need the ID to get the correct pokemon image
                    guard let id = Int(url.dropFirst(34).dropLast()) else {
                        completion(nil, ParsingErrors.invalidID)
                        return nil
                    }
                    // only want pokemon from generation 1
                    guard id >= 1, id <= 151 else {
                        return nil
                    }
                    return PokemonResource(url: url, name: name, id: id)
                }
                completion(pokemonResources, nil)
            }
            catch let error {
                completion(nil, error)
            }
        }
        task.resume()
    }
    
    class func getImage(imageUrl: String, session: URLSession, completion: @escaping (UIImage?, Error?) -> ()) {
        if let image = GlobalCache.shared.imageCache.object(forKey: imageUrl as NSString) {
            completion(image, nil)
            return
        }
        guard let url = URL(string: imageUrl) else {
            completion(nil, NetworkErrors.badUrl)
            return
        }
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) {
            (data, response, error) in
            guard error == nil else {
                completion(nil, error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(nil, NetworkErrors.badResponse)
                return
            }
            guard httpResponse.statusCode == 200 else {
                completion(nil, NetworkErrors.httpError(code: httpResponse.statusCode))
                return
            }
            guard let data = data else {
                completion(nil, NetworkErrors.noData)
                return
            }
            guard let image = UIImage(data: data) else {
                completion(nil, ParsingErrors.badData)
                return
            }
            GlobalCache.shared.imageCache.setObject(image, forKey: imageUrl as NSString)
            completion(image, nil)
        }
        task.resume()
    }
    
    class func getPokemonDataFromUrl(urlString: String, completion: @escaping (Pokemon?, Error?) -> ()) {
        guard let url = URL(string: urlString) else {
            completion(nil, NetworkErrors.badUrl)
            return
        }
        let session = URLSession.shared
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) {
            (data, response, error) in
            guard error == nil else {
                completion(nil, error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(nil, NetworkErrors.badResponse)
                return
            }
            guard httpResponse.statusCode == 200 else {
                completion(nil, NetworkErrors.httpError(code: httpResponse.statusCode))
                return
            }
            guard let data = data else {
                completion(nil, NetworkErrors.noData)
                return
            }
            
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data)
                guard let pokemonDictionary = jsonObject as? [String: Any] else {
                    completion(nil, ParsingErrors.objectNotDictionary)
                    return
                }
                let pokemon = Pokemon(dictionary: pokemonDictionary)
                completion(pokemon, nil)
            }
            catch let error {
                completion(nil, error)
            }
        }
        task.resume()
    }
}
