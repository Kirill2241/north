//
//  OneContactViewController.swift
//  Telephone Directory
//
//  Created by Diana Princess on 30.11.2022.
//

import UIKit
import SnapKit
import MessageUI

protocol OneContactViewProtocol: class, MFMessageComposeViewControllerDelegate {
    
    func reload(fullName: String, phone: String, cell: String, email: String, largeImage: UIImage)
}

class OneContactViewController: UIViewController, OneContactViewProtocol {
    var presenter: OneContactPresenterProtocol?
    
    let fullNameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 22)
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        return lbl
    }()
    let largeImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.isUserInteractionEnabled = true
        return imgView
    }()
    let phoneLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 16)
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        return lbl
    }()
    let cellPhoneLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 16)
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        return lbl
    }()
    let emailLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 16)
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        return lbl
    }()
    let callButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = .systemGreen
        //btn.clipsToBounds = true
        //btn.layer.cornerRadius = 20
        btn.setImage(UIImage(systemName: "phone.fill"), for: .normal)
        return btn
    }()
    let sendSMSButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = .systemGreen
        //btn.clipsToBounds = true
        //btn.layer.cornerRadius = 20
        btn.setImage(UIImage(systemName: "message.fill"), for: .normal)
        return btn
    }()
    let callCellButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = .systemGreen
        //btn.clipsToBounds = true
        //btn.layer.cornerRadius = 20
        btn.setImage(UIImage(systemName: "phone.fill"), for: .normal)
        return btn
    }()
    let sendCellSMSButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = .systemGreen
        //btn.clipsToBounds = true
        //btn.layer.cornerRadius = 20
        btn.setImage(UIImage(systemName: "message.fill"), for: .normal)
        return btn
    }()
    var labelsStack : UIStackView?
    var phoneButtonsStack: UIStackView?
    var cellButtonsStack: UIStackView?
    var buttonsVerticalStack: UIStackView?
    var phone: String?
    var cell: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        view.tintColor = UIColor.white
        // Do any additional setup after loading the view.
    }

    func configureViews(fullName: String, phone: String, cell: String, email: String, largeImage: UIImage) {
        fullNameLabel.text = fullName
        phoneLabel.text = "Телефон: "+phone
        cellPhoneLabel.text = "Мобильный: "+cell
        emailLabel.text = "Эл. почта: "+email
        largeImageView.image = largeImage
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(enlargeImage(_:)))
        largeImageView.addGestureRecognizer(imageGestureRecognizer)
        self.phone = phone
        self.cell = cell
        view.addSubview(largeImageView)
        view.addSubview(fullNameLabel)
        labelsStack = UIStackView(arrangedSubviews: [phoneLabel, cellPhoneLabel])
        labelsStack?.axis = .vertical
        labelsStack?.alignment = .fill
        labelsStack?.distribution = .fillEqually
        labelsStack?.spacing = 15
        callButton.addTarget(self, action: #selector(callNumber(_:)), for: .touchUpInside)
        callCellButton.addTarget(self, action: #selector(callCell(_:)), for: .touchUpInside)
        sendSMSButton.addTarget(self, action: #selector(sendSMS(_:)), for: .touchUpInside)
        sendCellSMSButton.addTarget(self, action: #selector(sendCellSMS(_:)), for: .touchUpInside)
        phoneButtonsStack = UIStackView(arrangedSubviews: [callButton, sendSMSButton])
        phoneButtonsStack?.axis = .horizontal
        labelsStack?.alignment = .fill
        labelsStack?.distribution = .fillEqually
        labelsStack?.spacing = 20
        cellButtonsStack = UIStackView(arrangedSubviews: [callCellButton, sendCellSMSButton])
        cellButtonsStack?.axis = .horizontal
        cellButtonsStack?.alignment = .fill
        cellButtonsStack?.distribution = .fillEqually
        cellButtonsStack?.spacing = 20
        buttonsVerticalStack = UIStackView(arrangedSubviews: [phoneButtonsStack!, cellButtonsStack!])
        buttonsVerticalStack?.axis = .vertical
        buttonsVerticalStack?.distribution = .fillEqually
        buttonsVerticalStack?.alignment = .fill
        buttonsVerticalStack?.spacing = 15
        view.addSubview(labelsStack!)
        view.addSubview(buttonsVerticalStack!)
        view.addSubview(emailLabel)
    }
    
    func setUpConstraints() {
        largeImageView.snp.makeConstraints{ (maker) in
            maker.top.equalToSuperview().offset(50)
            maker.leading.trailing.equalToSuperview()
            maker.height.equalToSuperview().multipliedBy(0.3)
        }
        fullNameLabel.snp.makeConstraints{ (maker) in
            maker.top.equalTo(largeImageView.snp.bottom).offset(15)
            maker.leading.equalToSuperview().offset(20)
            maker.trailing.equalToSuperview().inset(20)
            maker.height.equalTo(27)
        }
        labelsStack!.snp.makeConstraints{ (maker) in
            maker.top.equalTo(fullNameLabel.snp.bottom).offset(15)
            maker.leading.equalToSuperview().offset(20)
            maker.width.equalToSuperview().multipliedBy(0.7)
            maker.height.equalTo(55)
        }
        buttonsVerticalStack!.snp.makeConstraints{ (maker) in
            maker.top.equalTo(fullNameLabel.snp.bottom).offset(15)
            maker.trailing.equalToSuperview().inset(20)
            maker.width.equalTo(80)
            maker.height.equalTo(55)
        }
        emailLabel.snp.makeConstraints{ (maker) in
            maker.top.equalTo(labelsStack!.snp.bottom).offset(15)
            maker.leading.equalToSuperview().offset(20)
            maker.trailing.equalToSuperview().inset(20)
            maker.height.equalTo(20)
        }
    }
    
    func reload(fullName: String, phone: String, cell: String, email: String, largeImage: UIImage){
        DispatchQueue.main.async {
            self.configureViews(fullName: fullName, phone: phone, cell: cell, email: email, largeImage: largeImage)
            self.setUpConstraints()
        }
    }
    
    @objc func callNumber(_ sender: UIButton){
        guard let phoneNumber = phone else { return }
        guard let numberUrl = URL(string: "tel://"+phoneNumber) else { return }
        UIApplication.shared.open(numberUrl)
    }
    
    @objc func callCell(_ sender: UIButton){
        guard let cellNumber = cell else { return }
        guard let numberUrl = URL(string: "tel://"+cellNumber) else { return }
        UIApplication.shared.open(numberUrl)
    }
    
    @objc func sendSMS(_ sender: UIButton){
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "Message Body"
            guard let unwrappedPhone = phone else { return }
            controller.recipients = [unwrappedPhone]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    @objc func sendCellSMS(_ sender: UIButton){
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "Message Body"
            guard let unwrappedCell = cell else { return }
            controller.recipients = [unwrappedCell]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    @objc func enlargeImage(_ sender: UITapGestureRecognizer){
        let contactPhotoViewController = ContactPhotoViewController()
        contactPhotoViewController.preferredSheetSizing = .large
        contactPhotoViewController.preferredSheetCornerRadius = 10
        contactPhotoViewController.preferredSheetBackdropColor = .white
        guard let image = largeImageView.image else { return }
        contactPhotoViewController.configure(photo: image)
        present(contactPhotoViewController, animated: true)
    }
}

extension OneContactViewController: MFMessageComposeViewControllerDelegate{
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
