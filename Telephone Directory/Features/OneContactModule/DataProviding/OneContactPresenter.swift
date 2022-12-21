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
    var networkService: NetworkServiceProtocol!
    var router: RouterProtocol?
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
    required init(view: OneContactViewProtocol, networkService: NetworkServiceProtocol, router: RouterProtocol, fullName: String, phone: String, cell: String, email: String, largeImgStr: String, nat: String) {
        self.view = view
        self.networkService = networkService
        self.router = router
        self.largeImgStr = largeImgStr
        Task{
            await useInfo(fullName: fullName, phone: phone, cell: cell, email: email, largeImgStr: largeImgStr, nat: nat)
        }
    }
    
    func useInfo(fullName: String, phone: String, cell: String, email: String, largeImgStr: String, nat: String) async {
        guard let countryCode = countryCodes[nat] else { return }
        let unfilteredPhone = countryCode+"-"+phone
        let unfilteredCell = countryCode+"-"+cell
        let fullPhone = unfilteredPhone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        let fullCell = unfilteredCell.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        view?.reload(fullName: fullName, phone: fullPhone, cell: fullCell, email: email)
        let image = await requestImage(string: largeImgStr)
        view?.setImage(image: image)
    }
    
    func requestImage(string: String) async -> UIImage {
        guard let imageUrlString = string as? String else {
            return UIImage(named: "Error")!}
        let result = await self.networkService.requestImage(urlString: imageUrlString)
        switch result.status {
        case .success:
            return UIImage(data: result.data!)!
        case .error:
            return UIImage(named: "Error")!
        case .noConnection:
            return UIImage(named: "Error")!
        }
    }
    
    func findImage() {
        Task{
            let imgStr = largeImgStr ?? "https://icon-library.com/images/no-image-available-icon/no-image-available-icon-7.jpg"
            let largeImage = await requestImage(string: imgStr)
            view?.setImage(image: largeImage)
        }
    }
}
