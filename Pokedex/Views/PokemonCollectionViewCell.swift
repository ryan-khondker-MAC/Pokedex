//
//  PokemonCollectionViewCell.swift
//  Pokedex
//
//  Created by Mac on 2/2/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class PokemonCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var pokemonName: UILabel!
    @IBOutlet weak var pokemonImage: UIImageView!
    
    lazy var session = URLSession(configuration: .default)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setCell(pokemonResource: PokemonResource) {
        self.pokemonName?.text = pokemonResource.resource.name.components(separatedBy: "-").joined(separator: " ").uppercased()
        self.pokemonImage?.image = #imageLiteral(resourceName: "placeholder")
        session.invalidateAndCancel()
        session = URLSession(configuration: .default)
        let id = pokemonResource.id
        let pokemonImageUrl = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other-sprites/official-artwork/\(id).png"
        NetworkService.getImage(imageUrl: pokemonImageUrl, session: session) {
            [unowned self] (image, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            guard let image = image else { return }
            DispatchQueue.main.async {
                self.pokemonImage?.image = image
            }
        }
    }
}
