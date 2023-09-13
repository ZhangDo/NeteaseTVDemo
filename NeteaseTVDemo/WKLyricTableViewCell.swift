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
        self.contentView.addSubview(self.contentLabel!)
        self.contentLabel?.snp.makeConstraints({ make in
            make.edges.equalToSuperview()
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
