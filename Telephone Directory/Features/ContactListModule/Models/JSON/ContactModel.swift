//
//  ContactModel.swift
//  Telephone Directory
//
//  Created by Diana Princess on 01.12.2022.
//

struct ContactModel: Codable {
    var results: [ContactInstance]?
    var error: String?
}

struct ContactInstance: Codable{
    var name: NameModel
    var email: String
    var phone: String
    var cell: String
    var picture: PictureOptions
    var nat: String
}

struct NameModel: Codable {
    var title: String
    var first: String
    var last: String
}

struct PictureOptions: Codable {
    var large: String
    var medium: String
    var thumbnail: String
}
