//
//  ShareItemCell.swift
//  bitbat
//
//  Created by Roberto Guzman on 1/3/18.
//  Copyright © 2018 fortyTwoSports. All rights reserved.
//

import UIKit

class ShareItemCell: UICollectionViewCell {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = BBTheme.Colors.textPrimary.color
        label.font = BBTheme.Fonts.countLabelFont.font
        label.textAlignment = .center
        label.contentMode = .center
        label.numberOfLines = 1
        return label
    }()
    let shareImageView: UIImageView = {
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        view.backgroundColor = .lightGray
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        return view
    }()
    var itemPressed : ((_ title: String) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Init(coder:) has not been implemented")
    }
    
    deinit {
        reset()
        BBDebugLog.DLog("Share Item Cell Deinited")
    }
    
    func reset() {
        titleLabel.text = ""
        shareImageView.image = nil
    }
    
    func setUpUI() {
        backgroundColor = .clear
        
        addSubview(titleLabel)
        addConstraintsWithFormat(format: "H:|[v0(100)]|", views: titleLabel)
        addConstraintsWithFormat(format: "V:[v0(20)]|", views: titleLabel)
        
        addSubview(shareImageView)
        addConstraintsWithFormat(format: "H:[v0(80)]", views: shareImageView)
        addConstraintsWithFormat(format: "V:[v0(80)]-2-[v1]", views: shareImageView, titleLabel)
        addConstraint(NSLayoutConstraint(item: shareImageView, attribute: .centerX, relatedBy: .equal, toItem: titleLabel, attribute: .centerX, multiplier: 1, constant: 0))
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ShareItemCell.handleTapGesture(_:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTapGesture(_ sender: UITapGestureRecognizer) {
        if itemPressed != nil {
            if let title = titleLabel.text {
                self.itemPressed!(title)
            }
        }
    }
    
    
}
