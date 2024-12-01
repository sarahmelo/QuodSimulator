//
//  SIMSwap.swift
//  QuodSimulator
//
//  Created by ipmedia on 01/12/24.
//

import SwiftUI
import UserNotifications

public struct Chip {
    var number: Int
    var hasRecentExchange: Bool
}

import Foundation
class SIMSwapViewController: UIViewController {
    var chips: [Chip] = [
        Chip(number: 5521979590000, hasRecentExchange: true),
        Chip(number: 5521979590001, hasRecentExchange: false)
    ]
    
    @IBOutlet weak var btnValidateSIM: UIButton!
    @IBOutlet weak var tfPhoneNumber: UITextField!
    @IBOutlet weak var lbFeedback: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tfPhoneNumber.keyboardType = .numberPad
        tfPhoneNumber.addTarget(self, action: #selector(onChangesField(_:)), for: .editingChanged)
        btnValidateSIM.isEnabled = false;
        tfPhoneNumber.clearButtonMode = .whileEditing
    }
    
    @objc func onChangesField(_ sender: UITextField) {
        guard let input = sender.text else {
                btnValidateSIM.isEnabled = false
                return
            }
            
        btnValidateSIM.isEnabled = !input.isEmpty
    }
    
    @IBAction func validateSIM(_ sender: UIButton) {
        showLoading(on: sender)
        
        DispatchQueue.global().async {
            sleep(2)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.hideLoading(on: sender)
                
                let text = self.tfPhoneNumber.text!;
                
                guard Validators.hasOnlyNumbers(text: text) else {
                    self.lbFeedback.text = "Por favor, insira apenas números válidos."
                    return
                }
                
                guard !Validators.isEmpty(text: text) else {
                    self.lbFeedback.text = "Por favor, insira um número de telefone"
                    return
                }
                
                if let chip = Validators.findPhoneNumber(phoneNumber: Int(text)!, data: chips) {
                    if chip.hasRecentExchange {
                        self.lbFeedback.text = "Identificada troca recente do chip. Este número não é seguro para utilização."
                    } else {
                        self.lbFeedback.text = "Número identificado como válido e seguro para utilização."
                    }
                } else {
                    self.lbFeedback.text = "O número informado não foi localizado em nosso sistema. Verifique o número e tente novamente."
                }
            }
        }
    }
    
    private func showLoading(on button: UIButton) {
        button.setTitle(" ", for: .normal)
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.center = CGPoint(x: button.bounds.midX, y: button.bounds.midY)
        activityIndicator.startAnimating()
        activityIndicator.tag = 999
        activityIndicator.color = .white
        button.addSubview(activityIndicator)
        button.isUserInteractionEnabled = false
        button.isEnabled = false;
        button.alpha = 0.5;
        button.backgroundColor = .systemBlue
    }
    
    private func hideLoading(on button: UIButton) {
        button.setTitle("Validar SIM", for: .normal)
        if let activityIndicator = button.viewWithTag(999) as? UIActivityIndicatorView {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
        }
        button.isUserInteractionEnabled = true
        button.isEnabled = true;
        button.alpha = 1;

    }
}
