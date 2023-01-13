//
//  ContactListViewController.swift
//  Telephone Directory
//
//  Created by Diana Princess on 30.11.2022.
//

import UIKit
import SnapKit

class ContactListViewController: UIViewController, ContactListViewProtocol {
    
    var presenter: ContactListPresenterProtocol?
    private let tableView = UITableView(frame: .zero)
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let searchController = UISearchController(searchResultsController: nil)
    private let nothingFoundLabel : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 20)
        lbl.textColor = UIColor.darkGray
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        lbl.textAlignment = .center
        lbl.text = "По Вашему запросу ничего не найдено"
        return lbl
    }()
    private var contactsDict: [Int: ContactPresentationModel] = [:]
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        initialConfig()
        presenter?.tryRequest()
        // Do any additional setup after loading the view.
    }
    
    private func initialConfig() {
        DispatchQueue.main.async {
            if !self.view.subviews.isEmpty{
                self.view.subviews.forEach({$0.removeFromSuperview()})
            }
            self.activityIndicator.hidesWhenStopped = true
            self.view.addSubview(self.activityIndicator)
            self.activityIndicator.snp.makeConstraints{ (maker) in
                maker.centerX.equalToSuperview()
                maker.centerY.equalToSuperview()
            }
            self.activityIndicator.startAnimating()
        }
        
    }
    
    private func configureViews() {
        tableView.register(ContactTableViewCell.self, forCellReuseIdentifier: ContactTableViewCell.reuseId)
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Поиск контактов"
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.backgroundColor = UIColor.white
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    private func setUpConstraints() {
        tableView.snp.makeConstraints{ (maker) in
            maker.top.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func setViewControllerDataSource(_ source: [Int: ContactPresentationModel]) {
        contactsDict = source
    }
    
    func setContentView() {
        DispatchQueue.main.async {
            if self.activityIndicator.isAnimating{
                self.activityIndicator.stopAnimating()
            }
            self.configureViews()
            self.setUpConstraints()
            self.tableView.reloadData()
        }
    }
    
    
    func setRequestFailureView(){
        DispatchQueue.main.async {
            if self.activityIndicator.isAnimating{
                self.activityIndicator.stopAnimating()
            }
            let alert = UIAlertController(title: "При выполнении запроса произошла ошибка", message: "Пожалуйста, проверьте подключение и повторите попытку", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Повторить попытку", style: UIAlertAction.Style.default){ _ in
                self.retryRequest()
            })
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func checkIfContactListIsFiltered() -> Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    func applyFilter() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func createNothingFoundLabel() {
        DispatchQueue.main.async {
            self.tableView.isHidden = true
            self.view.addSubview(self.nothingFoundLabel)
            self.nothingFoundLabel.snp.makeConstraints{ (maker) in
                maker.centerX.centerY.equalToSuperview()
                maker.leading.equalToSuperview().offset(30)
                maker.trailing.equalToSuperview().inset(30)
                maker.height.equalTo(50)
            }
        }
    }
    
    func removeNothingFoundLabel() {
        DispatchQueue.main.async {
            if self.view.subviews.contains(self.nothingFoundLabel){
                self.nothingFoundLabel.removeFromSuperview()
                self.tableView.isHidden = false
            }
        }
    }
    
    private func retryRequest() {
        initialConfig()
        presenter?.tryRequest()
    }
    
    // MARK: - Navigation
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ContactListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text != nil {
            presenter?.filterContacts(searchController.searchBar.text!)
        }
    }
}

extension ContactListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactsDict.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactTableViewCell.reuseId, for: indexPath) as! ContactTableViewCell
        let contact = contactsDict[indexPath.row]
        let fullname = contact?.fullname ?? "UNKNOWN USER"
        let errorImage = UIImage(named: "Error")!
        let errorImageData = errorImage.jpegData(compressionQuality: 1.0)!
        let thumbnailData = contact?.thumbnailData
        let thumbnail = UIImage(data: thumbnailData ?? errorImageData) ?? errorImage
        cell.configure(fullName: fullname, photo: thumbnail)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

extension ContactListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let indexPath = tableView.indexPathForSelectedRow {
            presenter?.openContact(index: indexPath.row)
        }
    }
}
