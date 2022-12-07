//
//  ContactListViewProtocol.swift
//  Telephone Directory
//
//  Created by Diana Princess on 07.12.2022.
//
import UIKit

protocol ContactListViewProtocol: class, UISearchResultsUpdating {
    func reload()
    func noInternet()
    func requestFailure(error: Error)
    func apiError(errorString: String)
    func applyFilter()
    func checkFiltering() -> Bool
}
