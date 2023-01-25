//
//  ContactPresentationModel.swift
//  Telephone Directory
//
//  Created by Diana Princess on 12.01.2023.
//

import Foundation

struct ContactPresentationModel: Hashable {
    let fullname: String
    let thumbnailString: String
    let thumbnail: ContactThumbnail
    let id: String
}

struct ContactThumbnail: Hashable {
    let state: ContactThumbnailState
}

enum ContactThumbnailState: Hashable {
    case new
    case downloaded(Data)
    case failed
}
