//
//  OneContactViewController.swift
//  Telephone Directory
//
//  Created by Diana Princess on 30.11.2022.
//

import UIKit
import SnapKit
import MessageUI

class OneContactViewController: UIViewController {
    
    @IBOutlet private weak var contactImageView: UIImageView!
    @IBOutlet private weak var fullNameLabel: UILabel!
    @IBOutlet private weak var phoneLabel: UILabel!
    @IBOutlet private weak var cellLabel: UILabel!
    @IBOutlet private weak var mailLabel: UILabel!
    @IBOutlet private weak var imageLoadingActivityIndicator: UIActivityIndicatorView!
    
    var presenter: OneContactPresenterProtocol?
    private var phone: String?
    private var cell: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.getContactInfo()
    }
    
    // MARK: IBACtions for buttons
    @IBAction private func callPhoneNumber(_ sender: UIButton) {
        guard let phoneNumber = phone else { return }
        guard let numberUrl = URL(string: "tel://"+phoneNumber) else { return }
        UIApplication.shared.open(numberUrl)
    }
    
    @IBAction private func callCellNumber(_ sender: UIButton) {
        guard let cellNumber = cell else { return }
        guard let numberUrl = URL(string: "tel://"+cellNumber) else { return }
        UIApplication.shared.open(numberUrl)
    }
    
    @IBAction private func sendSMSToCellNumber(_ sender: UIButton) {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "Message Body"
            guard let unwrappedCell = cell else { return }
            controller.recipients = [unwrappedCell]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction private func sendSMSToPhoneNumber(_ sender: UIButton) {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "Message Body"
            guard let unwrappedPhone = phone else { return }
            controller.recipients = [unwrappedPhone]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    // MARK: function for TapGestureRecognizer
    @objc private func enlargeImage(_ sender: UITapGestureRecognizer) {
        DispatchQueue.main.async {
            let vc = CustomModalViewController()
            guard let image = self.contactImageView.image else { return }
            vc.addImage(image: image)
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: false)
        }
    }
}

// MARK: OneContactViewProtocol implemenation
extension OneContactViewController: OneContactViewProtocol {
    func updateView(fullName: String, phone: String, cell: String, email: String) {
        imageLoadingActivityIndicator.hidesWhenStopped = true
        contactImageView.image = UIImage(systemName: "person.fill")
        fullNameLabel.text = fullName
        self.phone = phone
        phoneLabel.text = "Телефон: +"+phone
        self.cell = cell
        cellLabel.text = "Мобильный: +"+cell
        mailLabel.text = email
        presenter?.requestImage()
    }
    
    func setImage(data: Data) {
        guard let image = UIImage(data: data) else { return }
        self.contactImageView.image = image
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.enlargeImage(_:)))
        tapGestureRecognizer.numberOfTouchesRequired = 1
        self.contactImageView.isUserInteractionEnabled = true
        self.contactImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func setRequestFailureView(error: Error) {
        let alert = UIAlertController(title: "Не удалось загрузить изображение", message:  "Пожалуйста, проверьте подключение. Ошибка: "+error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Повторить попытку", style: UIAlertAction.Style.default){_ in
            self.presenter?.requestImage()
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    func imageIsLoading(_ isLoading: Bool) {
        isLoading ? imageLoadingActivityIndicator.startAnimating() : imageLoadingActivityIndicator.stopAnimating()
    }
}

// MARK: Delegate for messaging
extension OneContactViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
}
