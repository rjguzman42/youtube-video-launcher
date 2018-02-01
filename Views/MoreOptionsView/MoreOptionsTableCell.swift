//
//  MoreOptionsTableCell.swift
//  bitbat
//
//  Created by Roberto Guzman on 1/3/18.
//  Copyright © 2018 fortyTwoSports. All rights reserved.
//

import UIKit

class MoreOptionsTableCell: UITableViewCell {

    let optionImageView: UIImageView = {
       let view = UIImageView()
        return view
    }()
    let optionTitle: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = BBTheme.Fonts.primaryTextFont.font
        label.textColor = BBTheme.Colors.textPrimary.color
        label.contentMode = .left
        label.textAlignment = .left
        return label
    }()
    let lineView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.frame = CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 0.7)
        view.backgroundColor = UIColor.groupTableViewBackground
        return view
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    deinit {
        reset()
        BBDebugLog.DLog("WatchActivity Cell Deinited")
    }
    
    func reset() {
        optionTitle.text = ""
        optionImageView.image = nil
        lineView.isHidden = true
    }
    
    func setupUI() {
        backgroundColor = .white
        
        addSubview(lineView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: lineView)
        addConstraintsWithFormat(format: "V:|[v0(0.7)]", views: lineView)
        
        addSubview(optionImageView)
        addConstraintsWithFormat(format: "H:|-20-[v0(20)]", views: optionImageView)
        addConstraintsWithFormat(format: "V:[v0(20)]", views: optionImageView)
        addConstraint(NSLayoutConstraint(item: optionImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        addSubview(optionTitle)
        addConstraintsWithFormat(format: "H:[v1]-20-[v0(200)]", views: optionTitle, optionImageView)
        addConstraintsWithFormat(format: "V:[v0(20)]", views: optionTitle)
        addConstraint(NSLayoutConstraint(item: optionTitle, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
    }

}
