//
//  OneContactPresenter.swift
//  Telephone Directory
//
//  Created by Diana Princess on 02.12.2022.
//

import Foundation
import MessageUI

class OneContactPresenter: NSObject {
    private weak var view: OneContactViewProtocol?
    private var networkService: NetworkServiceProtocol!
    private var router: RouterProtocol?
    private let contactItem: ContactItem
    private var phoneNumber: String?
    private var cellPhoneNumber: String?
    private let countryCodes: [String: String] = [
        "AU": "61",
        "BR": "55",
        "CA": "1",
        "CH": "41",
        "DE": "49",
        "DK": "45",
        "ES": "34",
        "FI": "358",
        "FR": "32",
        "GB": "44",
        "IE": "353",
        "IN": "91",
        "IR": "98",
        "MX": "52",
        "NL": "31",
        "NO": "47",
        "NZ": "64",
        "RS": "381",
        "TR": "90",
        "UA": "380",
        "US": "1"
    ]
    
    required init(view: OneContactViewProtocol, networkService: NetworkServiceProtocol, router: RouterProtocol, contact: ContactItem) {
        self.view = view
        self.networkService = networkService
        self.router = router
        self.contactItem = contact
        super.init()
        let phoneTuple = setUpPhones(phone: contact.phone, cell: contact.cell, nat: contact.nat)
        self.phoneNumber = phoneTuple.0
        self.cellPhoneNumber = phoneTuple.1
    }
    
    private func setUpPhones(phone: String, cell: String, nat: String) -> (String, String) {
        guard let countryCode = countryCodes[nat] else { return ("", "")}
        let unfilteredPhone = countryCode+"-"+phone
        let unfilteredCell = countryCode+"-"+cell
        let fullPhone = unfilteredPhone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        let fullCell = unfilteredCell.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        return (fullPhone, fullCell)
    }
    
    private func getNecessaryPhone(type: PhoneTypes) -> String {
        switch type {
        case .regular:
            guard let phoneNumber = phoneNumber else { return "" }
            return phoneNumber
        case .cell:
            guard let cellPhoneNumber = cellPhoneNumber else { return "" }
            return cellPhoneNumber
        }
    }
}

// MARK: OneContactPresenterProtocol implementation
extension OneContactPresenter: OneContactPresenterProtocol {
    func makeACall(type: PhoneTypes) {
        let phone = getNecessaryPhone(type: type)
        guard let numberUrl = URL(string: "tel://"+phone) else { return }
        UIApplication.shared.open(numberUrl)
    }
    
    func sendSMS(type: PhoneTypes) {
        let phone = getNecessaryPhone(type: type)
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "Message Body"
            controller.recipients = [phone]
            controller.messageComposeDelegate = self
            view?.render(OneContactViewController.RenderOptions(screenState: .smsComposing(controller)))
        }
    }
    
    func updateContactInfo() -> ContactDetailedInfo {
        guard let countryCode = countryCodes[contactItem.nat] else { return ContactDetailedInfo(fullname: contactItem.fullname, phone: contactItem.phone, cell: contactItem.cell, email: contactItem.email) }
        let unfilteredPhone = countryCode+"-"+contactItem.phone
        let unfilteredCell = countryCode+"-"+contactItem.cell
        let fullPhone = unfilteredPhone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        let fullCell = unfilteredCell.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        return ContactDetailedInfo(fullname: contactItem.fullname, phone: fullPhone, cell: fullCell, email: contactItem.email)
    }
    
    func requestImage() {
        DispatchQueue.main.async {
            let loadingOption = OneContactViewController.RenderOptions(screenState: .imageIsLoading)
            self.view?.render(loadingOption)
        }
        networkService.requestImage(urlString: contactItem.largeImageStr, type: .large) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    let successOption = OneContactViewController.RenderOptions(screenState: .downloaded(data))
                    self.view?.render(successOption)
                case .failure(let error):
                    let failureOption = OneContactViewController.RenderOptions(screenState: .error(error))
                    self.view?.render(failureOption)
                case .isCancelled:
                    let cancelledOption = OneContactViewController.RenderOptions(screenState: .cancelled)
                    self.view?.render(cancelledOption)
                }
            }
        }
    }
}

extension OneContactPresenter: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        view?.render(OneContactViewController.RenderOptions(screenState: .smsComposingEnded(controller)))
    }
}
