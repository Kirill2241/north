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
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 15
        btn.setImage(UIImage(systemName: "phone.fill"), for: .normal)
        return btn
    }()
    let sendSMSButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = .systemGreen
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 15
        btn.setImage(UIImage(systemName: "message.fill"), for: .normal)
        return btn
    }()
    let callCellButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = .systemGreen
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 15
        btn.setImage(UIImage(systemName: "phone.fill"), for: .normal)
        return btn
    }()
    let sendCellSMSButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = .systemGreen
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 15
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

    func configureViews(fullName: String, phone: String, cell: String, email: String) {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "InternetConnectionMonitor")
        monitor.pathUpdateHandler = { pathUpdateHandler in
                    if pathUpdateHandler.status == .satisfied {
                        print("Internet connection is on.")
                        DispatchQueue.main.async{
                            self.presenter?.findImage()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.noConnection()
                        }
                    }
                }
        monitor.start(queue: queue)
        fullNameLabel.text = fullName
        phoneLabel.text = "Телефон: "+phone
        cellPhoneLabel.text = "Мобильный: "+cell
        emailLabel.text = "Эл. почта: "+email
        
        self.phone = phone
        self.cell = cell
        
        view.addSubview(fullNameLabel)
        labelsStack = UIStackView(arrangedSubviews: [phoneLabel, cellPhoneLabel])
        labelsStack?.axis = .vertical
        labelsStack?.alignment = .fill
        labelsStack?.distribution = .fillEqually
        labelsStack?.spacing = 20
        callButton.addTarget(self, action: #selector(callNumber(_:)), for: .touchUpInside)
        callCellButton.addTarget(self, action: #selector(callCell(_:)), for: .touchUpInside)
        sendSMSButton.addTarget(self, action: #selector(sendSMS(_:)), for: .touchUpInside)
        sendCellSMSButton.addTarget(self, action: #selector(sendCellSMS(_:)), for: .touchUpInside)
        phoneButtonsStack = UIStackView(arrangedSubviews: [callButton, sendSMSButton])
        phoneButtonsStack?.axis = .horizontal
        phoneButtonsStack?.alignment = .fill
        phoneButtonsStack?.distribution = .fillEqually
        phoneButtonsStack?.spacing = 20
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
        fullNameLabel.snp.makeConstraints{ (maker) in
            let fullNameOffset = view.frame.height*0.3+15+70
            maker.top.equalTo(fullNameOffset)
            maker.leading.equalToSuperview().offset(20)
            maker.trailing.equalToSuperview().inset(20)
            maker.height.equalTo(27)
        }
        labelsStack!.snp.makeConstraints{ (maker) in
            maker.top.equalTo(fullNameLabel.snp.bottom).offset(15)
            maker.leading.equalToSuperview().offset(20)
            maker.width.equalToSuperview().multipliedBy(0.7)
            maker.height.equalTo(75)
        }
        buttonsVerticalStack!.snp.makeConstraints{ (maker) in
            maker.top.equalTo(fullNameLabel.snp.bottom).offset(15)
            maker.trailing.equalToSuperview().inset(20)
            maker.width.equalTo(80)
            maker.height.equalTo(75)
        }
        emailLabel.snp.makeConstraints{ (maker) in
            maker.top.equalTo(labelsStack!.snp.bottom).offset(20)
            maker.leading.equalToSuperview().offset(20)
            maker.trailing.equalToSuperview().inset(20)
            maker.height.equalTo(20)
        }
    }
    
    func reload(fullName: String, phone: String, cell: String, email: String){
        DispatchQueue.main.async {
            self.configureViews(fullName: fullName, phone: phone, cell: cell, email: email)
            self.setUpConstraints()
        }
    }
    
    func setImage(image: UIImage){
        DispatchQueue.main.async {
            self.largeImageView.image = image
            let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.enlargeImage(_:)))
            self.largeImageView.addGestureRecognizer(imageGestureRecognizer)
            self.view.addSubview(self.largeImageView)
            self.largeImageView.snp.makeConstraints{ (maker) in
                maker.top.equalToSuperview().offset(70)
                maker.leading.trailing.equalToSuperview()
                maker.height.equalToSuperview().multipliedBy(0.3)
            }
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
        DispatchQueue.main.async {
            let vc = CustomModalViewController()
            guard let image = self.largeImageView.image else { return }
            vc.addImage(image: image)
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: false)
        }
    }
    
    func noConnection(){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Не удалось загрузить изображение", message: "Чтобы загрузить изображение, необходимо подключение к Интернету.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension OneContactViewController: MFMessageComposeViewControllerDelegate{
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
}
