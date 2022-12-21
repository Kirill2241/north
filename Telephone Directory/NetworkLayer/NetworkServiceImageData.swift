//
//  NetworkServiceImageData.swift
//  Telephone Directory
//
//  Created by Diana Princess on 19.12.2022.
//

import Foundation

struct NetworkServiceImageData {
    public var status: ImageDataStatusEnum
    public var data: Data?
    public var error: HTTPError?
}

enum ImageDataStatusEnum {
    case success
    case error
    case noConnection
}
