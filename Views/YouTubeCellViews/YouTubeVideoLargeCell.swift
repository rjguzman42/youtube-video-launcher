//
//  YouTubeVideoLargeCell.swift
//  bitbat
//
//  Created by Roberto Guzman on 11/6/17.
//  Copyright © 2017 fortyTwoSports. All rights reserved.
//

import UIKit

class YouTubeVideoLargeCell: UICollectionViewCell {
    
    
    let videoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .black
        iv.isUserInteractionEnabled = true
        iv.layer.cornerRadius = 5
        iv.clipsToBounds = true
        iv.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: (UIScreen.main.bounds.size.width * 9 / 16))
        return iv
    }()
    let videoTitle: UILabel = {
        let label = UILabel()
        label.font = BBTheme.Fonts.boldTitleFontSmall.font
        label.textColor = .white
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    let videoCreator: UILabel = {
        let label = UILabel()
        label.font = BBTheme.Fonts.pageTitleFont.font
        label.textColor = .white
        label.numberOfLines = 1
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    var videoPressed : ((_ touchPoint: CGPoint, _ videoImageView: UIImageView) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Init(coder:) has not been implemented")
    }
    
    deinit {
        videoTitle.text = ""
        videoImageView.image = nil
        BBDebugLog.DLog("Youtube video Cell Deinited")
    }
    
    func setupUI() {
        addSubview(videoImageView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: videoImageView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: videoImageView)
        
        addSubview(videoTitle)
        addConstraintsWithFormat(format: "H:|-10-[v0]-10-|", views: videoTitle)
        addConstraint(NSLayoutConstraint(item: videoTitle, attribute: .bottom, relatedBy: .equal, toItem: videoImageView, attribute: .bottom, multiplier: 1, constant: -10))
        
        addSubview(videoCreator)
        addConstraintsWithFormat(format: "H:|-10-[v0]|", views: videoCreator)
        addConstraint(NSLayoutConstraint(item: videoCreator, attribute: .bottom, relatedBy: .equal, toItem: videoTitle, attribute: .top, multiplier: 1, constant: -5))
        
        //add bottom gradient layer
        let gradientBottomLayer = CAGradientLayer()
        gradientBottomLayer.frame = videoImageView.bounds
        gradientBottomLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientBottomLayer.locations = [0.4, 1.2]
        videoImageView.layer.addSublayer(gradientBottomLayer)
        
        
        //add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(YouTubeVideoLargeCell.handleTopicTapGesture(_:)))
        videoImageView.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTopicTapGesture(_ sender: UITapGestureRecognizer) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.logActionEventWithName("button_press", value: "youtubeVideo")
        
        //get toucPoint so we can animate view from here
        var touchPoint = sender.location(in: self)
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            //more accurate touchPoint
            touchPoint = sender.location(in: topController.view)
        }
        
        if self.videoPressed != nil {
            self.videoPressed!(touchPoint, videoImageView)
        }
    }
}
