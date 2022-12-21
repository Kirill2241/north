//
//  OneContactViewController.swift
//  Telephone Directory
//
//  Created by Diana Princess on 30.11.2022.
//

import UIKit
import SnapKit
import MessageUI
import Network
class OneContactViewController: UIViewController, OneContactViewProtocol {
    
    var presenter: OneContactPresenterProtocol?
    var phone: String?
    var cell: String?
    
    @IBOutlet weak var contactImageView: UIImageView!
    
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var mailLabel: UILabel!
    
    func reload(fullName: String, phone: String, cell: String, email: String) {
        DispatchQueue.main.async {
            self.contactImageView.image = UIImage(named: "Error")
            self.fullNameLabel.text = fullName
            self.phone = phone
            self.phoneLabel.text = "Телефон: "+phone
            self.cell = cell
            self.cellLabel.text = "Мобильный: "+cell
            self.mailLabel.text = email
        }
    }
    
    @IBAction func callPhoneNumber(_ sender: UIButton) {
        guard let phoneNumber = phone else { return }
        guard let numberUrl = URL(string: "tel://"+phoneNumber) else { return }
        UIApplication.shared.open(numberUrl)
    }
    
    @IBAction func callCellNumber(_ sender: UIButton) {
        guard let cellNumber = cell else { return }
        guard let numberUrl = URL(string: "tel://"+cellNumber) else { return }
        UIApplication.shared.open(numberUrl)
    }
    
    @IBAction func sendSMSToCellNumber(_ sender: UIButton) {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "Message Body"
            guard let unwrappedCell = cell else { return }
            controller.recipients = [unwrappedCell]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func sendSMSToPhoneNumber(_ sender: UIButton) {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "Message Body"
            guard let unwrappedPhone = phone else { return }
            controller.recipients = [unwrappedPhone]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func setImage(image: UIImage) {
        DispatchQueue.main.async {
            self.contactImageView.image = image
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.enlargeImage(_:)))
            tapGestureRecognizer.numberOfTouchesRequired = 1
            self.contactImageView.isUserInteractionEnabled = true
            self.contactImageView.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    @objc func enlargeImage(_ sender: UITapGestureRecognizer){
        DispatchQueue.main.async {
            let vc = CustomModalViewController()
            guard let image = self.contactImageView.image else { return }
            vc.addImage(image: image)
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: false)
        }
    }
}

extension OneContactViewController: MFMessageComposeViewControllerDelegate{
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
}
