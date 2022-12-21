//
//  ContactListPresenter.swift
//  Telephone Directory
//
//  Created by Diana Princess on 30.11.2022.
//

import Foundation
import UIKit

class ContactListPresenter: NSObject, ContactListPresenterProtocol {
    weak var view: ContactListViewProtocol?
    var networkService: NetworkServiceProtocol!
    var router: RouterProtocol?
    var allContacts: [(ContactInstance, UIImage)] = []
    var filteredContacts: [(ContactInstance, UIImage)] = []
    var searchBarIsEmpty: Bool = true
    required init(view: ContactListViewProtocol, networkService: NetworkServiceProtocol, router: RouterProtocol) {
        self.view = view
        self.networkService = networkService
        self.router = router
        super.init()
        tryRequest()
    }
    
    func requestContacts(numberOfContacts: Int, fields: [String]) async {
        let networkData = await networkService.processContactListRequest(numberOfContacts, fields: fields)
        switch networkData.status {
        case .error:
            view?.setRequestFailureView()
        case .success:
            if networkData.result?.error != nil {
                view?.setAPIErrorView(errorString: (networkData.result?.error!)!)
            }else{
                for instance in networkData.result?.results ?? []{
                    let image = await requestImage(string: instance.picture.thumbnail)
                    let tuple = (instance, image)
                    allContacts.append(tuple)
                }
                view?.setContentView()
            }
        case .none:
            print("")
        }
    }
    
    func requestImage(string: String) async -> UIImage {
        guard let imageUrlString = string as? String else {
            return UIImage(named: "Error")!}
        let result = await networkService.requestImage(urlString: imageUrlString)
        switch result.status {
        case .success:
            return UIImage(data: result.data!)!
        case .error:
            return UIImage(named: "Error")!
        case .noConnection:
            return UIImage(named: "Error")!
        }
    }
    
    func filterContacts(_ searchText: String){
        filteredContacts = allContacts.filter({ (contactTuple: (ContactInstance, UIImage)) -> Bool in
            return contactTuple.0.name.first.lowercased().contains(searchText.lowercased()) || contactTuple.0.name.last.lowercased().contains(searchText.lowercased())
        })
        view?.applyFilter()
    }
    
    func tryRequest() {
        Task{
            await requestContacts(numberOfContacts: 1000, fields: ["name" ,"phone","cell","email","nat","picture"])
        }
    }
}

extension ContactListPresenter: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if view!.checkFiltering(){
            if filteredContacts.count == 0{
                view?.nothingFound()
            }
            view?.removeNothingFoundLabel()
            return filteredContacts.count
        }
        view?.removeNothingFoundLabel()
        return allContacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactTableViewCell.reuseId, for: indexPath) as! ContactTableViewCell
        var contactTuple: (ContactInstance, UIImage)
        if view!.checkFiltering(){
            contactTuple = filteredContacts[indexPath.row]
        } else {
            contactTuple = allContacts[indexPath.row]
        }
        let firstName = contactTuple.0.name.first
        let lastName = contactTuple.0.name.last
        let fullName = firstName+" "+lastName
        let thumbnail = contactTuple.1
        cell.configure(fullName: fullName, photo: thumbnail)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

extension ContactListPresenter: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let indexPath = tableView.indexPathForSelectedRow{
            var contactTuple: (ContactInstance, UIImage)
            if view!.checkFiltering(){
                contactTuple = filteredContacts[indexPath.row]
            } else {
                contactTuple = allContacts[indexPath.row]
            }
            let contact = contactTuple.0
            let firstName = contact.name.first
            let lastName = contact.name.last
            let fullName = firstName+" "+lastName
            router?.openContact(fullName: fullName, phone: contact.phone, cell: contact.cell, email: contact.email, largeImgStr: contact.picture.large, nat: contact.nat)
        }
    }
}
