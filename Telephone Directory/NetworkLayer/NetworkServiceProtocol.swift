//
//  NetworkServiceProtocol.swift
//  Telephone Directory
//
//  Created by Diana Princess on 22.12.2022.
//

import Foundation

protocol NetworkServiceProtocol {
    func processContactListRequest(_ numberOfResults: Int) -> NetworkServiceCustomData
    func requestImage(urlString: String) -> NetworkServiceImageData
    
    func loadContactList(number: Int, completion: @escaping(Result<[ContactInstance]?, HTTPError>) -> Void)
    func loadImage(from text: String, completion: @escaping(Result<Data?, HTTPError>) -> Void)
}
