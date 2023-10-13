//
//  WKSearchViewController.swift
//  NeteaseTVDemo
//
//  Created by fengyn on 2023/10/13.
//

import UIKit

class WKSearchViewController: UIViewController {
    var searchResultsController: UITableViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        searchResultsController = UITableViewController(style: .plain)
        let searchController = UISearchController(searchResultsController: searchResultsController)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        
        if let searchContainerView = self.view.viewWithTag(100) {
            searchContainerView.addSubview(searchController.searchBar)
        }
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

extension WKSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // 处理搜索结果的更新
    }
}
