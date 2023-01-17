//
//  ContactListPresenter.swift
//  Telephone Directory
//
//  Created by Diana Princess on 30.11.2022.
//

import Foundation

class ContactListPresenter {
    
    private weak var view: ContactListViewProtocol?
    private var networkService: NetworkServiceProtocol!
    private var router: RouterProtocol?
    private var presentationModelsArray: [ContactPresentationModel] = []
    private var domainModelsDict: [String: ContactItem] = [:]
    init(view: ContactListViewProtocol, networkService: NetworkServiceProtocol, router: RouterProtocol) {
        self.view = view
        self.networkService = networkService
        self.router = router
    }
    
    private func addToDictAndArray(contact: ContactItem, id: String) {
        let thumbnailString = contact.thumbnailString
        self.domainModelsDict[id] = contact
        networkService.requestImage(urlString: thumbnailString){ result in
            switch result {
            case .success(let success):
                let contactPresentationModel = ContactPresentationModel(fullname: contact.fullname, thumbnailData: success, id: id)
                self.presentationModelsArray.append(contactPresentationModel)
            case .failure(_):
                let contactPresentationModel = ContactPresentationModel(fullname: contact.fullname, thumbnailData: nil, id: id)
                self.presentationModelsArray.append(contactPresentationModel)
            }
        }
    }
    
    
}

extension ContactListPresenter: ContactListPresenterProtocol {
    
    func tryRequest() {
        networkService.fetchContactList(number: 1000) { result in
            switch result {
            case .success(let success):
                for contactItem in success{
                    let id = UUID().uuidString
                    self.addToDictAndArray(contact: contactItem, id: id)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0, execute: {
                    self.view?.updateContactList(self.presentationModelsArray)
                })
            case .failure(_):
                DispatchQueue.main.async {
                    self.view?.setRequestFailureView()
                }
            }
        }
    }
    
    func filterContacts(_ searchText: String) {
        guard let contactListIsFiltered = view?.checkIfContactListIsFiltered() else { return
        }
        if contactListIsFiltered {
            let filteredContacts = presentationModelsArray.filter({ $0.fullname.lowercased().contains(searchText.lowercased())
            })
            DispatchQueue.main.async {
                self.view?.updateContactList(filteredContacts)
            }
        } else {
            DispatchQueue.main.async {
                self.view?.updateContactList(self.presentationModelsArray)
            }
        }
    }
    
    func openContact(id: String) {
        guard let contactDomainModel = domainModelsDict[id] else { return }
        router?.openContact(contact: contactDomainModel)
    }
}
