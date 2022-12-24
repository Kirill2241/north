//
//  NetworkServiceCustomData.swift
//  Telephone Directory
//
//  Created by Diana Princess on 19.12.2022.
//

import Foundation

struct NetworkServiceCustomData {
    public var status: CustomDataStatusEnum
    public var result: ContactModel?
    public var error: HTTPError?
}

enum CustomDataStatusEnum {
    case success
    case error
}
