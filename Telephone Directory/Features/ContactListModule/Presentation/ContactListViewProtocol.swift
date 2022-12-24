//
//  ContactListViewProtocol.swift
//  Telephone Directory
//
//  Created by Diana Princess on 07.12.2022.
//
import UIKit

protocol ContactListViewProtocol: class, UISearchResultsUpdating, UITableViewDataSource, UITableViewDelegate {
    func setContentView()
    func setRequestFailureView()
    func setAPIErrorView(errorString: String)
    func applyFilter()
    func checkFiltering() -> Bool
    func nothingFound()
    func removeNothingFoundLabel()
}
