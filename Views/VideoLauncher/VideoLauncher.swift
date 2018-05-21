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
    var originFrame = CGRect()
    var touchPoint = CGPoint()
    var thumbnailImageView = UIImageView()
    var minusConstraint: Int = 0
    
    func setupData(_ selectedVideos: [BBPost]?, _ touchPoint: CGPoint, _ videoImageView: UIImageView, _ tableCell: UITableViewCell?, _ collectionCell: UICollectionViewCell?, _ controller: UIViewController, _ user: BBUser?, _ appLocation: String) {
        AnalyticsManager(engine: FirebaseAnalyticsEngine()).log(YouTubeVideoAnalyticsEvent.playVideo(userID: user?.userID ?? "", post: (selectedVideos?[0])!, appLocation: appLocation))
        //let cell = youtubeVideoLargeView.collectionView.cellForItem(at: indexPath) as! YouTubeVideoLargeCell
        var rect = CGRect()
        if tableCell != nil {
            rect = controller.view.convert(videoImageView.frame, from: tableCell)
        } else if collectionCell != nil {
            rect = controller.view.convert(videoImageView.frame, from: collectionCell)
        }
        let constraint: CGFloat = CGFloat(10 - minusConstraint)
        let adjustedRect = CGRect(x: rect.origin.x + constraint, y: rect.origin.y, width: rect.width, height: rect.height)
        self.originFrame = adjustedRect
        self.touchPoint = touchPoint
        self.thumbnailImageView = videoImageView
        self.posts = selectedVideos!
        self.launch()
    }
    
    func setupDataWithoutImage(_ selectedVideos: [BBPost]?, _ touchPoint: CGPoint, _ tableCell: UITableViewCell?, _ collectionCell: UICollectionViewCell?, _ controller: UIViewController?, _ user: BBUser?, _ appLocation: String) {
        AnalyticsManager(engine: FirebaseAnalyticsEngine()).log(YouTubeVideoAnalyticsEvent.playVideo(userID: user?.userID ?? "", post: (selectedVideos?[0])!, appLocation: appLocation))

        self.originFrame = CGRect(x: touchPoint.x, y: touchPoint.y, width: 20, height: 20)
        self.touchPoint = touchPoint
        self.posts = selectedVideos!
        self.launch()
    }
    
    
    func launch() {
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
            youtubePlayView.frame = CGRect(x: originFrame.origin.x, y: originFrame.origin.y, width: 20, height: 20)
            youtubePlayView.dismissTapped = {[weak self] in
                youtubePlayView.removeFromSuperview()
            }
            keyWindow.addSubview(youtubePlayView)
            
//            //add thumbnail for UI/animation purposes
            let thumbnailView = UIImageView(frame: originFrame)
            thumbnailView.backgroundColor = thumbnailImageView.backgroundColor
            thumbnailView.contentMode = thumbnailImageView.contentMode
            thumbnailView.image = thumbnailImageView.image
            thumbnailView.clipsToBounds = thumbnailImageView.clipsToBounds
            thumbnailView.layer.cornerRadius = thumbnailImageView.layer.cornerRadius
            keyWindow.addSubview(thumbnailView)

            //open view and animate view from touchPoint
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [.curveEaseIn], animations: {
                thumbnailView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: (UIScreen.main.bounds.size.width * 9 / 16))
                thumbnailView.layer.cornerRadius = 0
                thumbnailView.layoutIfNeeded()
                youtubePlayView.frame = keyWindow.frame
                youtubePlayView.initialSetup()
                youtubePlayView.layoutIfNeeded()
            }, completion: { (true) in
                thumbnailView.removeFromSuperview()
            })
        }
    }

}
