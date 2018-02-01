//
//  SkipRewindBackgroundView.swift
//  bitbat
//
//  Created by Roberto Guzman on 1/7/18.
//  Copyright © 2018 fortyTwoSports. All rights reserved.
//

import UIKit

class SkipRewindBackgroundView: BaseUIView {

    let imageOne: UIImageView = {
        let view = UIImageView()
        view.image = nil
        view.isUserInteractionEnabled = false
        return view
    }()
    let imageTwo: UIImageView = {
        let view = UIImageView()
        view.image = nil
        view.isUserInteractionEnabled = false
        return view
    }()
    let imageThree: UIImageView = {
        let view = UIImageView()
        view.image = nil
        view.isUserInteractionEnabled = false
        return view
    }()
    let countLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = BBTheme.Fonts.videoPlaybackSmallBoldFont.font
        label.contentMode = .center
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    override func setupSubViews() {
        addSubview(imageOne)
        addConstraintsWithFormat(format: "H:|[v0]", views: imageOne)
        addConstraintsWithFormat(format: "V:|[v0]", views: imageOne)
        
        addSubview(imageTwo)
        addConstraintsWithFormat(format: "H:[v1]-2-[v0]", views: imageTwo, imageOne)
        addConstraintsWithFormat(format: "V:|[v0]", views: imageTwo)
        
        addSubview(imageThree)
        addConstraintsWithFormat(format: "H:[v1]-2-[v0]", views: imageThree, imageTwo)
        addConstraintsWithFormat(format: "V:|[v0]", views: imageThree)
        
        
        addSubview(countLabel)
        addConstraintsWithFormat(format: "H:[v0]", views: countLabel)
        addConstraintsWithFormat(format: "V:[v1]-2-[v0]", views: countLabel, imageTwo)
        addConstraint(NSLayoutConstraint(item: countLabel, attribute: .centerX, relatedBy: .equal, toItem: imageTwo, attribute: .centerX, multiplier: 1, constant: 0))
    }
    
    func setImages(_ image: UIImage) {
        imageOne.image = image
        imageTwo.image = image
        imageThree.image = image
    }
    
}
