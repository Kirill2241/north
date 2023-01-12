//
//  NetworkServiceProtocol.swift
//  Telephone Directory
//
//  Created by Diana Princess on 22.12.2022.
//

import Foundation

protocol NetworkServiceProtocol {
    func requestImage(urlString: String, completion: @escaping(Data?) -> Void)
    func prepareNetworkResponseForPresentation(number: Int, completion: @escaping(([ContactItem]?, ContactListDownloadStatus)) -> Void)
}
