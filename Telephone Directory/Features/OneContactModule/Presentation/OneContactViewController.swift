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
        guard let contactInfo = presenter?.updateContactInfo() else { return }
        contactImageView.image = UIImage(systemName: "person.fill")
        fullNameLabel.text = contactInfo.fullname
        self.phone = contactInfo.phone
        phoneLabel.text = "Телефон: +"+contactInfo.phone
        self.cell = contactInfo.cell
        cellLabel.text = "Мобильный: +"+contactInfo.cell
        mailLabel.text = contactInfo.email
        presenter?.requestImage()
    }
    
    // MARK: IBACtions for buttons
    @IBAction private func callPhoneNumber(_ sender: UIButton) {
        presenter?.makeACall(type: .regular)
    }
    
    @IBAction private func callCellNumber(_ sender: UIButton) {
        presenter?.makeACall(type: .cell)
    }
    
    @IBAction private func sendSMSToCellNumber(_ sender: UIButton) {
        presenter?.sendSMS(type: .cell)
    }
    
    @IBAction private func sendSMSToPhoneNumber(_ sender: UIButton) {
        presenter?.sendSMS(type: .regular)
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
    
    func setRequestFailureView(error: Error) {
        let alert = UIAlertController(title: "Не удалось загрузить изображение", message:  "Пожалуйста, проверьте подключение. Ошибка: "+error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Повторить попытку", style: UIAlertAction.Style.default){_ in
            self.presenter?.requestImage()
        })
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: OneContactViewProtocol implemenation
extension OneContactViewController: OneContactViewProtocol {
    func render(_ option: RenderOptions) {
        switch option.imageState {
        case .isLoading:
            imageLoadingActivityIndicator.startAnimating()
        case .error(let error):
            imageLoadingActivityIndicator.stopAnimating()
            setRequestFailureView(error: error)
        case .downloaded(let data):
            imageLoadingActivityIndicator.stopAnimating()
            guard let data = data else { return }
            guard let image = UIImage(data: data) else { return }
            self.contactImageView.image = image
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.enlargeImage(_:)))
            tapGestureRecognizer.numberOfTouchesRequired = 1
            self.contactImageView.isUserInteractionEnabled = true
            self.contactImageView.addGestureRecognizer(tapGestureRecognizer)
        case .smsComposing(let controller):
            self.present(controller, animated: true)
        }
    }
    
    func dismissMessageController(_ controller: MFMessageComposeViewController) {
        controller.dismiss(animated: true)
    }
}
