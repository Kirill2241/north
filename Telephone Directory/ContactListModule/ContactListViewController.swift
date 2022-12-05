//
//  ContactListViewController.swift
//  Telephone Directory
//
//  Created by Diana Princess on 30.11.2022.
//

import UIKit
import SnapKit
import Network
protocol ContactListViewProtocol: class, UISearchResultsUpdating {
    func reload()
    func noInternet()
    
    func requestFailure(error: Error)
    func apiError(errorString: String)
    func applyFilter()
    func checkFiltering() -> Bool
}

class ContactListViewController: UIViewController, ContactListViewProtocol{
    var presenter: ContactListPresenterProtocol?
    let tableView = UITableView(frame: .zero)
    let activityIndicator = UIActivityIndicatorView(style: .large)
    let searchController = UISearchController(searchResultsController: nil)
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "InternetConnectionMonitor")
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        monitor.pathUpdateHandler = { pathUpdateHandler in
                    if pathUpdateHandler.status == .satisfied {
                        print("Internet connection is on.")
                    } else {
                        DispatchQueue.main.async {
                                self.noInternet()
                        }
                    }
                }
        monitor.start(queue: queue)
        initialConfig()
        // Do any additional setup after loading the view.
    }
    
    func initialConfig() {
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints{ (maker) in
            maker.centerX.equalToSuperview()
            maker.centerY.equalToSuperview()
        }
        activityIndicator.startAnimating()
    }
    
    func configureViews(){
        tableView.register(ContactTableViewCell.self, forCellReuseIdentifier: ContactTableViewCell.reuseId)
        tableView.dataSource = presenter
        tableView.delegate = presenter
        view.addSubview(tableView)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск контактов"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    func setUpConstraints(){
        tableView.snp.makeConstraints{ (maker) in
            maker.top.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func reload() {
        DispatchQueue.main.async {
            if self.activityIndicator.isAnimating{
                self.activityIndicator.stopAnimating()
            }
            self.configureViews()
            self.setUpConstraints()
            self.tableView.reloadData()
        }
    }
    
    func noInternet(){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Отсутствует соединение с интернетом", message: "Пожалуйста, проверьте подключение и повторите попытку.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func requestFailure(error: Error) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "При выполнении запроса произошла ошибка", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    func apiError(errorString: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "При выполнении запроса произошла ошибка", message: errorString, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func applyFilter() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    func checkFiltering() -> Bool{
        return searchController.isActive && !searchBarIsEmpty
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ContactListViewController: UISearchResultsUpdating{
    
    func updateSearchResults(for searchController: UISearchController) {
        presenter?.filterContacts(searchController.searchBar.text!)
    }
}
