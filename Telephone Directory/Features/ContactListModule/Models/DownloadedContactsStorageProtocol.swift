//
//  DownloadedContactsStateProtocol.swift
//  Telephone Directory
//
//  Created by Diana Princess on 27.01.2023.
//

import Foundation
protocol DownloadedContactsStorageProtocol {
    func setDataStorageIfEmpty(_ source: [ContactItem])
    func deactivateFiltering()
    func updateThumbnailForContact(at index: Int, data: Data?)
    func filterContactList(_ searchString: String)
    func getAContactDomainModelByID(id: String) -> ContactItem?
    func getAContactPresentationModelByIndex(index: Int) -> ContactPresentationModel?
    var contactListFilteringState: ContactListFilteringState { get }
}

protocol DownloadedContactsStorageDelegate {
    func contactsStateDidChange(_ state: ContactListFilteringState)
}
