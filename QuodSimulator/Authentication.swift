//
//  Authentication.swift
//  QuodSimulator
//
//  Created by ipmedia on 30/11/24.
//

struct Person {
    let name: String
    let cpf: String
    let email: String
    let telephone: String
}

import Foundation
import UIKit
import Alamofire

class Authentication: UIViewController, UITextFieldDelegate {
    
    var data: [Person] = [
        Person(name: "Sarah Melo", cpf: "123.456.789-00", email: "sarah@email.com", telephone: "(11) 98765-4321"),
    ]
    
    let green = UIColor(red: 0x5e / 255.0, green: 0x91 / 255.0, blue: 0x88 / 255.0, alpha: 1.0);
    let red = UIColor(red: 0x77 / 255.0, green: 0x18 / 255.0, blue: 0x1e / 255.0, alpha: 1.0);

    @IBOutlet weak var tfEmailAdress: UITextField!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfCPF: UITextField!
    @IBOutlet weak var tfTelephone: UITextField!
    @IBOutlet weak var tfDDI: UITextField!
    @IBOutlet weak var tfDDD: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var lbDDI: UILabel!
    @IBOutlet weak var lbOnlyNumberFeedback: UILabel!
    @IBOutlet weak var lbDDD: UILabel!
    @IBOutlet weak var lbTelephone: UILabel!
    @IBOutlet weak var lbFeedbackName: UILabel!
    @IBOutlet weak var lbNameFeedbackOnlyWord: UILabel!
    @IBOutlet weak var lbFeedbackOnlyNumberCPF: UILabel!
    @IBOutlet weak var lbEmailFeedback: UILabel!
    @IBOutlet weak var lbFeedbackCPF: UILabel!
    
    public var isValidTfEmail = false;
    public var isValidTfName = false;
    public var isValidTFCPF = false;
    public var isValidTFDDI = false;
    public var isValidTFDDD = false;
    public var isValidTFTelephone = false;

    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitButton.isEnabled = false;
        
        keyboardTypeSettings();
        addEventListeners();
        
        [tfCPF, tfDDD, tfDDI, tfName, tfTelephone, tfEmailAdress].forEach({ $0.addTarget(self, action: #selector(editingChanged), for: .editingChanged) })
        
        NotificationCenter.default.addObserver(self, selector:
 #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification,
 object: nil)
    }
    
    @objc func editingChanged(_ textField: UITextField) {
        print("textFieldDidEndEditing called for:", textField.text!)

        
        if isValidTFCPF && isValidTFDDD && isValidTFDDI && isValidTfName && isValidTfEmail && isValidTFTelephone {
            submitButton.isEnabled = true;
        } else {
            submitButton.isEnabled = false;
        }
    }


    
    @objc func keyboardWillShow(notification: NSNotification)
 {
     print("teclado aberto")
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
 {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            scrollView.scrollIndicatorInsets = scrollView.contentInset
        }
    }

    @objc
 func keyboardWillHide(notification: NSNotification) {
     print("teclado fechou")
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero

    }
    
    func keyboardTypeSettings() {
        tfCPF.keyboardType = .numberPad
        tfDDD.keyboardType = .phonePad
        tfDDI.keyboardType = .phonePad
        tfTelephone.keyboardType = .phonePad
    }
    
    func addEventListeners() {
        tfEmailAdress.addTarget(self, action: #selector(checkEmailAddress(_:)), for: .editingChanged)
        tfCPF.addTarget(self, action: #selector(checkCPF(_:)), for: .editingChanged)
        tfName.addTarget(self, action: #selector(checkName(_:)), for: .editingChanged)
        tfDDI.addTarget(self, action: #selector(checkDDI(_:)), for: .editingChanged)
        tfDDD.addTarget(self, action: #selector(checkDDD(_:)), for: .editingChanged)
        tfTelephone.addTarget(self, action: #selector(checkTelephone(_:)), for: .editingChanged)
    }
    
    @IBAction func checkName(_ sender: UITextField) {
        if handleFiveCharactersValidation(text: sender.text!) &&
            handleNameValidation(text: sender.text!) {
            isValidTfName = true;
        } else {
            isValidTfName = false;
        }
    }
    
    @IBAction func checkEmailAddress(_ sender: UITextField) {
        let text = sender.text!

        let isExistingEmail = isExistingEmail(email: text, in: data)
                
        if !isExistingEmail && isValidEmail(email: text) {
            lbEmailFeedback.textColor = green
            isValidTfEmail = true;
        } else {
            lbEmailFeedback.textColor = red
            isValidTfEmail = false;
        }
    }
    
    @IBAction func checkCPF(_ sender: UITextField) {
        let text = sender.text!

        if isValidCPF(cpf: text) &&
            validateIfHasOnlyNumbers(cpf: sender.text!) {
            isValidTFCPF = true;
        } else {
            isValidTFCPF = false;
        }
    }
    
    @IBAction func checkDDI(_ sender: UITextField) {
        let text = sender.text!
        
        if !isValidDDI(ddi: text) {
            lbDDI.textColor = red;
            isValidTFDDI = false;
        } else {
            lbDDI.textColor = green;
            isValidTFDDI = true;
        }
    }
    
    @IBAction func checkDDD(_ sender: UITextField) {
        let text = sender.text!
        
        if !isValidDDD(ddd: text) {
            lbDDD.textColor = red;
            isValidTFDDD = false;
        } else {
            lbDDD.textColor = green;
            isValidTFDDD = true;
        }
    }
    
    @IBAction func checkTelephone(_ sender: UITextField) {
        let text = sender.text!
        
        if !isValidTelephone(phoneNumber: text) {
            lbTelephone.textColor = red;
            isValidTFTelephone = false;
        } else {
            lbTelephone.textColor = green;
            isValidTFTelephone = true;
        }
    }
    
    @IBAction func submitForm(_ sender: UIButton) {
        let person = Person(
            name: tfName.text!,
            cpf: tfCPF.text!,
            email: tfEmailAdress.text!,
            telephone: tfTelephone.text!
        );
        
        data.append(person);
        
        let alert = UIAlertController(title: "Sucesso", message: "Usuário registrado!", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
        
        print(data)
    }
    
    
    func handleFiveCharactersValidation(text: String) -> Bool {
        if text.count <= 5 {
            lbFeedbackName.textColor = red;
            return false;
        } else {
            lbFeedbackName.textColor = green;
            return true;
        }
    }
    
    func handleNameValidation(text: String) -> Bool {
        let regex = "^[a-zA-Z ]+$"
        let predicate = NSPredicate(format:"SELF MATCHES %@", regex)
        
        if !predicate.evaluate(with: text) {
            lbNameFeedbackOnlyWord.textColor = red;
            return false;
        } else {
            lbNameFeedbackOnlyWord.textColor = green;
            return true;
        }
    }
    
    func isExistingEmail(email: String, in data: [Person]) -> Bool {
        return data.contains(where: { $0.email == email })
    }
    
    func isValidEmail(email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPred.evaluate(with: email)
    }
    
    func isValidCPF(cpf: String) -> Bool {
        let isValid = cpf.count == 11
        
        if isValid {
            lbFeedbackCPF.textColor = green
            return true;
        } else {
            lbFeedbackCPF.textColor = red
            return false;
        }
    }
    
    func validateIfHasOnlyNumbers(cpf: String) -> Bool {
        let isValid = CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: cpf))

        if isValid {
            lbFeedbackOnlyNumberCPF.textColor = green
            return true
        } else {
            lbFeedbackOnlyNumberCPF.textColor = red
            return false
        }
    }
    
    func isValidDDI(ddi: String) -> Bool {
        return ddi.count > 1 && ddi.count < 5
    }
    
    func isValidDDD(ddd: String) -> Bool {
        return ddd.count == 2
    }
    
    func isValidTelephone(phoneNumber: String) -> Bool {
        return phoneNumber.count == 9 && validateIfHasOnlyNumbers(cpf: phoneNumber)
    }
}
