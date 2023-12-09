
import UIKit
import NeteaseRequest
class WKSearchViewController: UIViewController {
    private let searchController: UISearchController
    private let searchContainerViewController: UISearchContainerViewController
    private let searchResultsController = WKSearchResultViewController.creat()
    init() {
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
        
    }

}

extension WKSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            print(searchText)
            UserDefaults.standard.set(searchText, forKey: "searchText")
            self.searchResultsController.query = searchText
            self.searchResultsController.searchData()
        }
    }
    
    func updateSearchResults(for searchController: UISearchController, selecting searchSuggestion: UISearchSuggestion) {
        print(searchSuggestion.localizedSuggestion ?? "")
    }
}

