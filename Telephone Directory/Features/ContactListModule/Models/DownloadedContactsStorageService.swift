//
//  DownloadedContactsStorageService.swift
//  Telephone Directory
//
//  Created by Diana Princess on 19.01.2023.
//

import Foundation

class DownloadedContactsStorageService {
    private var downloadedList: [ContactPresentationModel]
    private var contactItemsDict: [String: ContactItem]
    private var filterString: String? = nil
    var contactListFilteringState: ContactListFilteringState
    var delegate: DownloadedContactsStorageDelegate?
    init(_ list: [ContactPresentationModel] = [], _ dict: [String: ContactItem] = [:], filteringState: ContactListFilteringState = ContactListFilteringState.notFiltered([])) {
        self.contactListFilteringState = filteringState
        self.downloadedList = list
        self.contactItemsDict = dict
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
    
    private func insertNewContact(_ contact: ContactPresentationModel, at index: Int) {
        downloadedList.insert(contact, at: index)
    }
    
    private func getAContactPresentationModelByIndex(index: Int) -> ContactPresentationModel? {
        if index > downloadedList.count-1 || index < 0 {
            return nil
        } else {
            return downloadedList.remove(at: index)
        }
    }
}

// MARK: Protocol implemenation
extension DownloadedContactsStorageService: DownloadedContactsStorageProtocol {
    func setDataStorageIfEmpty(_ source: [ContactItem]) {
        if downloadedList.count == 0 && contactItemsDict.count == 0 {
            let newContactsTuple = createDataForStorage(source)
            self.downloadedList = newContactsTuple.0
            self.contactItemsDict = newContactsTuple.1
        }
    }
    
    func deactivateFiltering() {
        filterString = nil
        self.contactListFilteringState = .notFiltered(downloadedList)
        delegate?.contactsStateDidChange(.notFiltered(downloadedList))
    }
    
    func downloadThumbnailForContact(at index: Int) {
        guard let contact = getAContactPresentationModelByIndex(index: index) else { return }
            if contact.thumbnailState == .notDownloaded {
                delegate?.requestThumbnailForContact(thumbnailURL: contact.thumbnailString, at: index) { result in
                    switch result {
                    case .success(let imageData):
                        let newContact = ContactPresentationModel(fullname: contact.fullname, thumbnailString: contact.thumbnailString, thumbnailState: ContactThumbnailState.downloaded(imageData), id: contact.id)
                        self.insertNewContact(newContact, at: index)
                    case .failure(_):
                        let newContact = ContactPresentationModel(fullname: contact.fullname, thumbnailString: contact.thumbnailString, thumbnailState: ContactThumbnailState.failed, id: contact.id)
                        self.insertNewContact(newContact, at: index)
                    }
                }
            }
        switch contactListFilteringState {
        case .notFiltered(_):
            deactivateFiltering()
        case .filtered(_):
            guard let searchString = filterString else { return }
            filterContactList(searchString)
        }
    }
    
    func filterContactList(_ searchString: String) {
        filterString = searchString
        let filteredContacts = downloadedList.filter({
            $0.fullname.lowercased().contains(searchString.lowercased())
        })
        self.contactListFilteringState = .filtered(filteredContacts)
        delegate?.contactsStateDidChange(.filtered(filteredContacts))
    }
    
    func getAContactDomainModelByID(id: String) -> ContactItem? {
        return contactItemsDict[id]
    }
}

enum ContactListFilteringState {
    case notFiltered([ContactPresentationModel])
    case filtered([ContactPresentationModel])
}
