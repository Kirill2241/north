//
//  OneContactPresenter.swift
//  Telephone Directory
//
//  Created by Diana Princess on 02.12.2022.
//

import Foundation
import UIKit

class OneContactPresenter: OneContactPresenterProtocol {
    weak var view: OneContactViewProtocol?
    
    var interactor: OneContactInteractorProtocol?
    var largeImgStr: String?
    let countryCodes: [String: String] = [
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
    required init(view: OneContactViewProtocol) {
        self.view = view
    }
    
    func useInfo(contact: ContactItem) {
        guard let countryCode = countryCodes[contact.nat] else { return }
        let unfilteredPhone = countryCode+"-"+contact.phone
        let unfilteredCell = countryCode+"-"+contact.cell
        let fullPhone = unfilteredPhone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        let fullCell = unfilteredCell.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        view?.reload(fullName: contact.fullname, phone: fullPhone, cell: fullCell, email: contact.email)
        
    }
    
    func presentContactInfo(contact: ContactItem) {
        guard let countryCode = countryCodes[contact.nat] else { return }
        let unfilteredPhone = countryCode+"-"+contact.phone
        let unfilteredCell = countryCode+"-"+contact.cell
        let fullPhone = unfilteredPhone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        let fullCell = unfilteredCell.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        view?.reload(fullName: contact.fullname, phone: fullPhone, cell: fullCell, email: contact.email)
    }
    
    func requestImage(string: String) {
        let result = interactor?.requestImage(imageString: string)
       
        /*
        guard let imageUrlString = string as? String else {
            return UIImage(named: "Error")!}
        let result = await self.networkService.requestImage(urlString: imageUrlString)
        switch result.status {
        case .success:
            return UIImage(data: result.data!)!
        case .error:
            return UIImage(named: "Error")!
        }*/
    }
    
    func setImage(data: Data) {
        view?.setImage(data: data)
    }
    
    func displayErrorMessage() {
        view?.setRequestFailureView()
    }
    func findImage() {
        guard let string = largeImgStr else { return  }
        interactor?.requestImage(imageString: string)
    }
}
