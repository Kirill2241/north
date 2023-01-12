//
//  ContactListPresenter.swift
//  Telephone Directory
//
//  Created by Diana Princess on 30.11.2022.
//

import Foundation

class ContactListPresenter: ContactListPresenterProtocol {
    
    weak var view: ContactListViewProtocol?
    var networkService: NetworkServiceProtocol!
    var router: RouterProtocol?
    private var contactsThumbnailsDictStruct: ContactItemsAndThumbnailsDictionary = ContactItemsAndThumbnailsDictionary(dictionary: [:])
    
    init(view: ContactListViewProtocol, networkService: NetworkServiceProtocol, router: RouterProtocol) {
        self.view = view
        self.networkService = networkService
        self.router = router
    }
    
    func tryRequest() {
        networkService.prepareNetworkResponseForPresentation(number: 1000) { result in
            switch result.1{
            case .failure:
                self.view?.setRequestFailureView()
            case .success:
                guard let array = result.0 else { return }
                for i in 0...array.count-1{
                    self.getThumbnail(string: array[i].thumbnailString, contact: array[i])
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
                    self.view?.setViewControllerDataSource(self.contactsThumbnailsDictStruct.dictionary)
                    self.view?.setContentView()
                })
            }
        }
    }
    
    private func getThumbnail(string: String, contact: ContactItem) {
        networkService.requestImage(urlString: string){ result in
            self.contactsThumbnailsDictStruct.dictionary[contact] = result
        }
    }
    
    func filterContacts(_ searchText: String) {
        guard let contactListIsFiltered = view?.checkIfContactListIsFiltered() else { return }
        if contactListIsFiltered {
            let filteredContacts = contactsThumbnailsDictStruct.dictionary.filter({ $0.key.fullname.lowercased().contains(searchText.lowercased())
            })
            if filteredContacts.count == 0 {
                view?.createNothingFoundLabel()
            } else {
                view?.removeNothingFoundLabel()
            }
            view?.setViewControllerDataSource(filteredContacts)
            view?.applyFilter()
        } else {
            view?.setViewControllerDataSource(contactsThumbnailsDictStruct.dictionary)
            view?.removeNothingFoundLabel()
            view?.applyFilter()
        }
    }
    
    func openContact(_ contact: ContactItem) {
        router?.openContact(contact: contact)
    }
}
