//
//  VideoLauncher.swift
//  bitbat
//
//  Created by Roberto Guzman on 12/13/17.
//  Copyright © 2017 fortyTwoSports. All rights reserved.
//

import UIKit

class VideoLauncher: NSObject {
    
    var posts = [BBPost]()
    var originPoint = CGRect()
    var thumbnailImage = UIImage()
    
    func showVideoPlayer() {
        if let keyWindow = UIApplication.shared.keyWindow {
            //first remove any current youtubePlayViews before we add a new one
            for subview in keyWindow.subviews {
                if subview is YoutubePlayView {
                    subview.removeFromSuperview()
                }
            }
            let youtubePlayView = YoutubePlayView()
            youtubePlayView.backgroundColor = .white
            youtubePlayView.posts = posts
            youtubePlayView.frame = CGRect(x: originPoint.origin.x, y: originPoint.origin.y, width: 20, height: 20)
            youtubePlayView.dismissTapped = {[weak self] in
                youtubePlayView.removeFromSuperview()
            }
            keyWindow.addSubview(youtubePlayView)
            
            //add thumbnail for UI/animation purposes
            let thumbnailView = UIImageView(frame: CGRect(x: originPoint.origin.x, y: originPoint.origin.y, width: 0, height: 0))
            thumbnailView.backgroundColor = .black
            thumbnailView.contentMode = .scaleAspectFill
            thumbnailView.image = thumbnailImage
            keyWindow.addSubview(thumbnailView)
            
            //open view and animate view from touchPoint
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveLinear, animations: {
                thumbnailView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: (UIScreen.main.bounds.size.width * 9 / 16))
                youtubePlayView.frame = keyWindow.frame
            }, completion: { (true) in
                thumbnailView.removeFromSuperview()
                youtubePlayView.initialSetup()
            })
        }
    }

}
