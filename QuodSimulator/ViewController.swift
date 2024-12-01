//
//  ViewController.swift
//  QuodSimulator
//
//  Created by ipmedia on 29/11/24.
//

import Foundation
import UIKit
import LocalAuthentication

class ViewController: UIViewController {
    let laContext = LAContext()
    
    @IBOutlet weak var btnFacialBiometry: UIButton!
    @IBOutlet weak var btnTouchBiometry: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkBiometry()
    }

    func checkBiometry() {
        var error: NSError?
        
        btnFacialBiometry.isEnabled = false
        btnTouchBiometry.isEnabled = false
        
        guard (laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)) else {
            print("laError - \(String(describing: error))")
            return
        }
        
        if #available(iOS 11.0, *) {
            switch laContext.biometryType {
            case .faceID:
                btnFacialBiometry.isEnabled = true
            case .touchID:
                btnTouchBiometry.isEnabled = true
            default:
                print("No Biometric support")
            }
        }
    }
    
    func showSuccessMessage() {
        let alertController = UIAlertController(
            title: "Sucesso!",
            message: "Você se autenticou com sucesso",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func biometricAuthentication() -> Void {
        laContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Você deve se autenticar para acessar sua conta", reply: { (isSuccess, error) in
            DispatchQueue.main.async(execute: {
                
                if error != nil {
                    print("laError - \(String(describing:error))")
                    return
                }
                
                if isSuccess {
                    self.showSuccessMessage()
                }
            })
        })
    }
}

