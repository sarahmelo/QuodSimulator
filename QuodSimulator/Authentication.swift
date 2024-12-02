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

class Authentication: UIViewController, UITextFieldDelegate {
    var data: [Person] = []
    
    let green = UIColor(red: 0x5e / 255.0, green: 0x91 / 255.0, blue: 0x88 / 255.0, alpha: 1.0);
    let red = UIColor(red: 0x77 / 255.0, green: 0x18 / 255.0, blue: 0x1e / 255.0, alpha: 1.0);

    @IBOutlet weak var tfAddres: UITextField!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfCPF: UITextField!
    @IBOutlet weak var tfTelephone: UITextField!
    @IBOutlet weak var tfDDI: UITextField!
    @IBOutlet weak var tfDDD: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var tfComplemento: UITextField!
    
    @IBOutlet weak var tfNumber: UITextField!
    @IBOutlet weak var lbDDI: UILabel!
    @IBOutlet weak var lbOnlyNumberFeedback: UILabel!
    @IBOutlet weak var lbDDD: UILabel!
    @IBOutlet weak var lbTelephone: UILabel!
    @IBOutlet weak var lbFeedbackName: UILabel!
    @IBOutlet weak var lbNameFeedbackOnlyWord: UILabel!
    @IBOutlet weak var lbFeedbackOnlyNumberCPF: UILabel!
    @IBOutlet weak var lbEmailFeedback: UILabel!
    @IBOutlet weak var lbFeedbackCPF: UILabel!
    @IBOutlet weak var lbAddress: UILabel!
    
    public var isValidTfName = false;
    public var isValidTFCPF = false;
    public var isValidTFDDI = false;
    public var isValidTFDDD = false;
    public var isValidTFTelephone = false;
    public var isValidTfCep = false;
    public var isValidTfNumber = false;
    public var isValidTfComplement = false;
    public var positionYCurrentFieldFocused = 0;
    var debounceTimer: Timer?

    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitButton.isEnabled = false;
        
        keyboardTypeSettings();
        addEventListeners();
        
        [tfCPF, tfDDD, tfDDI, tfName, tfTelephone, tfNumber, tfComplemento].forEach({ $0.addTarget(self, action: #selector(editingChanged), for: .editingChanged) })
        
        tfAddres.addTarget(self, action: #selector(cepEditingChanged(_:)), for: .editingChanged)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func editingChanged(_ textField: UITextField) {
            let textFieldPositionInWindow = textField.convert(textField.bounds.origin, to: nil)
            positionYCurrentFieldFocused = Int(textFieldPositionInWindow.y)
            
            if isValidTFCPF && isValidTFDDD && isValidTFDDI && isValidTfName && isValidTfCep && isValidTfNumber && isValidTFTelephone {
                
                submitButton.isEnabled = true;
            } else {
                submitButton.isEnabled = false;
            }
        }
    
    @objc func cepEditingChanged(_ textField: UITextField) {
        debounceTimer?.invalidate()
                
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { [weak self] _ in
                    guard let cep = textField.text, !cep.isEmpty else { return }
                    
            self?.fetchViaCepData(for: cep) { [self] result in
                switch result {
                case .success(let json):
                    if let localidade = json["localidade"] as? String,
                       let uf = json["uf"] as? String,
                       let logradouro = json["logradouro"] as? String,
                       let bairro = json["bairro"] as? String {
                        
                        print("oiiii")
                        self?.isValidTfCep = true;

                        DispatchQueue.main.async { [weak self] in
                            self?.lbAddress.text = "\(localidade), \(uf) - \(logradouro), \(bairro)"
                        }
                        
                        
                    } else {
                        DispatchQueue.main.async { [weak self] in
                            self?.isValidTfCep = false;
                            self?.lbAddress.text = "CEP inválido"
                        }
                    }
                case .failure(let error):
                    print("Erro: \(error.localizedDescription)")
                    DispatchQueue.main.async { [weak self] in
                        self?.isValidTfCep = false;
                        self?.lbAddress.text = "Erro ao buscar endereço"
                    }
                }


                    }
                })
        
        print("idValidCeP : ", isValidTFCPF, isValidTFDDD, isValidTFDDI, isValidTfName, isValidTfCep, isValidTfNumber, isValidTFTelephone, isValidTfComplement)
        
        if isValidTFCPF && isValidTFDDD && isValidTFDDI && isValidTfName && isValidTfCep && isValidTfNumber && isValidTFTelephone && isValidTfComplement {
            submitButton.isEnabled = true;
        } else {
            submitButton.isEnabled = false;
        }
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let bottomInset = keyboardSize.height
            
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
            scrollView.scrollIndicatorInsets = scrollView.contentInset
        }
    }
    
    func fetchViaCepData(for cep: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        let urlString = "https://viacep.com.br/ws/\(cep)/json/"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "InvalidURL", code: 400, userInfo: [NSLocalizedDescriptionKey: "URL inválida"])))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                let error = NSError(domain: "NoData", code: 404, userInfo: [NSLocalizedDescriptionKey: "Dados não recebidos"])
                completion(.failure(error))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    completion(.success(json))
                } else {
                    let error = NSError(domain: "InvalidJSON", code: 500, userInfo: [NSLocalizedDescriptionKey: "Formato de JSON inválido"])
                    completion(.failure(error))
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

    @objc func keyboardWillHide(notification: NSNotification) {
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
        tfCPF.addTarget(self, action: #selector(checkCPF(_:)), for: .editingChanged)
        tfName.addTarget(self, action: #selector(checkName(_:)), for: .editingChanged)
        tfDDI.addTarget(self, action: #selector(checkDDI(_:)), for: .editingChanged)
        tfDDD.addTarget(self, action: #selector(checkDDD(_:)), for: .editingChanged)
        tfTelephone.addTarget(self, action: #selector(checkTelephone(_:)), for: .editingChanged)
        tfNumber.addTarget(self, action: #selector(checkNumber(_:)), for: .editingChanged)
        tfComplemento.addTarget(self, action: #selector(checkComplement(_:)), for: .editingChanged)
    }
    
    @IBAction func checkName(_ sender: UITextField) {
        if handleFiveCharactersValidation(text: sender.text!) &&
            handleNameValidation(text: sender.text!) {
            isValidTfName = true;
        } else {
            isValidTfName = false;
        }
    }
    
    @IBAction func checkCPF(_ sender: UITextField) {
        let text = sender.text!

        if isValidCPF(cpf: text) &&
            validateIfHasOnlyNumbers(cpf: sender.text!) {
            isValidTFCPF = true;
            return
        } else {
            isValidTFCPF = false;
        }
    }
    
    @IBAction func checkNumber(_ sender: UITextField) {
        if (sender.text!.count != 0) {
            isValidTfNumber = true
            return
        }
        isValidTfNumber = false
    }
    
    @IBAction func checkComplement(_ sender: UITextField) {
        if (sender.text!.count != 0) {
            isValidTfComplement = true
            return
        }
        isValidTfComplement = false
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
            email: tfAddres.text! + lbAddress.text! + tfComplemento.text!,
            telephone: tfDDI.text! + tfDDD.text! + tfTelephone.text!
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
        return phoneNumber.count == 9 && Validators.hasOnlyNumbers(text: phoneNumber)
    }
}

extension UIResponder {
    private static weak var _currentFirstResponder: UIResponder?

    static func findCurrentFirstResponder() -> UIResponder? {
        _currentFirstResponder = nil
        UIApplication.shared.sendAction(#selector(_captureFirstResponder), to: nil, from: nil, for: nil)
        return _currentFirstResponder
    }

    @objc private func _captureFirstResponder() {
        UIResponder._currentFirstResponder = self
    }

}
