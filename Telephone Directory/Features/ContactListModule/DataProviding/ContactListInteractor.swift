//
//  ContactListInteractor.swift
//  Telephone Directory
//
//  Created by Diana Princess on 22.12.2022.
//

import Foundation

class ContactListInteractor: ContactListInteractorProtocol {
    
    weak var presenter: ContactListPresenterProtocol?
    var networkService: NetworkServiceProtocol!
    var router: RouterProtocol?
    
    required init(presenter: ContactListPresenterProtocol, networkService: NetworkServiceProtocol, router: RouterProtocol) {
        self.presenter = presenter
        self.networkService = networkService
        self.router = router
    }
    
    func requestContacts(numberOfContacts: Int){
        let networkResponse = networkService.loadContactList(number: numberOfContacts){ result in
            switch result {
            case .success(let contactModel):
                if contactModel != nil{
                    contactModel?.forEach({ self.createNewContactItem(contact: $0)})
                    self.presenter?.fillViewWithContent()
                }
            case .failure(let error):
                self.presenter?.errorAlert(error: error)
            }
            
        }
        /*
        let networkResponse = networkService.processContactListRequest(1000)
        switch networkResponse.status{
        case .success:
            let data = networkResponse.result
            if data?.error != nil{
                return .failure(HTTPError.httpError(-1))
            } else {
                var contacts: [ContactItem] = []
                data?.results?.forEach({contacts.append(createNewContactItem(contact: $0))})
                return .success(contacts)
            }
        case .error:
            return .failure(networkResponse.error ?? HTTPError.httpError(0))
        }
         */
    }
    
    private func createNewContactItem(contact: ContactInstance){
        let fullname = contact.name.first+" "+contact.name.last
        let phone = contact.phone
        let cell = contact.cell
        let mail = contact.email
        let nat = contact.nat
        let largeImageStr = contact.picture.large
        let thumbnailUrl = contact.picture.thumbnail
        let contact = ContactItem(fullname: fullname, email: mail, phone: phone, cell: cell, largeImageStr: largeImageStr,nat: nat)
        getImageData(thumbnailUrl, contact: contact)
    }
    
    func getImageData(_ string: String, contact: ContactItem){
        let response = networkService.loadImage(from: string){ result in
                switch result {
                case .success(let data):
                    self.presenter?.collectData(data, contact: contact)
                case .failure(let error):
                    self.presenter?.collectData(nil, contact: contact)
                }
        }
    }
    
    func openContact(contact: ContactItem) {
        router?.openContact(contact: contact)
    }
}
