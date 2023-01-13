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
    private var contactsThumbnailsDictStruct: ContactPresentationModelsDictionary = ContactPresentationModelsDictionary(dictionary: [:])
    private var contactDomainModels: [ContactItem] = []
    
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
                    self.addToDict(contact: array[i], index: i)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0, execute: {
                    self.view?.setViewControllerDataSource(self.contactsThumbnailsDictStruct.dictionary)
                    self.view?.setContentView()
                })
            }
        }
    }
    
    private func addToDict(contact: ContactItem, index: Int) {
        contactDomainModels.append(contact)
        let thumbnailString = contact.thumbnailString
        networkService.requestImage(urlString: thumbnailString){ result in
            let contactPresentationModel = ContactPresentationModel(fullname: contact.fullname, thumbnailData: result)
            self.contactsThumbnailsDictStruct.dictionary[index] = contactPresentationModel
        }
    }
    
    func filterContacts(_ searchText: String) {
        guard let contactListIsFiltered = view?.checkIfContactListIsFiltered() else { return
        }
        if contactListIsFiltered {
            let filteredContacts = contactsThumbnailsDictStruct.dictionary.filter({ $0.value.fullname.lowercased().contains(searchText.lowercased())
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
    
    func openContact(index: Int) {
        let contactDomainModel = contactDomainModels[index]
        router?.openContact(contact: contactDomainModel)
    }
}
