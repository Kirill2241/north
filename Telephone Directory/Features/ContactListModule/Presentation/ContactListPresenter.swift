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
    private var downloadedContactsState: DownloadedContactsStateProtocol!
    private var imageDataCache: ImageDataCacheTypeProtocol
    private var filterString = ""
    init(view: ContactListViewProtocol, networkService: NetworkServiceProtocol, router: RouterProtocol, downloadedContactsState: DownloadedContactsStateProtocol, dataCache: ImageDataCacheTypeProtocol) {
        self.view = view
        self.networkService = networkService
        self.router = router
        self.downloadedContactsState = downloadedContactsState
        self.imageDataCache = dataCache
    }
    
    private func createDataForStorage(_ contacts: [ContactItem]) -> ([ContactPresentationModel], [String: ContactItem]) {
        var contactList: [ContactPresentationModel] = []
        var contactsDict: [String: ContactItem] = [:]
        for contact in contacts{
            let id = UUID().uuidString
            let presentationModel = ContactPresentationModel(fullname: contact.fullname, thumbnailString: contact.thumbnailString, thumbnailState: ContactThumbnailState.notDownloaded, id: id)
            contactList.append(presentationModel)
            contactsDict[id] = contact
        }
        return (contactList, contactsDict)
    }
}

extension ContactListPresenter: ContactListPresenterProtocol {
    
    func tryRequest() {
        DispatchQueue.main.async {
            self.view?.isLoading(true)
        }
        networkService.fetchContactList(number: 1000) { result in
            switch result {
            case .success(let success):
                let contactsInfo = self.createDataForStorage(success)
                self.downloadedContactsState?.setDataStorageIfEmpty(contactsInfo.0, contactsInfo.1)
                DispatchQueue.main.async {
                    self.view?.isLoading(false)
                }
                self.downloadedContactsState.deactivateFiltering()
            case .failure(let error):
                DispatchQueue.main.async {
                    self.view?.isLoading(false)
                    self.view?.setRequestFailureView(error: error)
                }
            }
        }
    }
    
    func downloadThumbnailForContact(at index: Int) {
        guard let contact = downloadedContactsState.getAContactPresentationModelByIndex(index: index) else { return }
            if contact.thumbnailState == .notDownloaded {
                let imageData = imageDataCache.lookForImageData(for: contact.thumbnailString)
                switch imageData {
                case .none:
                    networkService.requestImage(urlString: contact.thumbnailString, index: index) { result in
                        switch result {
                        case .success(let imageData):
                            let newContact = ContactPresentationModel(fullname: contact.fullname, thumbnailString: contact.thumbnailString, thumbnailState: ContactThumbnailState.downloaded(imageData), id: contact.id)
                            self.imageDataCache.insertImageData(imageData, for: contact.thumbnailString)
                            self.downloadedContactsState.insertNewContact(newContact, at: index)
                        case .failure(_):
                            let newContact = ContactPresentationModel(fullname: contact.fullname, thumbnailString: contact.thumbnailString, thumbnailState: ContactThumbnailState.failed, id: contact.id)
                            self.downloadedContactsState.insertNewContact(newContact, at: index)
                        }
                    }
                case .some(let storedImageData):
                    let newContact = ContactPresentationModel(fullname: contact.fullname, thumbnailString: contact.thumbnailString, thumbnailState: ContactThumbnailState.downloaded(storedImageData), id: contact.id)
                    downloadedContactsState.insertNewContact(newContact, at: index)
                }
            }
        switch downloadedContactsState.contactListFilteringState {
        case .notFiltered(_):
            downloadedContactsState.deactivateFiltering()
        case .filtered(_):
            downloadedContactsState.filterContactList(filterString)
        }
    }
    
    func filterContacts(_ searchText: String, listIsFiltered: Bool) {
        if listIsFiltered {
            filterString = searchText
            downloadedContactsState.filterContactList(searchText)
        } else {
            filterString = ""
            downloadedContactsState.deactivateFiltering()
        }
    }
    
    func openContact(id: String) {
        guard let contactItem = downloadedContactsState.getAContactDomainModelByID(id: id) else { return }
        router?.openContact(contact: contactItem)
    }
}

extension ContactListPresenter: DownloadedContactsStateDelegate {
    func contactsStateDidChange(_ state: ContactListFilteringState) {
        DispatchQueue.main.async {
            switch state {
            case .notFiltered(let fullArray):
                self.view?.updateContactList(fullArray)
            case .filtered(let filteredArray):
                self.view?.updateContactList(filteredArray)
            }
        }
    }
}
