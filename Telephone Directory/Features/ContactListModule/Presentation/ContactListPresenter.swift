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
    private lazy var imageDownloadsInProgress: [Int: Operation] = [:]
    private lazy var imageDownloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Downloading thumbnails"
        queue.maxConcurrentOperationCount = 20
        return queue
    }()
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
            let presentationModel = ContactPresentationModel(fullname: contact.fullname, thumbnailString: contact.thumbnailString, thumbnail: ContactThumbnail(state: .new), id: id)
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
        case .downloaded(let downloadedContactsState):
            DispatchQueue.main.async {
                self.view?.isLoading(false)
                switch downloadedContactsState.contactListFilteringState{
                case .notFiltered(let array):
                    self.view?.updateContactList(array)
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
                let contactsInfo = self.createDataForStorage(success)
                self.downloadedContactsState?.setDataStorageIfEmpty(contactsInfo.0, contactsInfo.1)
                self.downloadedContactsState.getFullArray()
                let state = ContactListViewState.downloaded(self.downloadedContactsState)
                self.updateUI(state: state)
            case .failure(let error):
                let state = ContactListViewState.error(error)
                self.updateUI(state: state)
            }
        }
    }
    
    func contactsWithImage(at index: Int) {
        guard let contact = downloadedContactsState.getAContactPresentationModelByIndex(index: index) else { return }
            if contact.thumbnail.state == .new {
                let imageData = imageDataCache.lookForImageData(for: contact.thumbnailString)
                switch imageData {
                case .none:
                    guard imageDownloadsInProgress[index] == nil else { return }
                    self.imageDownloadsInProgress[index] = self.networkService
                    if index == 0 {
                        self.imageDownloadQueue.addOperation(self.networkService)
                    }
                   
                    networkService.requestImage(urlString: contact.thumbnailString) { result in
                        switch result {
                        case .success(let imageData):
                            let newContact = ContactPresentationModel(fullname: contact.fullname, thumbnailString: contact.thumbnailString, thumbnail: ContactThumbnail(state: .downloaded(imageData)), id: contact.id)
                            self.downloadedContactsState.insertNewContact(newContact, at: index)
                        case .failure(_):
                            let newContact = ContactPresentationModel(fullname: contact.fullname, thumbnailString: contact.thumbnailString, thumbnail: ContactThumbnail(state: .failed), id: contact.id)
                            self.downloadedContactsState.insertNewContact(newContact, at: index)
                        }
                    }
                case .some(let wrapped):
                    let newContact = ContactPresentationModel(fullname: contact.fullname, thumbnailString: contact.thumbnailString, thumbnail: ContactThumbnail(state: .downloaded(wrapped)), id: contact.id)
                    downloadedContactsState.insertNewContact(newContact, at: index)
                }
            }
        downloadedContactsState.getFullArray()
        let state = ContactListViewState.downloaded(downloadedContactsState)
        updateUI(state: state)
    }
    
    func filterContacts(_ searchText: String, listIsFiltered: Bool) {
        if listIsFiltered {
            downloadedContactsState.filterContactList(searchText)
            let state = ContactListViewState.downloaded(downloadedContactsState)
            updateUI(state: state)
        } else {
            downloadedContactsState.getFullArray()
            let state = ContactListViewState.downloaded(downloadedContactsState)
            updateUI(state: state)
        }
    }
    
    func openContact(id: String) {
        guard let contactItem = downloadedContactsState.getAContactDomainModelByID(id: id) else { return }
        router?.openContact(contact: contactItem)
    }
}
