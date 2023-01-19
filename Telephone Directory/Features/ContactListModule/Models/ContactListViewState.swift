//
//  ContactListViewState.swift
//  Telephone Directory
//
//  Created by Diana Princess on 19.01.2023.
//

enum ContactListViewState {
    case loading
    case error(Error)
    case downloaded(ContactListDataStorage)
}

class ContactListDataStorage {
    var contactListStatus: ContactListStatus
    private var downloadedList: [ContactPresentationModel]
    private var contactItemsDict: [String: ContactItem]
    
    static var shared: ContactListDataStorage = {
        let shared = ContactListDataStorage()
        return shared
    }()
    
    private init(_ list: [ContactPresentationModel] = [], _ dict: [String: ContactItem] = [:]) {
        self.contactListStatus = ContactListStatus.complete
        self.downloadedList = list
        self.contactItemsDict = dict
    }
    
    func setDataStorageIfEmpty(_ list: [ContactPresentationModel], _ dict: [String: ContactItem]){
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


