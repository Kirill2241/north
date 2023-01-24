//
//  ContactListViewState.swift
//  Telephone Directory
//
//  Created by Diana Princess on 19.01.2023.
//

enum ContactListViewState {
    case loading
    case error(Error)
    case downloaded(ContactListDataProviderProtocol)
}

protocol ContactListDataProviderProtocol {
    func setDataStorageIfEmpty(_ list: [ContactPresentationModel], _ dict: [String: ContactItem])
    func getFullArray() -> [ContactPresentationModel]
    func filterContactList(_ searchString: String) -> [ContactPresentationModel]
    func getAContactDomainModelByID(id: String) -> ContactItem?
    static var shared: ContactListDataProvider { get }
    var contactListStatus: ContactListStatus { get set }
}

class ContactListDataProvider {
    private var downloadedList: [ContactPresentationModel]
    private var contactItemsDict: [String: ContactItem]
    var contactListStatus: ContactListStatus
    private init(_ list: [ContactPresentationModel] = [], _ dict: [String: ContactItem] = [:]) {
        self.contactListStatus = ContactListStatus.complete
        self.downloadedList = list
        self.contactItemsDict = dict
    }
    
}

extension ContactListDataProvider: ContactListDataProviderProtocol {
    static var shared: ContactListDataProvider = {
        let shared = ContactListDataProvider()
        return shared
    }()
    
    func setDataStorageIfEmpty(_ list: [ContactPresentationModel], _ dict: [String: ContactItem]) {
        if downloadedList.count == 0 && contactItemsDict.count == 0 {
            self.downloadedList = list
            self.contactItemsDict = dict
        }
    }
    func getFullArray() -> [ContactPresentationModel] {
        return downloadedList
    }
    func filterContactList(_ searchString: String) -> [ContactPresentationModel] {
        return downloadedList.filter({
            $0.fullname.lowercased().contains(searchString.lowercased())
        })
    }
    func getAContactDomainModelByID(id: String) -> ContactItem? {
        return contactItemsDict[id]
    }
}

enum ContactListStatus {
    case complete
    case filtered(ContactListFilterer)
}

struct ContactListFilterer {
    let searchText: String
    let filteredContacts: [ContactPresentationModel]
}


