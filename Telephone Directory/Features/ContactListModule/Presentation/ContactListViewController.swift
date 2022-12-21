//
//  ContactListViewController.swift
//  Telephone Directory
//
//  Created by Diana Princess on 30.11.2022.
//

import UIKit
import SnapKit
import Network

class ContactListViewController: UIViewController, ContactListViewProtocol{
    
    var presenter: ContactListPresenterProtocol?
    let tableView = UITableView(frame: .zero)
    let activityIndicator = UIActivityIndicatorView(style: .large)
    let searchController = UISearchController(searchResultsController: nil)
    let nothingFoundLabel : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 20)
        lbl.textColor = UIColor.darkGray
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        lbl.textAlignment = .center
        lbl.text = "По Вашему запросу ничего не найдено"
        return lbl
    }()
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        initialConfig()
        // Do any additional setup after loading the view.
    }
    
    func initialConfig() {
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
    
    func configureViews(){
        tableView.register(ContactTableViewCell.self, forCellReuseIdentifier: ContactTableViewCell.reuseId)
        tableView.dataSource = presenter
        tableView.delegate = presenter
        view.addSubview(tableView)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Поиск контактов"
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.backgroundColor = UIColor.white
        //navigationController?.navigationBar.isTranslucent = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    func setUpConstraints(){
        tableView.snp.makeConstraints{ (maker) in
            maker.top.leading.trailing.bottom.equalToSuperview()
        }
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
            let noInternetImageView : UIImageView = {
                let imgV = UIImageView()
                imgV.contentMode = .scaleAspectFit
                imgV.image = UIImage(systemName: "exclamationmark.triangle.fill")
                return imgV
            }()
            let noInternetLabel: UILabel = {
                let lbl = UILabel()
                lbl.numberOfLines = 0
                lbl.textAlignment = .center
                lbl.lineBreakMode = .byWordWrapping
                lbl.font = UIFont.systemFont(ofSize: 20)
                lbl.textColor = UIColor.darkGray
                lbl.text = "Произошла ошибка запроса. Пожалуйста, проверьте подключение и повторите попытку"
                return lbl
            }()
            self.view.tintColor = .systemRed
            self.view.addSubview(noInternetImageView)
            self.view.addSubview(noInternetLabel)
            noInternetImageView.snp.makeConstraints{(maker) in
                maker.centerX.centerY.equalToSuperview()
                maker.height.width.equalTo(60)
            }
            noInternetLabel.snp.makeConstraints{ (maker) in
                maker.top.equalTo(noInternetImageView.snp.bottom).offset(15)
                maker.leading.equalToSuperview().offset(30)
                maker.trailing.equalToSuperview().inset(30)
                maker.height.equalTo(100)
            }
            let retryGR = UISwipeGestureRecognizer()
            retryGR.direction = .down
            retryGR.numberOfTouchesRequired = 1
            retryGR.addTarget(self, action: #selector(self.retryRequest(_:)))
            self.view.addGestureRecognizer(retryGR)
        }
    }
    
    func setAPIErrorView(errorString: String) {
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
    
    func nothingFound() {
        DispatchQueue.main.async {
            self.view.addSubview(self.nothingFoundLabel)
            self.nothingFoundLabel.snp.makeConstraints{ (maker) in
                maker.centerX.centerY.equalToSuperview()
                maker.leading.equalToSuperview().offset(30)
                maker.trailing.equalToSuperview().inset(30)
                maker.height.equalTo(50)
            }
        }
    }
    
    func removeNothingFoundLabel(){
        DispatchQueue.main.async {
            if !self.checkFiltering() && self.view.subviews.contains(self.nothingFoundLabel){
                self.nothingFoundLabel.removeFromSuperview()
            }
        }
    }
    
    @objc func retryRequest(_ sender: UISwipeGestureRecognizer){
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

extension ContactListViewController: UISearchResultsUpdating{
    
    func updateSearchResults(for searchController: UISearchController) {
        presenter?.filterContacts(searchController.searchBar.text!)
    }
}
