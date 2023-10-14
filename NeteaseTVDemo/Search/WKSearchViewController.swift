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
//    private let searchResultsController: UITableViewController
    init() {
//        self.appData = appData
//        self.searchResultsController = UITableViewController(style: .plain)
        self.searchController = UISearchController(searchResultsController: WKSearchResultViewController.creat())
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
        
//        let suggestion1 = UISearchSuggestionItem(localizedSuggestion: "歌手", localizedDescription: "歌手", iconImage: nil)
//        let suggestion2 = UISearchSuggestionItem(localizedSuggestion: "曲风", localizedDescription: "曲风", iconImage: nil)
//        let suggestion3 = UISearchSuggestionItem(localizedSuggestion: "专区", localizedDescription: "专区", iconImage: nil)
//        searchController.searchSuggestions = [suggestion1, suggestion2, suggestion3]
    }

}

extension WKSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            print(searchText)
        }
    }
    
    func updateSearchResults(for searchController: UISearchController, selecting searchSuggestion: UISearchSuggestion) {
        print(searchSuggestion.localizedSuggestion ?? "")
    }
}

