//
//  HTTPError.swift
//  Telephone Directory
//
//  Created by Diana Princess on 01.12.2022.
//

public enum HTTPError: Error{
    case transportError(Error)
    case httpError(Int)
}
