//
//  WKSearchViewController.swift
//  NeteaseTVDemo
//
//  Created by fengyn on 2023/10/13.
//

import UIKit

class WKSearchViewController: UIViewController {
//    private let appData: WKFindModel
    private let searchController: UISearchController
    private let searchContainerViewController: UISearchContainerViewController
    private let searchResultsController: UITableViewController
    init() {
//        self.appData = appData
        self.searchResultsController = UITableViewController(style: .plain)
        self.searchController = UISearchController(searchResultsController: self.searchResultsController)
        self.searchContainerViewController = UISearchContainerViewController(searchController: searchController)
        super.init(nibName: nil, bundle: nil)
        tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        addChild(searchContainerViewController)
        searchContainerViewController.view.frame = view.bounds
        view.addSubview(searchContainerViewController.view)
        searchContainerViewController.didMove(toParent: self)
        searchController.searchResultsUpdater = self
    }

}

extension WKSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
//            let (results, _) = appData
        }
    }
}

