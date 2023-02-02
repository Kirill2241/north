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
    func downloadThumbnailForContact(at index: Int)
    func filterContactList(_ searchString: String)
    func getAContactDomainModelByID(id: String) -> ContactItem?
    var contactListFilteringState: ContactListFilteringState { get }
}

protocol DownloadedContactsStorageDelegate {
    func requestThumbnailForContact(thumbnailURL: String, at index: Int, completion: @escaping(Result<Data, Error>) -> Void)
    func contactsStateDidChange(_ state: ContactListFilteringState)
}
