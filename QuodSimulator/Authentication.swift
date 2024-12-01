//
//  Authentication.swift
//  QuodSimulator
//
//  Created by ipmedia on 30/11/24.
//

import Foundation
import UIKit

class Authentication: UIViewController {

    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var labelValidationEmail: UILabel!
    @IBOutlet weak var labelPasswordValid: UILabel!
        
    override func viewDidLoad() {
        tfEmail.addTarget(self, action: #selector(checkEmailValidation(_:)), for: .editingChanged)
        tfPassword.addTarget(self, action: #selector(checkPasswordValidation(_:)), for: .editingChanged)
    }
    
    @IBAction func checkEmailValidation(_ sender: UITextField) {
        print("print do email")
    }
    
    @IBAction func checkPasswordValidation(_ sender: UITextField) {
        print("print do password")
    }
    
    @IBAction func validateAutentication(_ sender: UIButton) {
        print("button pressed")
    }
}
