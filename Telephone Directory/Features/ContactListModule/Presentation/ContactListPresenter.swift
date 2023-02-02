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
    private var contactsStorageService: DownloadedContactsStorageProtocol!
    
    init(view: ContactListViewProtocol, networkService: NetworkServiceProtocol, router: RouterProtocol, contactsStorageService: DownloadedContactsStorageProtocol) {
        self.view = view
        self.networkService = networkService
        self.router = router
        self.contactsStorageService = contactsStorageService
    }
}

// MARK: ContactListPresenterProtocol implementation
extension ContactListPresenter: ContactListPresenterProtocol {
    
    func tryRequest() {
        DispatchQueue.main.async {
            self.view?.isLoading(true)
        }
        networkService.fetchContactList(number: 1000) { result in
            switch result {
            case .success(let contacts):
                self.contactsStorageService?.setDataStorageIfEmpty(contacts)
                DispatchQueue.main.async {
                    self.view?.isLoading(false)
                }
                self.contactsStorageService.deactivateFiltering()
            case .failure(let error):
                DispatchQueue.main.async {
                    self.view?.isLoading(false)
                    self.view?.setRequestFailureView(error: error)
                }
            }
        }
    }
    
    func downloadThumbnailForContact(at index: Int) {
        contactsStorageService.downloadThumbnailForContact(at: index)
    }
    
    func filterContacts(_ searchText: String?) {
        if searchText == "" {
            contactsStorageService.deactivateFiltering()
        } else {
            guard let searchText = searchText else { return }
            contactsStorageService.filterContactList(searchText)
        }
    }
    
    func openContact(id: String) {
        guard let contactItem = contactsStorageService.getAContactDomainModelByID(id: id) else { return }
        router?.openContact(contact: contactItem)
    }
}

// MARK: Implemenation of DownloadedContactsStorageDelegate
extension ContactListPresenter: DownloadedContactsStorageDelegate {
    func requestThumbnailForContact(thumbnailURL: String, at index: Int, completion: @escaping (Result<Data, Error>) -> Void) {
        networkService.requestImage(urlString: thumbnailURL, index: index){ result in
            switch result {
            case .success(let data):
                completion(.success(data))
                return
            case .failure(let error):
                completion(.failure(error))
                return
            }
        }
    }
    
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
