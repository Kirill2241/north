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

protocol DownloadedContactsStateProtocol {
    func setDataStorageIfEmpty(_ list: [ContactPresentationModel], _ dict: [String: ContactItem])
    func getFullArray()
    func insertNewContact(_ contact: ContactPresentationModel, at index: Int)
    func filterContactList(_ searchString: String)
    func getAContactDomainModelByID(id: String) -> ContactItem?
    func getAContactPresentationModelByIndex(index: Int) -> ContactPresentationModel?
    var contactListFilteringState: ContactListFilteringState { get }
}

class DownloadedContactsState {
    private var downloadedList: [ContactPresentationModel]
    private var contactItemsDict: [String: ContactItem]
    var contactListFilteringState: ContactListFilteringState
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
    
    func getFullArray() {
        self.contactListFilteringState = .notFiltered(downloadedList)
    }
    
    func insertNewContact(_ contact: ContactPresentationModel, at index: Int) {
        downloadedList.insert(contact, at: index)
    }
    
    func filterContactList(_ searchString: String) {
        let filteredContacts = downloadedList.filter({
            $0.fullname.lowercased().contains(searchString.lowercased())
        })
        self.contactListFilteringState = .filtered(ContactListFilterer(searchText: searchString, filteredContacts: filteredContacts))
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
    case filtered(ContactListFilterer)
}

struct ContactListFilterer {
    let searchText: String
    let filteredContacts: [ContactPresentationModel]
}


