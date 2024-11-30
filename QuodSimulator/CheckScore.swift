//
//  ConsultarScore.swift
//  QuodSimulator
//
//  Created by ipmedia on 29/11/24.
//

import Foundation
import UIKit

class CheckScore: UIViewController {
    
    @IBOutlet weak var cpfController: UITextField!
    @IBOutlet weak var checkScoreButton: UIButton!
    @IBOutlet weak var noContainsSymbolsWordsAndSpaces: UILabel!
    @IBOutlet weak var containsEleven: UILabel!
    @IBOutlet weak var score: UILabel!
    
    
    let green = UIColor(red: 0x5e / 255.0, green: 0x91 / 255.0, blue: 0x88 / 255.0, alpha: 1.0);
    let red = UIColor(red: 0x77 / 255.0, green: 0x18 / 255.0, blue: 0x1e / 255.0, alpha: 1.0);
    
    override func viewDidLoad() {
        super.viewDidLoad();
        checkScoreButton.isEnabled = false;
        cpfController.keyboardType = .numberPad
        cpfController.addTarget(self, action: #selector(checkTextFieldChanged(_:)), for: .editingChanged)

    }
    
    @IBAction func checkTextFieldChanged(_ sender: UITextField) {
        
        let canDisabledButton = validateIfHasOnlyNumbers(sender.text!) && validateIfHasElevenDigits(sender.text!)
        
        if canDisabledButton {
            checkScoreButton.isEnabled = true;
        } else {
            checkScoreButton.isEnabled = false;
        }
    }
    
    @IBAction func checkScoreButtonPressed(_ sender: UIButton) {
        let randomScore = generateRandomScore()
        score.text = String(randomScore)
    }
        
    func generateRandomScore() -> Int {
        return Int.random(in: 0...1000)
    }
    
    func validateIfHasOnlyNumbers(_ input: String) -> Bool {
        let isValid = CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: input))

        if isValid {
            noContainsSymbolsWordsAndSpaces.textColor = green
            return true
        } else {
            noContainsSymbolsWordsAndSpaces.textColor = red
            return false
        }
    }
    
    func validateIfHasElevenDigits(_ input: String) -> Bool {
        let isValid = input.count == 11

        if isValid {
            containsEleven.textColor = green
            return true
        } else {
            containsEleven.textColor = red
            return false
        }
    }
}
