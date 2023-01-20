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
    init(view: ContactListViewProtocol, networkService: NetworkServiceProtocol, router: RouterProtocol) {
        self.view = view
        self.networkService = networkService
        self.router = router
    }
    
    private func createDataForStorage(_ contacts: [ContactItem]) -> ([ContactPresentationModel], [String: ContactItem]) {
        let group = DispatchGroup()
        var contactList: [ContactPresentationModel] = []
        var contactsDict: [String: ContactItem] = [:]
        for contact in contacts{
            let thumbnailString = contact.thumbnailString
            let id = UUID().uuidString
            group.enter()
            networkService.requestImage(urlString: thumbnailString){ result in
                switch result {
                case .success(let success):
                    let contactPresentationModel = ContactPresentationModel(fullname: contact.fullname, thumbnailData: success, id: id)
                    contactList.append(contactPresentationModel)
                case .failure(_):
                    let contactPresentationModel = ContactPresentationModel(fullname: contact.fullname, thumbnailData: nil, id: id)
                    contactList.append(contactPresentationModel)
                }
                group.leave()
            }
            group.wait()
            contactsDict[id] = contact
        }
        return (contactList, contactsDict)
    }
    
    private func updateUI(state: ContactListViewState){
        switch state {
        case .loading:
            DispatchQueue.main.async {
                self.view?.isLoading(true)
            }
        case .error(let error):
            DispatchQueue.main.async {
                self.view?.isLoading(false)
                self.view?.setRequestFailureView(error: error)
            }
        case .downloaded(let contactListDataStorage):
            DispatchQueue.main.async {
                self.view?.isLoading(false)
                switch contactListDataStorage.contactListStatus{
                case .complete:
                    self.view?.updateContactList(contactListDataStorage.getFullArray())
                case .filtered(let filterer):
                    self.view?.updateContactList(filterer.filteredContacts)
                }
            }
        }
    }
    
}

extension ContactListPresenter: ContactListPresenterProtocol {
    
    func tryRequest() {
        updateUI(state: ContactListViewState.loading)
        networkService.fetchContactList(number: 1000) { result in
            switch result {
            case .success(let success):
                DispatchQueue.global(qos: .userInitiated).async {
                    var contactsInfo = self.createDataForStorage(success)
                    let dataStorage = ContactListDataStorage.shared
                    dataStorage.setDataStorageIfEmpty(contactsInfo.0, contactsInfo.1)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 7.0, execute: {
                        let state = ContactListViewState.downloaded(dataStorage)
                        self.updateUI(state: state)
                    })
                }
            case .failure(let error):
                let state = ContactListViewState.error(error)
                self.updateUI(state: state)
            }
        }
    }
    
    func filterContacts(_ searchText: String, listIsFiltered: Bool) {
        let contactListDataStorage = ContactListDataStorage.shared
        if listIsFiltered {
            let contactFilterer = ContactListFilterer(searchText: searchText, filteredContacts: contactListDataStorage.filterContactList(searchText))
            contactListDataStorage.contactListStatus = .filtered(contactFilterer)
            let state = ContactListViewState.downloaded(contactListDataStorage)
            updateUI(state: state)
        } else {
            contactListDataStorage.contactListStatus = .complete
            let state = ContactListViewState.downloaded(contactListDataStorage)
            updateUI(state: state)
        }
    }
    
    func openContact(id: String) {
        let contactListDataStorage = ContactListDataStorage.shared
        guard let contactItem = contactListDataStorage.getAContactDomainModelByID(id: id) else { return }
        router?.openContact(contact: contactItem)
    }
}
