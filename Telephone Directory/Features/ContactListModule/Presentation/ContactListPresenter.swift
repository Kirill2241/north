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
    private var dataProviderService: ContactListDataProviderProtocol!
    private var dataCache: DataCacheTypeProtocol
    init(view: ContactListViewProtocol, networkService: NetworkServiceProtocol, router: RouterProtocol, dataProviderService: ContactListDataProviderProtocol, dataCache: DataCacheTypeProtocol) {
        self.view = view
        self.networkService = networkService
        self.router = router
        self.dataProviderService = dataProviderService
        self.dataCache = dataCache
    }
    
    private func createDataForStorage(_ contacts: [ContactItem]) -> ([ContactPresentationModel], [String: ContactItem]) {
        var contactList: [ContactPresentationModel] = []
        var contactsDict: [String: ContactItem] = [:]
        for contact in contacts{
            let id = UUID().uuidString
            let presentationModel = ContactPresentationModel(fullname: contact.fullname, thumbnailString: contact.thumbnailString, thumbnailData: nil, id: id)
            contactList.append(presentationModel)
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
                    let contactsInfo = self.createDataForStorage(success)
                    self.dataProviderService?.setDataStorageIfEmpty(contactsInfo.0, contactsInfo.1)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                        let state = ContactListViewState.downloaded(self.dataProviderService)
                        self.updateUI(state: state)
                    })
                }
            case .failure(let error):
                let state = ContactListViewState.error(error)
                self.updateUI(state: state)
            }
        }
    }
    
    func requestThumbnail(contacts: [ContactPresentationModel]) -> [ContactPresentationModel] {
        var contactsWithThumbnailRequests: [ContactPresentationModel] = []
        let group = DispatchGroup()
        for contact in contacts {
            if dataCache.lookForImageData(for: contact.thumbnailString) == nil {
                group.enter()
                networkService.requestImage(urlString: contact.thumbnailString) { result in
                    switch result {
                    case .success(let success):
                        let contactWithImage = ContactPresentationModel(fullname: contact.fullname, thumbnailString: contact.thumbnailString, thumbnailData: success, id: contact.id)
                        contactsWithThumbnailRequests.append(contactWithImage)
                    case .failure(_):
                        let contactWithoutImage = ContactPresentationModel(fullname: contact.fullname, thumbnailString: contact.thumbnailString, thumbnailData: nil, id: contact.id)
                        contactsWithThumbnailRequests.append(contactWithoutImage)
                    }
                    group.leave()
                }
            } else {
                guard let data = dataCache.lookForImageData(for: contact.thumbnailString) else { return [] }
                let contactWithImage = ContactPresentationModel(fullname: contact.fullname, thumbnailString: contact.thumbnailString, thumbnailData: data, id: contact.id)
                contactsWithThumbnailRequests.append(contactWithImage)
            }
            group.wait()
        }
        return contactsWithThumbnailRequests
    }
    
    func filterContacts(_ searchText: String, listIsFiltered: Bool) {
        if listIsFiltered {
            let contactFilterer = ContactListFilterer(searchText: searchText, filteredContacts: dataProviderService?.filterContactList(searchText) ?? [])
            dataProviderService?.contactListStatus = .filtered(contactFilterer)
            let state = ContactListViewState.downloaded(dataProviderService)
            updateUI(state: state)
        } else {
            dataProviderService.contactListStatus = .complete
            let state = ContactListViewState.downloaded(dataProviderService)
            updateUI(state: state)
        }
    }
    
    func openContact(id: String) {
        guard let contactItem = dataProviderService.getAContactDomainModelByID(id: id) else { return }
        router?.openContact(contact: contactItem)
    }
}
