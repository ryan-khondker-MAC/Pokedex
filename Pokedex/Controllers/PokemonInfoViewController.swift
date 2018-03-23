//
//  PokemonInfoViewController.swift
//  Pokedex
//
//  Created by Mac on 2/4/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class PokemonInfoViewController: UIViewController {
    var scrollView = UIScrollView()
    
    lazy var session = URLSession.shared
    
    var pokemonUrl: String?
    var pokemon: Pokemon?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupView()
        self.getPokemonData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupView() {
        let scrollViewFrame = self.view.frame
        self.scrollView = UIScrollView(frame: scrollViewFrame)
        self.scrollView.backgroundColor = UIColor(red: 180/255, green: 8/255, blue: 8/255, alpha: 1)
        self.view.addSubview(self.scrollView)
    }
    
    private func getPokemonData() {
        guard let url = pokemonUrl else {
            fatalError("Missing Pokemon URL")
        }
        NetworkService.getPokemonDataFromUrl(urlString: url) {
            [unowned self] (pokemon, error) in
            if let error = error {
                self.present(ErrorMessageService.getErrorAlertWithMessage(message: error.localizedDescription), animated: true)
                return
            }
            guard let pokemon = pokemon else {
                self.present(ErrorMessageService.getErrorAlertWithMessage(message: "Missing Pokemon data"), animated: true)
                return
            }
            guard let id = pokemon.id else {
                self.present(ErrorMessageService.getErrorAlertWithMessage(message: "Missing Pokemon ID"), animated: true)
                return
            }
            let pokemonImageUrl = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other-sprites/official-artwork/\(id).png"
            self.displayImage(imageUrl: pokemonImageUrl, isSprite: false)
            
            self.pokemon = pokemon
            self.displayPokemonData()
        }
    }
    
    private func displayPokemonData() {
        self.displayPokemonName()
        self.displayPokemonId()
        self.displayPokemonSpeciesInfo()
        self.displayPokemonHeight()
        self.displayPokemonWeight()
        self.displayPokemonStats()
        self.displayPokemonForms()
        self.displayPokemonTypes()
        self.displayPokemonMoves()
        self.displayPokemonBaseExperience()
        self.displayPokemonSprites()
    }
    
    private func displayLabel(isSectionHeaderLabel: Bool, alignment: NSTextAlignment, textToDisplay: String) {
        DispatchQueue.main.async {
            let labelHeight: CGFloat = (isSectionHeaderLabel) ? 20.0 : 28.0
            let labelFrame = (isSectionHeaderLabel) ? CGRect(x: 0.0, y: self.scrollView.contentSize.height + 10, width: self.view.frame.width, height: labelHeight) : CGRect(x: 5.0, y: self.scrollView.contentSize.height + 5, width: self.view.frame.width - 10, height: labelHeight)
            self.scrollView.contentSize.height = labelFrame.maxY
            let label = UILabel(frame: labelFrame)
            label.textColor = UIColor(red: 253/255, green: 203/255, blue: 9/255, alpha: 1)
            if isSectionHeaderLabel {
                label.backgroundColor = UIColor(red: 0, green: 0, blue: 128/255, alpha: 1)
            }
            label.textAlignment = alignment
            label.font = UIFont(name: "Trebuchet MS", size: (isSectionHeaderLabel) ? 18.0 : 24.0)
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.5
            label.text = "\(textToDisplay)"
            self.scrollView.addSubview(label)
        }
    }
    
    private func displayButton(alignment: UIControlContentHorizontalAlignment, textToDisplay: String, tag: Int) {
        DispatchQueue.main.async {
            let buttonHeight: CGFloat = 28.0
            let buttonFrame = CGRect(x: 5.0, y: self.scrollView.contentSize.height + 5, width: self.view.frame.width - 10, height: buttonHeight)
            self.scrollView.contentSize.height = buttonFrame.maxY
            let button = UIButton(frame: buttonFrame)
            button.contentHorizontalAlignment = alignment
            let textAttributes: [NSAttributedStringKey : Any] = [
                NSAttributedStringKey.font: UIFont(name: "Trebuchet MS", size: 24.0) ?? UIFont.systemFont(ofSize: 24.0),
                NSAttributedStringKey.foregroundColor: UIColor(red: 253/255, green: 203/255, blue: 9/255, alpha: 1),
                NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue
            ]
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleLabel?.minimumScaleFactor = 0.5
            let buttonText = NSAttributedString(string: textToDisplay, attributes: textAttributes)
            button.setAttributedTitle(buttonText, for: UIControlState.normal)
            button.sizeToFit()
            button.addTarget(self, action: #selector(self.typeButtonPressed), for: UIControlEvents.touchUpInside)
            button.tag = tag
            self.scrollView.addSubview(button)
        }
    }
    
    @objc private func typeButtonPressed(sender: UIButton!) {
        guard let pokemon = pokemon else {
            self.present(ErrorMessageService.getErrorAlertWithMessage(message: "Missing Pokemon data"), animated: true)
            return
        }
        guard let types = pokemon.types else {
            self.present(ErrorMessageService.getErrorAlertWithMessage(message: "Missing Pokemon types"), animated: true)
            return
        }
        let selectedTypeIndex = sender.tag - 1
        guard selectedTypeIndex < types.count else {
            fatalError("Invalid range")
        }
        let selectedType = types[selectedTypeIndex]
        let vcIdentifier = "Pokedex"
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let pokedexVC = storyboard.instantiateViewController(withIdentifier: vcIdentifier) as? PokedexViewController else {
            fatalError("Unable to find PokedexViewController with identifier \(vcIdentifier)")
        }
        pokedexVC.urlToGetPokemonResources = selectedType.typeResource.url
        show(pokedexVC, sender: self)
    }
    
    private func displayImage(imageUrl: String, isSprite: Bool) {
        DispatchQueue.main.async {
            let imageLength: CGFloat = (isSprite) ? 150.0 : 200.0
            let imageFrame = CGRect(x: self.view.frame.width * 0.5 - (imageLength * 0.5), y: self.scrollView.contentSize.height + 10, width: imageLength, height: imageLength)
            let imageView = UIImageView(frame: imageFrame)
            self.scrollView.addSubview(imageView)
            imageView.image = #imageLiteral(resourceName: "placeholder")
            self.scrollView.contentSize.height = imageFrame.maxY
            NetworkService.getImage(imageUrl: imageUrl, session: self.session) {
                [unowned self] (image, error) in
                if let error = error {
                    self.present(ErrorMessageService.getErrorAlertWithMessage(message: error.localizedDescription), animated: true)
                }
                guard let image = image else { return }
                DispatchQueue.main.async {
                    imageView.image = image
                }
            }
        }
    }
    
    private func displayPokemonName() {
        guard let pokemon = self.pokemon else {
            self.present(ErrorMessageService.getErrorAlertWithMessage(message: "Missing Pokemon data"), animated: true)
            return
        }
        guard let name = pokemon.name else {
            self.present(ErrorMessageService.getErrorAlertWithMessage(message: "Missing Pokemon name"), animated: true)
            return
        }
        DispatchQueue.main.async {
            let labelHeight: CGFloat = 50.0
            let labelFrame = CGRect(x: 0.0, y: self.scrollView.contentSize.height + 5, width: self.view.frame.width, height: labelHeight)
            self.scrollView.contentSize.height = labelFrame.maxY
            let label = UILabel(frame: labelFrame)
            label.textColor = UIColor(red: 253/255, green: 203/255, blue: 9/255, alpha: 1)
            label.textAlignment = NSTextAlignment.center
            label.font = UIFont(name: "Pokemon GB", size: 34.0)
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.5
            label.text = name.uppercased()
            self.scrollView.addSubview(label)
        }
    }
    
    private func displayPokemonId() {
        guard let pokemon = self.pokemon else {
            self.present(ErrorMessageService.getErrorAlertWithMessage(message: "Missing Pokemon data"), animated: true)
            return
        }
        guard let id = pokemon.id else {
            self.present(ErrorMessageService.getErrorAlertWithMessage(message: "Missing Pokemon ID"), animated: true)
            return
        }
        self.displayLabel(isSectionHeaderLabel: false, alignment: NSTextAlignment.center, textToDisplay: "Pokemon #\(id)")
    }
    
    private func displayPokemonSpeciesInfo() {
        guard let pokemon = self.pokemon else {
            self.present(ErrorMessageService.getErrorAlertWithMessage(message: "Missing Pokemon data"), animated: true)
            return
        }
        guard let species = pokemon.speciesResource else {
            self.present(ErrorMessageService.getErrorAlertWithMessage(message: "Missing Pokemon species info"), animated: true)
            return
        }
        self.displayLabel(isSectionHeaderLabel: true, alignment: NSTextAlignment.center, textToDisplay: "SPECIES")
        self.displayLabel(isSectionHeaderLabel: false, alignment: NSTextAlignment.left, textToDisplay: species.name.firstLetterCapitalized())
    }
    
    private func displayPokemonHeight() {
        guard let pokemon = self.pokemon else {
            self.present(ErrorMessageService.getErrorAlertWithMessage(message: "Missing Pokemon data"), animated: true)
            return
        }
        guard let height = pokemon.height else {
            self.present(ErrorMessageService.getErrorAlertWithMessage(message: "Missing Pokemon height"), animated: true)
            return
        }
        self.displayLabel(isSectionHeaderLabel: true, alignment: NSTextAlignment.center, textToDisplay: "HEIGHT")
        self.displayLabel(isSectionHeaderLabel: false, alignment: NSTextAlignment.left, textToDisplay: "\(height)")
    }
    
    private func displayPokemonWeight() {
        guard let pokemon = self.pokemon else {
            self.present(ErrorMessageService.getErrorAlertWithMessage(message: "Missing Pokemon data"), animated: true)
            return
        }
        guard let weight = pokemon.weight else {
            self.present(ErrorMessageService.getErrorAlertWithMessage(message: "Missing Pokemon weight"), animated: true)
            return
        }
        self.displayLabel(isSectionHeaderLabel: true, alignment: NSTextAlignment.center, textToDisplay: "WEIGHT")
        self.displayLabel(isSectionHeaderLabel: false, alignment: NSTextAlignment.left, textToDisplay: "\(weight)")
    }
    
    private func displayPokemonStats() {
        guard let pokemon = self.pokemon else {
            self.present(ErrorMessageService.getErrorAlertWithMessage(message: "Missing pokemon data"), animated: true)
            return
        }
        guard let stats = pokemon.stats else {
            self.present(ErrorMessageService.getErrorAlertWithMessage(message: "Missing Pokemon stats info"), animated: true)
            return
        }
        self.displayLabel(isSectionHeaderLabel: true, alignment: NSTextAlignment.center, textToDisplay: "STATS")
        stats.forEach {
            stat in
            self.displayLabel(isSectionHeaderLabel: false, alignment: NSTextAlignment.center, textToDisplay: "\(stat.statResource.name.uppercased().replacingOccurrences(of: "-", with: " "))")
            self.displayLabel(isSectionHeaderLabel: false, alignment: NSTextAlignment.center, textToDisplay: "Base Stat: \(stat.baseStat) | Effort: \(stat.effort)")
        }
    }
    
    private func displayPokemonForms() {
        guard let pokemon = self.pokemon else {
            self.present(ErrorMessageService.getErrorAlertWithMessage(message: "Missing Pokemon data"), animated: true)
            return
        }
        guard let forms = pokemon.forms else {
            self.present(ErrorMessageService.getErrorAlertWithMessage(message: "Missing Pokemon form info"), animated: true)
            return
        }
        self.displayLabel(isSectionHeaderLabel: true, alignment: NSTextAlignment.center, textToDisplay: "FORMS")
        
        forms.forEach {
            form in
            self.displayLabel(isSectionHeaderLabel: false, alignment: NSTextAlignment.left, textToDisplay: form.name.firstLetterCapitalized())
        }
    }
    
    private func displayPokemonTypes() {
        guard let pokemon = self.pokemon else {
            self.present(ErrorMessageService.getErrorAlertWithMessage(message: "Missing Pokemon data"), animated: true)
            return
        }
        guard let types = pokemon.types else {
            self.present(ErrorMessageService.getErrorAlertWithMessage(message: "Missing Pokemon type info"), animated: true)
            return
        }
        self.displayLabel(isSectionHeaderLabel: true, alignment: NSTextAlignment.center, textToDisplay: "TYPES")
        
        types.enumerated().forEach {
            type in
            self.displayButton(alignment: UIControlContentHorizontalAlignment.left, textToDisplay: type.element.typeResource.name.firstLetterCapitalized(), tag: type.offset + 1)
        }
    }
    
    private func displayPokemonMoves() {
        guard let pokemon = self.pokemon else {
            self.present(ErrorMessageService.getErrorAlertWithMessage(message: "Missing Pokemon data"), animated: true)
            return
        }
        guard let moves = pokemon.moves else {
            self.present(ErrorMessageService.getErrorAlertWithMessage(message: "Missing Pokemon moves info"), animated: true)
            return
        }
        self.displayLabel(isSectionHeaderLabel: true, alignment: NSTextAlignment.center, textToDisplay: "MOVES")
        moves.forEach {
            move in
            let moveName = move.moveResource.name.components(separatedBy: "-").map {
                $0.firstLetterCapitalized()
            }.joined(separator: " ")
            self.displayLabel(isSectionHeaderLabel: false, alignment: NSTextAlignment.left, textToDisplay: "\(moveName)")
        }
    }
    
    private func displayPokemonBaseExperience() {
        guard let pokemon = self.pokemon else {
            self.present(ErrorMessageService.getErrorAlertWithMessage(message: "Missing Pokemon data"), animated: true)
            return
        }
        guard let baseExperience = pokemon.baseExperience else {
            self.present(ErrorMessageService.getErrorAlertWithMessage(message: "Missing Pokemon base experience"), animated: true)
            return
        }
        self.displayLabel(isSectionHeaderLabel: true, alignment: NSTextAlignment.center, textToDisplay: "BASE EXPERIENCE GAIN")
        self.displayLabel(isSectionHeaderLabel: false, alignment: NSTextAlignment.left, textToDisplay: "\(baseExperience)")
    }
    
    private func displayPokemonSprites() {
        guard let pokemon = self.pokemon else {
            self.present(ErrorMessageService.getErrorAlertWithMessage(message: "Missing Pokemon data"), animated: true)
            return
        }
        guard let sprites = pokemon.sprites else {
            self.present(ErrorMessageService.getErrorAlertWithMessage(message: "Missing Pokemon sprites"), animated: true)
            return
        }
        
        self.displayLabel(isSectionHeaderLabel: true, alignment: NSTextAlignment.center, textToDisplay: "SPRITES")
        
        if let frontDefault = sprites.frontDefault {
            self.displayImage(imageUrl: frontDefault, isSprite: true)
        }
        
        if let frontShiny = sprites.frontShiny {
            self.displayImage(imageUrl: frontShiny, isSprite: true)
        }
        
        if let frontFemale = sprites.frontFemale {
            self.displayImage(imageUrl: frontFemale, isSprite: true)
        }
        
        if let frontShinyFemale = sprites.frontShinyFemale {
            self.displayImage(imageUrl: frontShinyFemale, isSprite: true)
        }
        
        if let backDefault = sprites.backDefault {
            self.displayImage(imageUrl: backDefault, isSprite: true)
        }
        
        if let backShiny = sprites.backShiny {
            self.displayImage(imageUrl: backShiny, isSprite: true)
        }
        
        if let backFemale = sprites.backFemale {
            self.displayImage(imageUrl: backFemale, isSprite: true)
        }
        
        if let backShinyFemale = sprites.backShinyFemale {
            self.displayImage(imageUrl: backShinyFemale, isSprite: true)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension String {
    func firstLetterCapitalized() -> String {
        return self.prefix(1).uppercased() + self.dropFirst()
    }
}
