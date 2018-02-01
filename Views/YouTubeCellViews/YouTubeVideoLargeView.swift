//
//  YouTubeVideoLargeView.swift
//  bitbat
//
//  Created by Roberto Guzman on 11/6/17.
//  Copyright © 2017 fortyTwoSports. All rights reserved.
//

import UIKit

class YouTubeVideoLargeView: BaseUIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.size.width
        let height = (UIScreen.main.bounds.size.width * 9 / 16)
        layout.itemSize = CGSize(width: width, height: height)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    var videoPosts = [BBPost]()
    var videoPressed : ((_ selectedVideos: [BBPost]?, _ touchPoint: CGPoint, _ thumbnailImage: UIImage) -> Void)?
    
    override func setupSubViews() {
        frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: (UIScreen.main.bounds.size.width * 9 / 16))
    }
    
    func setupCollectionView() {
        //collectionView
        addSubview(collectionView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: collectionView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: collectionView)
        collectionView.register(YouTubeVideoLargeCell.self, forCellWithReuseIdentifier: "YouTubeVideoLargeCell")
    }
    
    // MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoPosts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return getYouTubeVideoLargeCellForIndexpath(indexPath)
    }
    
    func getYouTubeVideoLargeCellForIndexpath(_ indexPath: IndexPath) -> YouTubeVideoLargeCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "YouTubeVideoLargeCell", for: indexPath) as! YouTubeVideoLargeCell
        let selectedVideo = videoPosts[indexPath.row]
        
        if let link = selectedVideo.youtubeLink {
            let thumbnailPath = "http://img.youtube.com/vi/\(link)/sddefault.jpg"
            cell.videoImageView.sd_setImage(with: URL(string: thumbnailPath))
        }
        
        if let postTitle = selectedVideo.comment {
            cell.videoTitle.text = postTitle
        }
        
        if let creatorName = selectedVideo.creatorName {
            cell.videoCreator.text = creatorName
        }
        cell.videoPressed = {[weak self] touchPoint in
            if let weakSelf = self {
                weakSelf.handleVideoGesture(selectedVideo, indexPath: indexPath, touchPoint: touchPoint)
            }
        }
        return cell
    }
    
    func handleVideoGesture(_ selectedPost: BBPost, indexPath: IndexPath, touchPoint: CGPoint ) {
        //get thumbnail for animation
        let cell = collectionView.cellForItem(at: indexPath) as! YouTubeVideoLargeCell
        var thumbnail = UIImage()
        if let image = cell.videoImageView.image {
            thumbnail = image
        }
        
        var orderedVideoPosts = [BBPost]()
        var count = 0
        let selectedIndexPath = indexPath.row
        var beforeVideos = [BBPost]()
        var afterVideos = [BBPost]()
        for video in videoPosts {
            if count < selectedIndexPath {
                beforeVideos.append(video)
            } else if count > selectedIndexPath {
                afterVideos.append(video)
            }
            count += 1
        }
        orderedVideoPosts.append(videoPosts[selectedIndexPath])
        orderedVideoPosts.append(contentsOf: afterVideos)
        orderedVideoPosts.append(contentsOf: beforeVideos)
        print("----->orderedVideoPosts \(orderedVideoPosts)")
        self.videoPressed!(orderedVideoPosts, touchPoint, thumbnail)
    }
    

    
}
