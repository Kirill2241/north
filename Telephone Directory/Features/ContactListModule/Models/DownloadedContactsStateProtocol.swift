//
//  DownloadedContactsStateProtocol.swift
//  Telephone Directory
//
//  Created by Diana Princess on 27.01.2023.
//

import Foundation
protocol DownloadedContactsStateProtocol {
    func setDataStorageIfEmpty(_ list: [ContactPresentationModel], _ dict: [String: ContactItem])
    func deactivateFiltering()
    func insertNewContact(_ contact: ContactPresentationModel, at index: Int)
    func filterContactList(_ searchString: String)
    func getAContactDomainModelByID(id: String) -> ContactItem?
    func getAContactPresentationModelByIndex(index: Int) -> ContactPresentationModel?
    var contactListFilteringState: ContactListFilteringState { get }
}

protocol DownloadedContactsStateDelegate {
    func contactsStateDidChange(_ state: ContactListFilteringState)
}
