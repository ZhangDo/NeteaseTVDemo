//
//  WKRecommendViewController.swift
//  NeteaseTVDemo
//
//  Created by fengyn on 2023/9/15.
//

import UIKit
import NeteaseRequest
import Kingfisher
class WKRecommendViewController: UIViewController,FSPagerViewDataSource,FSPagerViewDelegate {

    fileprivate let sectionTitles = ["Configurations", "Decelaration Distance", "Item Size", "Interitem Spacing", "Number Of Items"]
    fileprivate let configurationTitles = ["Automatic sliding","Infinite"]
    
    fileprivate var banners: [NRBannerModel]?
    
    @IBOutlet weak var bannerView: FSPagerView! {
        didSet {
            self.bannerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
            self.bannerView.itemSize = FSPagerView.automaticSize
//            self.bannerView.automaticSlidingInterval = 3.0 - self.bannerView.automaticSlidingInterval
//            self.bannerView.itemSize = CGSize(width: 500, height: 400)
//            let type = self.transformerTypes[3]
//            self.bannerView.transformer = FSPagerViewTransformer(type:type)
            let transform = CGAffineTransform(scaleX: 0.4, y: 0.75)
            self.bannerView.itemSize = self.bannerView.frame.size.applying(transform)
            self.bannerView.decelerationDistance = FSPagerView.automaticDistance
            self.bannerView.interitemSpacing = 200
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            self.banners = await self.loadBannerData()
            self.bannerView.reloadData()
        }
        
        
    }
    
    func loadBannerData() async -> [NRBannerModel] {
        return try! await fetchBanners()
    }

    // MARK:- FSPagerView DataSource
    
    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        return self.banners?.count ?? 0
    }
    
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        cell.imageView?.kf.setImage(with: URL(string: self.banners![index].pic ))
//        cell.imageView?.image = UIImage(named: self.imageNames[index])
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.clipsToBounds = true
        cell.textLabel?.text = self.banners![index].typeTitle
        return cell
    }
    
    // MARK:- FSPagerView Delegate
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        pagerView.scrollToItem(at: index, animated: true)
    }
    
//    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
//        self.pageControl.currentPage = targetIndex
//    }
//
//    func pagerViewDidEndScrollAnimation(_ pagerView: FSPagerView) {
//        self.pageControl.currentPage = pagerView.currentIndex
//    }

}
