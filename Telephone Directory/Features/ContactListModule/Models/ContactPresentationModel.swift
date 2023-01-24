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
    let thumbnailData: Data?
    let id: String
}
