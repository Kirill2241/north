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
    
    func requestContacts(str: String) async {
        let result = await try! self.networkService.requestContactList(urlString: str)
        if case .failure(let error) = result {
            if error.localizedDescription == "The operation couldn’t be completed. (MoscowEvents.HTTPError error 0.)" {
                self.view?.noInternet()
            } else{
                self.view?.requestFailure(error: error)
            }
        }
        if case .success(let requestResp) = result{
            guard let contacts = requestResp else { return }
                guard let results = contacts.results else { return }
                for item in results{
                    let image = await downloadImage(string: item.picture.thumbnail)
                    let contactTuple = (item, image)
                    allContacts.append(contactTuple)
                }
                self.view?.reload()
        }
    }
    
    func downloadImage(string: String) async -> UIImage {
        var finalImg: UIImage?
        guard let imageUrlString = string as? String else {
            return UIImage(named: "Error")!}
        let result = await self.networkService.requestImage(from: imageUrlString)
        if case .failure(let error) = result {
            guard let errorImg = UIImage(named: "Error") else { return UIImage(named: "Error")!}
            finalImg = errorImg
        }
        if case .success(let data) = result{
            let image = UIImage(data: data!)
            let errorImg = UIImage(named: "Error")!
            finalImg = image ?? errorImg
        }
        return finalImg ?? UIImage(named: "Error")!
    }
    
    func filterContacts(_ searchText: String){
        filteredContacts = allContacts.filter({ (contactTuple: (ContactInstance, UIImage)) -> Bool in
            return contactTuple.0.name.first.lowercased().contains(searchText.lowercased()) || contactTuple.0.name.last.lowercased().contains(searchText.lowercased())
        })
        view?.applyFilter()
    }
    
    func tryRequest() {
        Task{
            await requestContacts(str: "https://randomuser.me/api/?results=1000&inc=name,phone,cell,email,nat,picture")
        }
    }
}

extension ContactListPresenter: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if view!.checkFiltering(){
            return filteredContacts.count
        }
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
