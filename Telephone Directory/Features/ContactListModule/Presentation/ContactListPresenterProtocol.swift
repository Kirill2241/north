//
//  ContactListPresenterProtocol.swift
//  Telephone Directory
//
//  Created by Diana Princess on 07.12.2022.
//

import Foundation
import UIKit

protocol ContactListPresenterProtocol {
    func tryRequest()
    func downloadThumbnailForContact(at index: Int)
    func filterContacts(_ searchText: String?)
    func openContact(id: String)
    func imageDownloadingControl(_ downloadIsStopped: Bool, _ indexes: [Int])
}
