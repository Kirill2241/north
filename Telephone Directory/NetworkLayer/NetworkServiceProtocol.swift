//
//  NetworkServiceProtocol.swift
//  Telephone Directory
//
//  Created by Diana Princess on 22.12.2022.
//

import Foundation

protocol NetworkServiceProtocol {
    func requestImage(urlString: String, type: RequestedImageType, completion: @escaping(Result<Data, Error>) -> Void)
    func fetchContactList(number: Int, completion: @escaping(Result<[ContactItem], Error>) -> Void)
}

enum RequestedImageType {
    case thumbnail
    case large
}
