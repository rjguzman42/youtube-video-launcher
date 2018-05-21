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
        let width = UIScreen.main.bounds.size.width - 40
        let height = ((UIScreen.main.bounds.size.width - 40) * 9 / 16)
        layout.itemSize = CGSize(width: width, height: height)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.contentInset = UIEdgeInsetsMake(0,10,0,10)
        cv.backgroundColor = .white
        cv.isPagingEnabled = false
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    let headerView: TableSectionHeaderView = {
        let view = TableSectionHeaderView()
        view.headerTitle.text = "TODAY'S SPOTLIGHT"
        return view
    }()
    var videoPosts = [BBPost]()
    var videoPressed : ((_ selectedVideos: [BBPost]?, _ touchPoint: CGPoint, _ videoImageView: UIImageView, _ cell: UICollectionViewCell) -> Void)?
    
    override func setupSubViews() {
        frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: (UIScreen.main.bounds.size.width * 9 / 16) + 60)
    }
    
    func setupCollectionView() {
        //headerview
        addSubview(headerView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: headerView)
        addConstraintsWithFormat(format: "V:|[v0(60)]", views: headerView)
        
        //collectionView
        addSubview(collectionView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: collectionView)
        addConstraintsWithFormat(format: "V:[v1]-0-[v0]|", views: collectionView, headerView)
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
    
    private var indexOfCellBeforeDragging = 0
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        indexOfCellBeforeDragging = indexOfMajorCell()
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // Stop scrollView sliding:
        targetContentOffset.pointee = scrollView.contentOffset

        // calculate where scrollView should snap to:
        let indexOfMajorCell = self.indexOfMajorCell()
        print(velocity.x)
        // calculate conditions:
        let dataSourceCount = collectionView(collectionView, numberOfItemsInSection: 0)
        let swipeVelocityThreshold: CGFloat = 0.5
        let hasEnoughVelocityToSlideToTheNextCell = indexOfCellBeforeDragging + 1 < dataSourceCount && velocity.x > swipeVelocityThreshold
        let hasEnoughVelocityToSlideToThePreviousCell = indexOfCellBeforeDragging - 1 >= 0 && velocity.x < -swipeVelocityThreshold
        let majorCellIsTheCellBeforeDragging = indexOfMajorCell == indexOfCellBeforeDragging
        let didUseSwipeToSkipCell = majorCellIsTheCellBeforeDragging && (hasEnoughVelocityToSlideToTheNextCell || hasEnoughVelocityToSlideToThePreviousCell)

        if didUseSwipeToSkipCell {

            let snapToIndex = indexOfCellBeforeDragging + (hasEnoughVelocityToSlideToTheNextCell ? 1 : -1)
            let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
            let toValue = flowLayout.itemSize.width * CGFloat(snapToIndex)

            // Damping equal 1 => no oscillations => decay animation:
            UIView.animate(withDuration: 0, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 100, options: .allowUserInteraction, animations: {
//                scrollView.contentOffset = CGPoint(x: toValue, y: 0)
//                scrollView.layoutIfNeeded()
                let indexPath = IndexPath(row: snapToIndex, section: 0)
                self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            }, completion: nil)

        } else {
            // This is a much better to way to scroll to a cell:
            let indexPath = IndexPath(row: indexOfMajorCell, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }

    
    private func indexOfMajorCell() -> Int {
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let itemWidth = flowLayout.itemSize.width
        let proportionalOffset = collectionView.contentOffset.x / itemWidth
        return Int(round(proportionalOffset))
    }
    
    
    func getYouTubeVideoLargeCellForIndexpath(_ indexPath: IndexPath) -> YouTubeVideoLargeCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "YouTubeVideoLargeCell", for: indexPath) as! YouTubeVideoLargeCell
        let selectedVideo = videoPosts[indexPath.row]
        
        if let link = selectedVideo.youtubeLink {
            let thumbnailPath = "http://img.youtube.com/vi/\(link)/sddefault.jpg"
            cell.videoImageView.sd_setImage(with: URL(string: thumbnailPath), placeholderImage: nil, options: [.continueInBackground])
        }
        
        if let postTitle = selectedVideo.comment {
            cell.videoTitle.text = postTitle
        }
        
        if let creatorName = selectedVideo.creatorName {
            cell.videoCreator.text = creatorName
        }
        
        cell.videoPressed = {[weak self] touchPoint, videoImageView in
            if let weakSelf = self {
                weakSelf.handleVideoGesture(selectedVideo, indexPath: indexPath, touchPoint: touchPoint, videoImageView: videoImageView)
            }
        }
        return cell
    }
    
    func handleVideoGesture(_ selectedPost: BBPost, indexPath: IndexPath, touchPoint: CGPoint, videoImageView: UIImageView ) {
        //get thumbnail for animation
        let cell = collectionView.cellForItem(at: indexPath) as! YouTubeVideoLargeCell
        
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
        self.videoPressed!(orderedVideoPosts, touchPoint, videoImageView, cell)
    }
    

    
}
