//
//  WKLyricTableViewCell.swift
//  NeteaseTVDemo
//
//  Created by fengyn on 2023/9/13.
//

import UIKit
import SnapKit
class WKLyricTableViewCell: UITableViewCell {
    var contentLabel: UILabel?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentLabel = UILabel()
        self.contentLabel?.numberOfLines = 0
        self.contentLabel?.textAlignment = .left
        self.contentView.addSubview(self.contentLabel!)
        self.contentLabel?.snp.makeConstraints({ make in
            make.edges.equalToSuperview()
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
//        if context.nextFocusedView == self {
//            setSelected(false, animated: false)
//        }
    }

}
