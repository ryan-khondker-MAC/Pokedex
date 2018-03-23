//
//  ViewController.swift
//  Pokedex
//
//  Created by Mac on 2/1/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class PokedexViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    let baseApiUrl = "https://pokeapi.co/api/v2/"
    let limit = 151
    
    var urlToGetPokemonResources: String = ""
    var pokemonResources: [PokemonResource]?
    
    var filteredPokemons: [PokemonResource] = []
    var searchActive = false
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.setCollectionViewCell()
        self.setupCollectionView()
        self.setupSearchController()
        
        if urlToGetPokemonResources.count == 0 {
            urlToGetPokemonResources = "\(baseApiUrl)pokemon/?limit=\(limit)"
        }
        self.navigationItem.hidesBackButton = true
        self.getPokemonResources()
        self.navigationItem.hidesBackButton = false
    }
    
    private func setCollectionViewCell() {
        let bundle = Bundle(for: PokemonCollectionViewCell.self)
        let nib = UINib(nibName: "PokemonCollectionViewCell", bundle: bundle)
        collectionView.register(nib, forCellWithReuseIdentifier: "pokemonCell")
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func setupSearchController() {
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = true
        self.searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for Pokemon name"
        searchController.searchBar.sizeToFit()
        
        searchController.searchBar.becomeFirstResponder()
        
        self.navigationItem.titleView = searchController.searchBar
    }
    
    private func getPokemonResources() {
        NetworkService.getPokemonResources(urlAsString: urlToGetPokemonResources) {
            [unowned self] (pokemonResources, error) in
            if let error = error {
                self.present(ErrorMessageService.getErrorAlertWithMessage(message: error.localizedDescription), animated: true)
                return
            }
            guard let pokemonResources = pokemonResources else { return }
            
            if pokemonResources.count == 0 {
                self.present(ErrorMessageService.getErrorAlertWithMessage(message: "No pokemons in collection"), animated: true)
            }
            
            self.pokemonResources = pokemonResources
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension PokedexViewController : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let pokemonResources = self.pokemonResources else { return 0 }
        return (searchActive) ? filteredPokemons.count : pokemonResources.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellIdentifier = "pokemonCell"
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? PokemonCollectionViewCell else {
            fatalError("Unable to find cell with identifier \(cellIdentifier) in PokemonCollectionViewCell, collectionView, ViewController")
        }
        guard let pokemonResources = self.pokemonResources else { return cell }
        let pokemonResource = (searchActive) ? filteredPokemons[indexPath.row] : pokemonResources[indexPath.row]
        cell.setCell(pokemonResource: pokemonResource)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 85, height: 85)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vcIdentifier = "PokemonInfo"
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let pokemonVC = storyboard.instantiateViewController(withIdentifier: vcIdentifier) as? PokemonInfoViewController else {
            fatalError("Unable to find PokemonInfoViewController with identifier \(vcIdentifier)")
        }
        guard let pokemonResources = self.pokemonResources else { return }
        pokemonVC.pokemonUrl = (searchActive) ? filteredPokemons[indexPath.row].resource.url : pokemonResources[indexPath.row].resource.url
        show(pokemonVC, sender: self)
    }
}

extension PokedexViewController : UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        self.dismiss(animated: true, completion: nil)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchString = searchController.searchBar.text?.uppercased() else { return }
        guard let pokemonResources = self.pokemonResources else { return }
        filteredPokemons = pokemonResources.filter {
            pokemon in
            let pokemonName = pokemon.resource.name.uppercased()
            return pokemonName.starts(with: searchString)
        }
        collectionView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
        collectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        collectionView.reloadData()
    }
}
