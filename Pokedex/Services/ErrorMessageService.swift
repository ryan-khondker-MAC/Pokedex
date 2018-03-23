//
//  ErrorMessageService.swift
//  Pokedex
//
//  Created by Mac on 2/5/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class ErrorMessageService {
    static func getErrorAlertWithMessage(message: String) -> UIAlertController {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default, handler: { (action) in print("OK pressed")})
        alert.addAction(okButton)
        return alert
    }
}
