//
//  skipRewindView.swift
//  bitbat
//
//  Created by Roberto Guzman on 1/7/18.
//  Copyright © 2018 fortyTwoSports. All rights reserved.
//

import UIKit

class SkipRewindView: BaseUIView {

    let mainImage: UIImageView = {
        let view = UIImageView()
        view.image = nil
        view.isUserInteractionEnabled = true
        return view
    }()
    let countLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = BBTheme.Fonts.videoPlaybackSmallFont.font
        label.contentMode = .center
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    override func setupSubViews() {
        addSubview(mainImage)
        addConstraintsWithFormat(format: "H:|[v0]|", views: mainImage)
        addConstraintsWithFormat(format: "V:|[v0]|", views: mainImage)
        
        addSubview(countLabel)
        addConstraintsWithFormat(format: "H:[v0]", views: countLabel)
        addConstraintsWithFormat(format: "V:[v0]", views: countLabel)
        addConstraint(NSLayoutConstraint(item: countLabel, attribute: .centerX, relatedBy: .equal, toItem: mainImage, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: countLabel, attribute: .centerY, relatedBy: .equal, toItem: mainImage, attribute: .centerY, multiplier: 1, constant: 2))
    }

}
