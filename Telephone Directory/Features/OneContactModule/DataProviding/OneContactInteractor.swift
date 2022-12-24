//
//  OneContactInteractor.swift
//  Telephone Directory
//
//  Created by Diana Princess on 23.12.2022.
//

import Foundation
class OneContactInteractor: OneContactInteractorProtocol {
    weak var presenter: OneContactPresenterProtocol?
    var networkService: NetworkServiceProtocol!
    var router: RouterProtocol?
    
    required init(presenter: OneContactPresenterProtocol, networkService: NetworkServiceProtocol, router: RouterProtocol, oneContact: ContactItem) {
        self.presenter = presenter
        self.networkService = networkService
        self.router = router
        presenter.presentContactInfo(contact: oneContact)
    }
    
    func requestImage(imageString: String){
        let imageResponse = networkService.loadImage(from: imageString){ result in
            switch result {
            case .success(let data):
                self.presenter?.setImage(data: data!)
            case .failure(let error):
                self.presenter?.displayErrorMessage()
            }
        }
    }
}
