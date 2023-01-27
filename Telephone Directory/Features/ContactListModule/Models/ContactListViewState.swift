//
//  ContactListViewState.swift
//  Telephone Directory
//
//  Created by Diana Princess on 19.01.2023.
//

enum ContactListViewState {
    case loading
    case error(Error)
    case downloaded(DownloadedContactsStateProtocol)
}

class DownloadedContactsState {
    private var downloadedList: [ContactPresentationModel]
    private var contactItemsDict: [String: ContactItem]
    var contactListFilteringState: ContactListFilteringState
    var delegate: DownloadedContactsStateDelegate?
    init(_ list: [ContactPresentationModel] = [], _ dict: [String: ContactItem] = [:], filteringState: ContactListFilteringState = ContactListFilteringState.notFiltered([])) {
        self.contactListFilteringState = filteringState
        self.downloadedList = list
        self.contactItemsDict = dict
    }
}

extension DownloadedContactsState: DownloadedContactsStateProtocol {
    
    func setDataStorageIfEmpty(_ list: [ContactPresentationModel], _ dict: [String: ContactItem]) {
        if downloadedList.count == 0 && contactItemsDict.count == 0 {
            self.downloadedList = list
            self.contactItemsDict = dict
        }
    }
    
    func deactivateFiltering() {
        self.contactListFilteringState = .notFiltered(downloadedList)
        delegate?.contactsStateDidChange(.notFiltered(downloadedList))
    }
    
    func insertNewContact(_ contact: ContactPresentationModel, at index: Int) {
        downloadedList.insert(contact, at: index)
    }
    
    func filterContactList(_ searchString: String) {
        let filteredContacts = downloadedList.filter({
            $0.fullname.lowercased().contains(searchString.lowercased())
        })
        self.contactListFilteringState = .filtered(filteredContacts)
        delegate?.contactsStateDidChange(.filtered(filteredContacts))
    }
    
    func getAContactDomainModelByID(id: String) -> ContactItem? {
        return contactItemsDict[id]
    }
    func getAContactPresentationModelByIndex(index: Int) -> ContactPresentationModel? {
        if index > downloadedList.count-1 || index < 0 {
            return nil
        } else {
            return downloadedList.remove(at: index)
        }
    }
}

enum ContactListFilteringState {
    case notFiltered([ContactPresentationModel])
    case filtered([ContactPresentationModel])
}


