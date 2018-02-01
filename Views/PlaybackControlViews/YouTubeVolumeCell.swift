//
//  YouTubeVolumeCell.swift
//  bitbat
//
//  Created by Roberto Guzman on 12/17/17.
//  Copyright © 2017 fortyTwoSports. All rights reserved.
//

import UIKit

class YouTubeVolumeCell: UICollectionViewCell {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Init(coder:) has not been implemented")
    }
    
    deinit {
        BBDebugLog.DLog("Youtube volume Cell Deinited")
    }
    
    func setupUI() {
        clipsToBounds = true
        layer.cornerRadius = 3
        backgroundColor = UIColor.white.withAlphaComponent(0.8)
    }
    
}
