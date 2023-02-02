//
//  OneContactPresenter.swift
//  Telephone Directory
//
//  Created by Diana Princess on 02.12.2022.
//

import Foundation

class OneContactPresenter {
    private weak var view: OneContactViewProtocol?
    private var networkService: NetworkServiceProtocol!
    private var router: RouterProtocol?
    private let contactItem: ContactItem?
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
    }
    
    private func presentContactInfo(contact: ContactItem) {
        guard let countryCode = countryCodes[contact.nat] else { return }
        let unfilteredPhone = countryCode+"-"+contact.phone
        let unfilteredCell = countryCode+"-"+contact.cell
        let fullPhone = unfilteredPhone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        let fullCell = unfilteredCell.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        view?.updateView(fullName: contact.fullname, phone: fullPhone, cell: fullCell, email: contact.email)
    }
}

// MARK: OneContactPresenterProtocol implementation
extension OneContactPresenter: OneContactPresenterProtocol {
    func getContactInfo() {
        guard let contact = contactItem else { return }
        presentContactInfo(contact: contact)
    }
    
    func requestImage() {
        DispatchQueue.main.async {
            self.view?.imageIsLoading(true)
        }
        guard let largeImageURLString = contactItem?.largeImageStr else { return }
        networkService.requestImage(urlString: largeImageURLString, index: -1) { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.view?.imageIsLoading(false)
                    self.view?.setImage(data: data)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.view?.imageIsLoading(false)
                    self.view?.setRequestFailureView(error: error)
                }
            }
        }
    }
}
