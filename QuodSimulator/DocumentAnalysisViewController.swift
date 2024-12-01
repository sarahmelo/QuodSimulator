//
//  DocumentAnalysisViewController.swift
//  QuodSimulator
//
//  Created by ipmedia on 01/12/24.
//

import UIKit
import Vision
import AVFoundation


class DocumentAnalysisViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var isDocumentImageValid: Bool = false
    var isSelfieValid: Bool = false
    
    @IBOutlet private weak var btnSubmitValidation: UIButton!
    
    @IBOutlet private weak var documentIcon: UIImageView!
    @IBOutlet private weak var btnCaptureDocumentImage: UIView!
    @IBOutlet private weak var btnCaptureSelfieImage: UIView!
    @IBOutlet private weak var selfieIcon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTapGestures()
    }
    
    private func configureTapGestures() {
        addTapGesture(to: btnCaptureDocumentImage, action: #selector(handleDocumentCapture))
        addTapGesture(to: btnCaptureSelfieImage, action: #selector(handleSelfieCapture))
    }
    
    private func addTapGesture(to view: UIView, action: Selector) {
        view.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: action)
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleDocumentCapture() {
        presentImageSelectionAlert(for: .document)
    }
    
    @objc private func handleSelfieCapture() {
        presentImageSelectionAlert(for: .selfie)
    }
    
    private func presentImageSelectionAlert(for type: ImageType) {
        let alert = UIAlertController(title: "Selecionar Imagem", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Usar Imagem Válida", style: .default) { _ in
            self.updateImageStatus(for: type, isValid: true)
        })
        alert.addAction(UIAlertAction(title: "Usar Imagem Inválida", style: .default) { _ in
            self.updateImageStatus(for: type, isValid: false)
        })
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(alert, animated: true)
    }
    
    private func updateImageStatus(for type: ImageType, isValid: Bool) {
        let icon = isValid ? UIImage(systemName: "checkmark.square") : UIImage(systemName: "xmark.square")
        let tintColor = isValid ? UIColor.systemGreen : UIColor.systemRed
        
        switch type {
        case .document:
            isDocumentImageValid = isValid
            documentIcon.image = icon
            documentIcon.tintColor = tintColor
        case .selfie:
            isSelfieValid = isValid
            selfieIcon.image = icon
            selfieIcon.tintColor = tintColor
        }
    }
    
    @IBAction private func validateData() {
        guard isDocumentImageValid, isSelfieValid else {
            showAlert(title: "Erro", message: "Tenha certeza de que capturou todas as imagens antes de verificar a identidade.")
            return
        }
        performFaceMatch()
    }
    
    private func performFaceMatch() {
        self.btnSubmitValidation.isEnabled = false 
        DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
            DispatchQueue.main.async {
                self.btnSubmitValidation.isEnabled = true
                self.showAlert(title: "Validação Concluída", message: "Identidade validada com sucesso!")
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Enums

private enum ImageType {
    case document
    case selfie
}
