//
//  NetworkServiceProtocol.swift
//  Telephone Directory
//
//  Created by Diana Princess on 22.12.2022.
//

import Foundation

protocol NetworkServiceProtocol {
    func requestImage(urlString: String, index: Int, completion: @escaping(Result<Data, Error>) -> Void)
    func fetchContactList(number: Int, completion: @escaping(Result<[ContactItem], Error>) -> Void)
    func operationQueueCurrentOperationIndexes(_ isSuspended: Bool, indexes: [Int]) -> [Int]
}
