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
            let loadingRenderOption = ContactListViewController.RenderOptions(state: .isLoading)
            self.view?.render(loadingRenderOption)
        }
        self.networkService.fetchContactList(number: 1000) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let contacts):
                    self.contactsStorageService?.setDataStorageIfEmpty(contacts)
                    self.contactsStorageService.deactivateFiltering()
                case .failure(let error):
                    let failureRenderOption = ContactListViewController.RenderOptions(state: .error(error))
                    self.view?.render(failureRenderOption)
                }
            }
        }
    }
    
    func downloadThumbnailForContact(at index: Int) {
        guard let contact = contactsStorageService.getAContactPresentationModelByIndex(index: index) else { return }
        networkService.requestImage(urlString: contact.thumbnailString, index: index){ result in
            switch result {
            case .success(let data):
                self.contactsStorageService.updateThumbnailForContact(at: index, data: data, contact: contact)
                return
            case .failure(_):
                self.contactsStorageService.updateThumbnailForContact(at: index, data: nil, contact: contact)
                return
            }
        }
    }
    
    func filterContacts(_ searchText: String?) {
        (searchText?.isEmpty ?? true) ? contactsStorageService.deactivateFiltering() : contactsStorageService.filterContactList(searchText!)
    }
    
    func openContact(id: String) {
        guard let contactItem = contactsStorageService.getAContactDomainModelByID(id: id) else { return }
        router?.openContact(contact: contactItem)
    }
}

// MARK: Implemenation of DownloadedContactsStorageDelegate
extension ContactListPresenter: DownloadedContactsStorageDelegate {
    func contactsStateDidChange(_ state: ContactListFilteringState) {
        DispatchQueue.main.async {
            switch state {
            case .notFiltered(let fullArray):
                let notFilteredRenderOption = ContactListViewController.RenderOptions(state: .updated(fullArray))
                self.view?.render(notFilteredRenderOption)
            case .filtered(let filteredArray):
                let filteredRenderOption = ContactListViewController.RenderOptions(state: .updated(filteredArray))
                self.view?.render(filteredRenderOption)
            }
        }
    }
}
