//
//  YoutubePlayView.swift
//  bitbat
//
//  Created by Roberto Guzman on 12/13/17.
//  Copyright © 2017 fortyTwoSports. All rights reserved.
//

import UIKit
import MediaPlayer
import AVKit
import youtube_ios_player_helper
import Branch
import Social
import MessageUI

class YoutubePlayView: BaseUIView, YTPlayerViewDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MFMessageComposeViewControllerDelegate {

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let width = (UIScreen.main.bounds.size.width / 7)
        let height = CGFloat(6)
        layout.itemSize = CGSize(width: width, height: width / 10)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isHidden = true
        cv.backgroundColor = .clear
        cv.isPagingEnabled = false
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    let audioSession = AVAudioSession.sharedInstance()
    let volumeView: MPVolumeView = {
        let view = MPVolumeView()
        view.clipsToBounds = true
        return view
    }()
    let expandContractButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ic_expand"), for: .normal)
        button.isUserInteractionEnabled = true
        button.imageEdgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        return button
    }()
    let videoDarkFilterView: UIView = {
        let view = UIView()
        return view
    }()
    lazy var tableView: UITableView = {
        let tv = UITableView(frame: frame, style: .grouped)
        tv.backgroundColor = .white
        tv.separatorStyle = .none
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()
    let nextVideoButton: UIButton = {
        let button = UIButton()
        button.setTitle("NEXT", for: .normal)
        button.titleLabel?.font = BBTheme.Fonts.videoTitleFont.font
        button.setTitleColor(BBTheme.Colors.textPrimary.color, for: .normal)
        button.setImage(UIImage(named: "ic_next_arrow"), for: .normal)
        button.isUserInteractionEnabled = true
        return button
    }()
    let previousVideoButton: UIButton = {
        let button = UIButton()
        button.setTitle("PREVIOUS", for: .normal)
        button.titleLabel?.font = BBTheme.Fonts.videoTitleFont.font
        button.setTitleColor(BBTheme.Colors.textPrimary.color, for: .normal)
        button.setImage(UIImage(named: "ic_back"), for: .normal)
        button.isUserInteractionEnabled = true
        return button
    }()
    let currentVideoRatioLabel: UILabel = {
        let label = UILabel()
        label.font = BBTheme.Fonts.secondaryTextFont.font
        label.textColor = BBTheme.Colors.textSecondary.color
        label.numberOfLines = 1
        return label
    }()
    let bottomChangeVideoControls: UIView = {
        let view = UIView()
        view.backgroundColor = BBTheme.Colors.navBarOffWhite.color
        view.isUserInteractionEnabled = true
        return view
    }()
    let bottomBorderView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    let videoTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = BBTheme.Fonts.videoTitleFont.font
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 0
        return label
    }()
    let moreOptionsButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ic_more_horizontal"), for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 13, left: 13, bottom: 13, right: 13)
        button.isUserInteractionEnabled = true
        return button
    }()
    let youtubePlayer: YTPlayerView = {
        let view = YTPlayerView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .black
        view.tintColor = .black
        return view
    }()
    let minimizeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ic_back"), for: .normal)
        button.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi/2))
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        button.isUserInteractionEnabled = true
        return button
    }()
    let nextVideoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = BBTheme.Fonts.buttonTitleFont.font
        label.contentMode = .left
        label.numberOfLines = 1
        label.isHidden = true
        return label
    }()
    let controlsSuperView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        return view
    }()
    let topControlsView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        return view
    }()
    let middleControlsView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        return view
    }()
    let bottomControlsView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        return view
    }()
    let playPauseButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ic_play"), for: .normal)
        button.isUserInteractionEnabled = true
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return button
    }()
    let forwardView: SkipRewindView = {
        let view = SkipRewindView()
        view.mainImage.image = UIImage(named: "ic_forward")
        return view
    }()
    let rewindView: SkipRewindView = {
        let view = SkipRewindView()
        view.mainImage.image = UIImage(named: "ic_rewind")
        return view
    }()
    let videoDurationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = BBTheme.Fonts.buttonTitleFont.font
        label.contentMode = .center
        label.numberOfLines = 1
        return label
    }()
    let videoSlider: UISlider = {
        let circleView = YouTubeSliderThumbView(frame: CGRect(x: 0, y: 0, width: 16, height: 16))
        let circleViewHighlighted = YouTubeSliderThumbView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        
        let circleImage = UIImage(view: circleView)
        let circleImageHighlighted = UIImage(view: circleViewHighlighted)
        let slider = UISlider()
        slider.minimumTrackTintColor = BBTheme.Colors.generalPrimaryOrange.color
        slider.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.5)
        slider.thumbTintColor = BBTheme.Colors.generalPrimaryOrange.color
        slider.addTarget(self, action: #selector(handlesSliderChange), for: .valueChanged)
        slider.setThumbImage(circleImage, for: .normal)
        slider.setThumbImage(circleImageHighlighted, for: .highlighted)
        return slider
    }()
    let forwardBackgroundView: UIView = {
       let view = UIView()
        view.isHidden = true
        view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        return view
    }()
    let rewindBackgroundView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        return view
    }()
    let forwardBackgroundImage: SkipRewindBackgroundView = {
        let view = SkipRewindBackgroundView()
        view.isHidden = true
        view.setImages(UIImage(named: "ic_play_forward")!)
        return view
    }()
    let rewindBackgroundImage: SkipRewindBackgroundView = {
        let view = SkipRewindBackgroundView()
        view.isHidden = true
        view.setImages(UIImage(named: "ic_play_rewind")!)
        return view
    }()
    let darkView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return view
    }()
    let shareView: ShareView = {
        let view = ShareView()
        view.backgroundColor = .white
        return view
    }()
    let moreOptionsView: MoreOptionsView = {
        let view = MoreOptionsView()
        let options: [BBSettingItem] = [BBSettingItem(category: .administrative, title: "Play next", imageName: "ic_play_next", placeholder: nil, userInputText: nil), BBSettingItem(category: .administrative, title: BBConstants.Strings.watchLater, imageName: "ic_watch_later", placeholder: nil, userInputText: nil), BBSettingItem(category: .administrative, title: BBConstants.Strings.sharePost, imageName: "ic_share", placeholder: nil, userInputText: nil), BBSettingItem(category: .administrative, title: BBConstants.Strings.cancel, imageName: "ic_cancel_two", placeholder: nil, userInputText: nil)]
        view.optionItems = groupBy(options) { $0.category}
        view.backgroundColor = .white
        return view
    }()
    var maximizeTap = UITapGestureRecognizer()
    var controlsSuperViewTap = UITapGestureRecognizer()
    var controlsSuperViewDoubleTap = UITapGestureRecognizer()
    var dismissPanGesture = UIPanGestureRecognizer()
    var dismissFromMaxPanGesture = UIPanGestureRecognizer()
    
    var volumeNumberOfItems: Float = 0
    var dismissTapped: (() -> Void)?
    var posts = [BBPost]()
    var currentPostIndex: Int = 0
    var currentYoutubeVideoID = ""
    var isPlaying = true
    var currentDragPoint = CGPoint()
    var currentMaxDragPoint = CGPoint()
    let youtubePlayerMinWidth = ((UIScreen.main.bounds.size.width / 2) - (UIScreen.main.bounds.size.width / 50))
    let youtubePlayerMinHeight = (((UIScreen.main.bounds.size.width / 2) - (UIScreen.main.bounds.size.width / 50)) * 9 / 16)
    var hideViewsTimer = Timer()
    var hideVolumeTimer = Timer()
    var forwardSeek: Int = 10
    var rewindSeek: Int = 10
    var playerVars = [
        "playsinline" : 1,
        "showinfo" : 0,
        "rel" : 0,
        "modestbranding" : 1,
        "controls" : 0,
        "fs" : 0,
        "playlist" : "",
        "cc_load_policy" : 0,
        "iv_load_policy" : 3,
        "autoplay" : 0,
        "origin" : "https://www.youtube.com",
        ] as [String : Any]
    
    override func setupSubViews() {
        //automatic setup
        AppUtility.setOrientation(orientation: "portrait")
        UIApplication.shared.isStatusBarHidden = true
        setupDefaults()
    }
    
    func setupDefaults() {
        if let forward = persistencyManager.getSkipForward() {
            forwardView.countLabel.text = forward
            forwardBackgroundImage.countLabel.text = "\(forward) seconds"
        }
        
        if let back = persistencyManager.getSkipBack() {
            rewindView.countLabel.text = back
            rewindBackgroundImage.countLabel.text = "\(back) seconds"
        }
    }
    
    func initialSetup() {
        //called setup
        setupUI()
        setupPlayBack()
        setupYoutubePlayer()
        startVideo()
        setupTableView()
        listenVolumeButton()
        
        //turn on sound if user has it on silent
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch {
            //error playing sound
        }
    }
    
    func setupUI() {
        self.isUserInteractionEnabled = true
        self.currentMaxDragPoint = CGPoint(x: self.center.x, y: (self.center.y / 2))
        
        addSubview(youtubePlayer)
        addConstraintsWithFormat(format: "H:|[v0]|", views: youtubePlayer)
        addConstraintsWithFormat(format: "V:|[v0]", views: youtubePlayer)
        youtubePlayer.frame = CGRect(x: 0, y: 0, width: Int(self.bounds.size.width), height: Int(self.bounds.size.width * 9 / 16))
        
        addSubview(controlsSuperView)
        controlsSuperView.frame = CGRect(x: 0, y: 0, width: Int(youtubePlayer.frame.width), height: Int(youtubePlayer.frame.height))
        
        controlsSuperView.addSubview(topControlsView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: topControlsView)
        addConstraintsWithFormat(format: "V:|[v0(60)]", views: topControlsView)
        
        controlsSuperView.addSubview(middleControlsView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: middleControlsView)
        addConstraintsWithFormat(format: "V:[v0(120)]", views: middleControlsView)
        addConstraint(NSLayoutConstraint(item: middleControlsView, attribute: .centerY, relatedBy: .equal, toItem: controlsSuperView, attribute: .centerY, multiplier: 1, constant: 0))
        
        controlsSuperView.addSubview(bottomControlsView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: bottomControlsView)
        addConstraintsWithFormat(format: "V:[v0(40)]|", views: bottomControlsView)

        topControlsView.addSubview(minimizeButton)
        addConstraintsWithFormat(format: "H:|-5-[v0]", views: minimizeButton)
        addConstraint(NSLayoutConstraint(item: minimizeButton, attribute: .centerY, relatedBy: .equal, toItem: topControlsView, attribute: .centerY, multiplier: 1, constant: 0))
        
        bottomControlsView.addSubview(expandContractButton)
        addConstraintsWithFormat(format: "H:[v0]-10-|", views: expandContractButton)
        addConstraint(NSLayoutConstraint(item: expandContractButton, attribute: .centerY, relatedBy: .equal, toItem: bottomControlsView, attribute: .centerY, multiplier: 1, constant: 0))
        
        topControlsView.addSubview(nextVideoLabel)
        addConstraintsWithFormat(format: "H:[v0]-15-|", views: nextVideoLabel)
        addConstraint(NSLayoutConstraint(item: nextVideoLabel, attribute: .centerY, relatedBy: .equal, toItem: topControlsView, attribute: .centerY, multiplier: 1, constant: 0))
        
        middleControlsView.addSubview(playPauseButton)
        playPauseButton.imageView?.contentMode = .scaleAspectFit
        addConstraintsWithFormat(format: "H:[v0(45)]", views: playPauseButton)
        addConstraintsWithFormat(format: "V:[v0(45)]", views: playPauseButton)
        addConstraint(NSLayoutConstraint(item: playPauseButton, attribute: .centerX, relatedBy: .equal, toItem: middleControlsView, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: playPauseButton, attribute: .centerY, relatedBy: .equal, toItem: middleControlsView, attribute: .centerY, multiplier: 1, constant: 0))
        
        bottomControlsView.addSubview(videoSlider)
        addConstraintsWithFormat(format: "H:|-10-[v0]", views: videoSlider)
        addConstraintsWithFormat(format: "V:[v0]", views: videoSlider)
        addConstraint(NSLayoutConstraint(item: videoSlider, attribute: .centerY, relatedBy: .equal, toItem: bottomControlsView, attribute: .centerY, multiplier: 1, constant: 0))
        
        middleControlsView.addSubview(forwardView)
        addConstraintsWithFormat(format: "H:[v1]-35-[v0(30)]", views: forwardView, playPauseButton)
        addConstraintsWithFormat(format: "V:[v0(30)]", views: forwardView)
        addConstraint(NSLayoutConstraint(item: forwardView, attribute: .centerY, relatedBy: .equal, toItem: middleControlsView, attribute: .centerY, multiplier: 1, constant: 0))
        
        middleControlsView.addSubview(rewindView)
        addConstraintsWithFormat(format: "H:[v0(30)]-35-[v1]", views: rewindView, playPauseButton)
        addConstraintsWithFormat(format: "V:[v0(30)]", views: rewindView)
        addConstraint(NSLayoutConstraint(item: rewindView, attribute: .centerY, relatedBy: .equal, toItem: middleControlsView, attribute: .centerY, multiplier: 1, constant: 0))
        
        bottomControlsView.addSubview(videoDurationLabel)
        addConstraintsWithFormat(format: "H:[v1]-15-[v0]-10-[v2]", views: videoDurationLabel, videoSlider, expandContractButton)
        addConstraint(NSLayoutConstraint(item: videoDurationLabel, attribute: .centerY, relatedBy: .equal, toItem: bottomControlsView, attribute: .centerY, multiplier: 1, constant: 0))
        
        addSubview(videoTitleLabel)
        addConstraintsWithFormat(format: "H:|-10-[v0]", views: videoTitleLabel)
        addConstraintsWithFormat(format: "V:[v1]-10-[v0]", views: videoTitleLabel, youtubePlayer)
        
        addSubview(moreOptionsButton)
        addConstraintsWithFormat(format: "H:[v0(40)]-5-|", views: moreOptionsButton)
        addConstraintsWithFormat(format: "V:[v0(40)]", views: moreOptionsButton)
        addConstraint(NSLayoutConstraint(item: moreOptionsButton, attribute: .centerY, relatedBy: .equal, toItem: videoTitleLabel, attribute: .centerY, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: videoTitleLabel, attribute: .right, relatedBy: .equal, toItem: moreOptionsButton, attribute: .left, multiplier: 1, constant: -5))
        
        addSubview(bottomChangeVideoControls)
        addConstraintsWithFormat(format: "H:|[v0]|", views: bottomChangeVideoControls)
        addConstraintsWithFormat(format: "V:[v0(60)]|", views: bottomChangeVideoControls)
        
        bottomChangeVideoControls.addSubview(currentVideoRatioLabel)
        addConstraintsWithFormat(format: "H:[v0]", views: currentVideoRatioLabel)
        addConstraintsWithFormat(format: "V:[v0]", views: currentVideoRatioLabel)
        addConstraint(NSLayoutConstraint(item: currentVideoRatioLabel, attribute: .centerY, relatedBy: .equal, toItem: bottomChangeVideoControls, attribute: .centerY, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: currentVideoRatioLabel, attribute: .centerX, relatedBy: .equal, toItem: bottomChangeVideoControls, attribute: .centerX, multiplier: 1, constant: 0))
        
        bottomChangeVideoControls.addSubview(previousVideoButton)
        addConstraintsWithFormat(format: "H:|-20-[v0]", views: previousVideoButton)
        addConstraint(NSLayoutConstraint(item: previousVideoButton, attribute: .centerY, relatedBy: .equal, toItem: bottomChangeVideoControls, attribute: .centerY, multiplier: 1, constant: 0))
        
        bottomChangeVideoControls.addSubview(nextVideoButton)
        addConstraintsWithFormat(format: "H:[v0]-20-|", views: nextVideoButton)
        addConstraint(NSLayoutConstraint(item: nextVideoButton, attribute: .centerY, relatedBy: .equal, toItem: bottomChangeVideoControls, attribute: .centerY, multiplier: 1, constant: 0))
        
        addSubview(bottomBorderView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: bottomBorderView)
        addConstraintsWithFormat(format: "V:[v0(0.7)]", views: bottomBorderView)
        addConstraint(NSLayoutConstraint(item: bottomBorderView, attribute: .bottom, relatedBy: .equal, toItem: bottomChangeVideoControls, attribute: .top, multiplier: 1, constant: 0))
        
        addSubview(tableView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: tableView)
        addConstraintsWithFormat(format: "V:[v1]-15-[v0]", views: tableView, videoTitleLabel)
        addConstraint(NSLayoutConstraint(item: tableView, attribute: .bottom, relatedBy: .equal, toItem: bottomBorderView, attribute: .top, multiplier: 1, constant: 0))
        
        addSubview(videoDarkFilterView)
        videoDarkFilterView.frame = youtubePlayer.frame
        
        addSubview(forwardBackgroundView)
        forwardBackgroundView.clipsToBounds = true
        forwardBackgroundView.layer.cornerRadius = youtubePlayer.bounds.size.height / 1.75
        forwardBackgroundView.frame = CGRect(x: Int((youtubePlayer.bounds.size.width / 2) + (youtubePlayer.bounds.size.width / 5)), y: Int(-(youtubePlayer.frame.size.height * 0.20)), width: Int(UIScreen.main.bounds.size.width), height: Int(youtubePlayer.frame.size.height + (youtubePlayer.frame.size.height * 0.5 )))
        addConstraint(NSLayoutConstraint(item: forwardBackgroundView, attribute: .centerY, relatedBy: .equal, toItem: youtubePlayer, attribute: .centerY, multiplier: 1, constant: 0))
        
        addSubview(rewindBackgroundView)
        rewindBackgroundView.clipsToBounds = true
        rewindBackgroundView.layer.cornerRadius = youtubePlayer.bounds.size.height / 1.75
        rewindBackgroundView.frame = CGRect(x: Int(-((youtubePlayer.bounds.size.width / 2) + (youtubePlayer.bounds.size.width / 5))), y: Int(-(youtubePlayer.frame.size.height * 0.20)), width: Int(UIScreen.main.bounds.size.width), height: Int(youtubePlayer.frame.size.height + (youtubePlayer.frame.size.height * 0.5)))
        addConstraint(NSLayoutConstraint(item: rewindBackgroundView, attribute: .centerY, relatedBy: .equal, toItem: youtubePlayer, attribute: .centerY, multiplier: 1, constant: 0))
        
        addSubview(forwardBackgroundImage)
        addConstraintsWithFormat(format: "H:[v0(80)]", views: forwardBackgroundImage)
        addConstraintsWithFormat(format: "V:[v0(30)]", views: forwardBackgroundImage)
        forwardBackgroundImage.frame = CGRect(x: 0, y: 0, width: youtubePlayer.bounds.size.height / 6, height: youtubePlayer.bounds.size.height / 6)
        addConstraint(NSLayoutConstraint(item: forwardBackgroundImage, attribute: .right, relatedBy: .equal, toItem: youtubePlayer, attribute: .right, multiplier: 1, constant: -(youtubePlayer.bounds.size.width / 16)))
        addConstraint(NSLayoutConstraint(item: forwardBackgroundImage, attribute: .centerY, relatedBy: .equal, toItem: youtubePlayer, attribute: .centerY, multiplier: 1, constant: 0))

        addSubview(rewindBackgroundImage)
        addConstraintsWithFormat(format: "H:[v0(80)]", views: rewindBackgroundImage)
        addConstraintsWithFormat(format: "V:[v0(30)]", views: rewindBackgroundImage)
        rewindBackgroundImage.frame = CGRect(x: 0, y: 0, width: youtubePlayer.bounds.size.height / 6, height: youtubePlayer.bounds.size.height / 6)
        addConstraint(NSLayoutConstraint(item: rewindBackgroundImage, attribute: .left, relatedBy: .equal, toItem: youtubePlayer, attribute: .left, multiplier: 1, constant: (youtubePlayer.bounds.size.width / 16)))
        addConstraint(NSLayoutConstraint(item: rewindBackgroundImage, attribute: .centerY, relatedBy: .equal, toItem: youtubePlayer, attribute: .centerY, multiplier: 1, constant: 0))
        
        addSubview(darkView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: darkView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: darkView)
        bringSubview(toFront: darkView)
        
        addSubview(shareView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: shareView)
        addConstraintsWithFormat(format: "V:[v0]", views: shareView)
        addConstraint(NSLayoutConstraint(item: shareView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
        bringSubview(toFront: shareView)
        shareView.itemPressed = {[weak self] title, post, linkToShare in
            if self != nil {
                print("shareItemPressed ----> \(title)")
                self?.handleShareViewRowTapped(title, post, linkToShare)
            }
        }
        shareView.cancelTapped = {[weak self] in
            if self != nil {
                self?.darkenView(false)
                self?.shareView.dismiss()
            }
        }
        
        //moreOptionsView
        addSubview(moreOptionsView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: moreOptionsView)
        addConstraintsWithFormat(format: "V:[v0]", views: moreOptionsView)
        addConstraint(NSLayoutConstraint(item: moreOptionsView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
        bringSubview(toFront: moreOptionsView)
        moreOptionsView.tableCellTapped = {[weak self] row, post in
            if self != nil {
                self?.moreOptionsButton.isUserInteractionEnabled = true
                self?.handleMoreOptionsRowTapped(row, post)
            }
        }
        
        //collectionView
        addSubview(collectionView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: collectionView)
        addConstraintsWithFormat(format: "V:|[v0(6)]", views: collectionView)
        collectionView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: ((UIScreen.main.bounds.size.width / 7) / 10))
        collectionView.register(YouTubeVolumeCell.self, forCellWithReuseIdentifier: "YouTubeVolumeCell")
        
        //gestures
        controlsSuperViewTap = UITapGestureRecognizer(target: self, action: #selector(YoutubePlayView.controlsSuperViewTapGesture(_:)))
        self.controlsSuperView.addGestureRecognizer(controlsSuperViewTap)
        
        controlsSuperViewDoubleTap = UITapGestureRecognizer(target: self, action: #selector(YoutubePlayView.controlsSuperViewDoubleTapGesture(_:)))
        controlsSuperViewDoubleTap.numberOfTapsRequired = 2
        self.controlsSuperView.addGestureRecognizer(controlsSuperViewDoubleTap)
        
        let moreOptionsTap = UITapGestureRecognizer(target: self, action: #selector(YoutubePlayView.moreOptionsButtonTapped(_:)))
        self.moreOptionsButton.addGestureRecognizer(moreOptionsTap)
        
        let nextVideoTap = UITapGestureRecognizer(target: self, action: #selector(YoutubePlayView.nextVideoLabelTapGesture(_:)))
        self.nextVideoLabel.addGestureRecognizer(nextVideoTap)
        
        let expandContractTap = UITapGestureRecognizer(target: self, action: #selector(YoutubePlayView.expandContractButtonTapped(_:)))
        self.expandContractButton.addGestureRecognizer(expandContractTap)
        
        let previousVideoTap = UITapGestureRecognizer(target: self, action: #selector(YoutubePlayView.previousVideoButtonTapped(_:)))
        self.previousVideoButton.addGestureRecognizer(previousVideoTap)
        
        let nextVideoButtonTap = UITapGestureRecognizer(target: self, action: #selector(YoutubePlayView.nextVideoButtonTapped(_:)))
        self.nextVideoButton.addGestureRecognizer(nextVideoButtonTap)
        
        let cancelTap = UITapGestureRecognizer(target: self, action: #selector(YoutubePlayView.minimizeButtonTapped(_:)))
        self.minimizeButton.addGestureRecognizer(cancelTap)
        
        let playPauseTap = UITapGestureRecognizer(target: self, action: #selector(YoutubePlayView.playPauseButtonTapped(_:)))
        self.playPauseButton.addGestureRecognizer(playPauseTap)
        
        let forwardButtonTap = UITapGestureRecognizer(target: self, action: #selector(YoutubePlayView.forwardButtonTapped))
        self.forwardView.addGestureRecognizer(forwardButtonTap)
        
        let rewindButtonTap = UITapGestureRecognizer(target: self, action: #selector(YoutubePlayView.rewindButtonTapped))
        self.rewindView.addGestureRecognizer(rewindButtonTap)
        
        self.dismissFromMaxPanGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedMaxView(_:)))
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(self.dismissFromMaxPanGesture)
        
        
        
        videoDurationLabel.text = ""
        nextVideoLabel.text = "Next Video 〉"
        setVideoTitle()
        
        //add shadow background to nextVideoLabel
        nextVideoLabel.backgroundColor = UIColor.clear
        nextVideoLabel.layer.shadowOffset = CGSize(width: 0, height: 0)
        nextVideoLabel.layer.shadowOpacity = 5
        nextVideoLabel.layer.shadowRadius = 1
        
        //add shadow background to videoDurationLabel
        videoDurationLabel.backgroundColor = UIColor.clear
        videoDurationLabel.layer.shadowOffset = CGSize(width: 0, height: 0)
        videoDurationLabel.layer.shadowOpacity = 5
        videoDurationLabel.layer.shadowRadius = 1
        
        /*
         //add bottom gradient layer
         let gradientBottomLayer = CAGradientLayer()
         gradientBottomLayer.frame = bottomControlsView.bounds
         gradientBottomLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
         gradientBottomLayer.locations = [0.4, 1.2]
         bottomControlsView.layer.addSublayer(gradientBottomLayer)
         
         //add top gradient layer
         let gradientTopLayer = CAGradientLayer()
         gradientTopLayer.frame = bottomControlsView.bounds
         gradientTopLayer.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
         gradientTopLayer.locations = [-0.2, 0.6]
         topControlsView.layer.addSublayer(gradientTopLayer)
         */
        
        //move nextVideoButton image to right
        nextVideoButton.semanticContentAttribute = .forceRightToLeft
        
        setCurrentVideoRatioLabel()
        
        //set dark filter for video controls
        videoDarkFilterView.isHidden = true
        let overlay: UIView = UIView(frame: CGRect(x: 0, y: 0, width: youtubePlayer.frame.size.width + 100, height: youtubePlayer.frame.size.height))
        overlay.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.2)
        videoDarkFilterView.addSubview(overlay)
        self.sendSubview(toBack: videoDarkFilterView)
        self.sendSubview(toBack: youtubePlayer)
        videoDarkFilterView.leadingAnchor.constraint(equalTo: youtubePlayer.leadingAnchor).isActive = true
        videoDarkFilterView.bottomAnchor.constraint(equalTo: youtubePlayer.bottomAnchor).isActive = true
        videoDarkFilterView.rightAnchor.constraint(equalTo: youtubePlayer.rightAnchor).isActive = true
        videoDarkFilterView.topAnchor.constraint(equalTo: youtubePlayer.topAnchor).isActive = true
        
    }
    
    func setupPlayBack() {
        let defaults = UserDefaults.standard
        
        if let forward = defaults.string(forKey: "skipForward") {
            if let fw = Int(forward) {
                forwardSeek = Int(fw)
            }
        }
        if let back = defaults.string(forKey: "skipBack") {
            if let rw = Int(back) {
                rewindSeek = Int(rw)
            }
        }
    }
    
    func listenVolumeButton(){
        do { try audioSession.setActive(false) }
        catch { debugPrint("\(error)") }
        audioSession.addObserver(self, forKeyPath: "outputVolume", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    func darkenView(_ darken: Bool) {
        if(darken) {
            self.darkView.isHidden = false
        } else {
            self.darkView.isHidden = true
        }
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        let youtubeVideoListCell = UINib(nibName: "BBYoutubeVideoListCell", bundle: Bundle.main)
        tableView.register(youtubeVideoListCell, forCellReuseIdentifier: "YoutubeVideoListCell")
        
        tableView.estimatedRowHeight = CGFloat(150)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.scrollsToTop = true
    }
    
    func setCurrentVideoRatioLabel() {
        let currentVideoNumber = currentPostIndex + 1
        currentVideoRatioLabel.text = "\(currentVideoNumber)/\(posts.count)"
    }
    
    func setBottomChangeVideoControlColor() {
        //alter color of changeVideoControls
        if posts.indices.contains(currentPostIndex - 1) {
            previousVideoButton.titleLabel?.textColor = BBTheme.Colors.textPrimaryLight.color
        } else {
            previousVideoButton.titleLabel?.textColor = BBTheme.Colors.textHint.color
        }
        
        if posts.indices.contains(currentPostIndex + 1) {
            nextVideoButton.titleLabel?.textColor = BBTheme.Colors.textPrimaryLight.color
        } else {
            nextVideoButton.titleLabel?.textColor = BBTheme.Colors.textHint.color
        }
    }
    
    func setVideoTitle() {
        videoTitleLabel.text = ""
        
        let post = posts[currentPostIndex]
        if(post.comment != nil) {
            videoTitleLabel.text = post.comment
        }
    }
    
    func setupYoutubePlayer() {
        self.hideViews(hide: true)
        self.youtubePlayer.delegate = self
        setPlayerVars()
    }
    
    func setPlayerVars() {
        //set playlist starting at posts[1] because we are already loading posts[0] into the playerview
        if posts.count > 1 {
            var playlistVideoIDs = ""
            let postsAfterFirstCount = [Int](1..<self.posts.count)
            for count in postsAfterFirstCount {
                let post = self.posts[count]
                if let youtubeLink = post.youtubeLink {
                    if(!youtubeLink.isEmpty){
                        if(playlistVideoIDs == "") {
                            //first post
                            playlistVideoIDs = "\(youtubeLink)"
                        } else {
                            //more posts
                            playlistVideoIDs = "\(playlistVideoIDs), \(youtubeLink)"
                        }
                    }
                }
            }
            playerVars = [
                "playsinline" : 1,
                "showinfo" : 0,
                "rel" : 0,
                "modestbranding" : 1,
                "controls" : 0,
                "fs" : 0,
                "playlist" : [],
                "cc_load_policy" : 0,
                "iv_load_policy" : 3,
                "autoplay" : 0,
                "origin" : "https://www.youtube.com",
                ] as [String : Any]
        }
    }
    
    func startVideo() {
        if posts.count > 0 {
            //play first video
            if let youtubeLink = self.posts[currentPostIndex].youtubeLink {
                self.currentYoutubeVideoID = youtubeLink
                if(!youtubeLink.isEmpty){
                    youtubePlayer.load(withVideoId: youtubeLink, playerVars: playerVars)
                    if let postid = self.posts[currentPostIndex].postid {
                        storeWatchActivity(postid: postid)
                    }
                } else {
                    //do something
                }
            }
        }
    }
    
    func playPreviousVideo() {
        if posts.indices.contains(currentPostIndex - 1) {
            currentPostIndex -= 1
            if let linkToPlay = posts[currentPostIndex].youtubeLink {
                youtubePlayer.loadVideo(byId: linkToPlay, startSeconds: 0.0, suggestedQuality: YTPlaybackQuality.auto)
                setVideoDurationTime()
                setVideoTitle()
                setBottomChangeVideoControlColor()
                setCurrentVideoRatioLabel()
            }
        }
    }
    
    func playNextVideo() {
        if posts.indices.contains(currentPostIndex + 1) {
            currentPostIndex += 1
            if let linkToPlay = posts[currentPostIndex].youtubeLink {
                youtubePlayer.loadVideo(byId: linkToPlay, startSeconds: 0.0, suggestedQuality: YTPlaybackQuality.auto)
                setVideoDurationTime()
                setVideoTitle()
                setBottomChangeVideoControlColor()
                setCurrentVideoRatioLabel()
                if let postid = self.posts[currentPostIndex].postid {
                    storeWatchActivity(postid: postid)
                }
            }
        } else {
            cancelMedia()
        }
    }
    
    @objc func cancelMedia() {
        if (youtubePlayer != nil) {
            youtubePlayer.pauseVideo()
        }
        if dismissTapped != nil {
            self.dismissTapped!()
        }
        UIApplication.shared.isStatusBarHidden = false
    }
    
    func addCustomVolume() {
        addSubview(volumeView)
        sendSubview(toBack: volumeView)
    }
    
    func removeCustomVolume() {
        volumeView.removeFromSuperview()
    }
    
    func hideCustomVolume(hide: Bool) {
        if(hide) {
            UIView.animate(withDuration: 0.3, animations: {
                self.collectionView.alpha = 0
            }, completion:  { (value: Bool) in
                self.collectionView.isHidden = true
                if(self.hideVolumeTimer != nil) {
                    self.hideVolumeTimer.invalidate()
                }
            })
        } else {
            self.collectionView.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                self.collectionView.alpha = 1
            }, completion: { (value: Bool) in
                if(self.hideVolumeTimer != nil) {
                    self.hideVolumeTimer.invalidate()
                }
                Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(self.timerHideVolume), userInfo: nil, repeats: false)
            })
        }
    }
    
    @objc func timerHideVolume() {
        if(!collectionView.isHidden) {
            hideCustomVolume(hide: true)
        }
    }
    
    func hideViews(hide: Bool) {
        if(hide) {
             UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.videoDarkFilterView.alpha = 0
                self.topControlsView.alpha = 0
                self.bottomControlsView.alpha = 0
                self.middleControlsView.alpha = 0
             }, completion: { (true) in
                self.videoDarkFilterView.isHidden = true
                self.topControlsView.tag = 1
                self.middleControlsView.isHidden = true
                self.topControlsView.isHidden = true
                self.bottomControlsView.isHidden = true
                self.middleControlsView.alpha = 0
                self.videoDarkFilterView.alpha = 1
                self.topControlsView.alpha = 1
                self.bottomControlsView.alpha = 1
             })
        } else {
            UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.videoDarkFilterView.alpha = 1
                self.middleControlsView.alpha = 1
                self.topControlsView.alpha = 1
                self.bottomControlsView.alpha = 1
            }, completion: { (true) in
                self.videoDarkFilterView.isHidden = false
                self.middleControlsView.isHidden = false
                self.topControlsView.tag = 0
                self.topControlsView.isHidden = false
                self.bottomControlsView.isHidden = false
            })
        }
    }
    
    @objc func timerHideViews() {
        if(!topControlsView.isHidden) {
            hideViews(hide: true)
        }
    }
    
    func closingViews(hide: Bool) {
        if(hide) {
            self.videoDarkFilterView.isHidden = true
            self.topControlsView.tag = 1
            self.middleControlsView.isHidden = true
            self.topControlsView.isHidden = true
            self.bottomControlsView.isHidden = true
            self.bottomChangeVideoControls.isHidden = true
            self.bottomBorderView.isHidden = true
            self.tableView.isHidden = true
            self.moreOptionsView.isHidden = true
            self.shareView.isHidden = true
            self.backgroundColor = .black
        } else {
            self.videoDarkFilterView.isHidden = false
            self.topControlsView.tag = 0
            self.topControlsView.isHidden = false
            self.middleControlsView.isHidden = false
            self.bottomControlsView.isHidden = false
            self.bottomChangeVideoControls.isHidden = false
            self.bottomBorderView.isHidden = false
            self.tableView.isHidden = false
            self.moreOptionsView.isHidden = false
            self.shareView.isHidden = false
            self.backgroundColor = .white
        }
    }
    
    @objc func minimize() {
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: .curveEaseInOut, animations: {
            UIApplication.shared.isStatusBarHidden = false
            if let keyWindow = UIApplication.shared.keyWindow {
                self.frame = CGRect(x: keyWindow.frame.width - self.youtubePlayerMinWidth, y: keyWindow.frame.height - self.youtubePlayerMinHeight, width: self.youtubePlayerMinWidth, height: self.youtubePlayerMinHeight)
            }
            
            self.closingViews(hide: true)
            self.youtubePlayer.translatesAutoresizingMaskIntoConstraints = false
            self.youtubePlayer.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            //self.youtubePlayer.frame = self.frame
            self.controlsSuperView.frame = CGRect(x: 0, y: 0, width: Int(self.youtubePlayer.frame.width), height: Int(self.youtubePlayer.frame.height))
            self.videoDarkFilterView.subviews[0].frame = CGRect(x: 0, y: 0, width: self.youtubePlayer.frame.size.width + 100, height: self.youtubePlayer.frame.size.height + 100)
            
            self.controlsSuperView.removeGestureRecognizer(self.controlsSuperViewTap)
            self.maximizeTap = UITapGestureRecognizer(target: self, action: #selector(YoutubePlayView.maximize(_:)))
            self.controlsSuperView.addGestureRecognizer(self.maximizeTap)
            
            self.dismissPanGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedView(_:)))
            self.isUserInteractionEnabled = true
            self.addGestureRecognizer(self.dismissPanGesture)
            self.currentDragPoint = self.center
        }, completion: { (true) in
            //do something
            self.tableView.alpha = 1
            self.videoTitleLabel.alpha = 1
            self.bottomChangeVideoControls.alpha = 1
            self.bottomBorderView.alpha = 1
            self.shareView.alpha = 1
            self.moreOptionsView.alpha = 1
            self.backgroundColor = UIColor.white
        })
    }
    
    @objc func maximize(_ sender: Any) {
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: .curveEaseInOut, animations: {
            UIApplication.shared.isStatusBarHidden = true
            if let keyWindow = UIApplication.shared.keyWindow {
                self.frame = keyWindow.frame
            }
            self.closingViews(hide: false)
            self.youtubePlayer.translatesAutoresizingMaskIntoConstraints = true
            self.youtubePlayer.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = false
            self.youtubePlayer.frame = CGRect(x: 0, y: 0, width: Int(self.frame.size.width), height: Int(self.frame.size.width * 9 / 16))
            self.controlsSuperView.frame = CGRect(x: 0, y: 0, width: Int(self.youtubePlayer.frame.width), height: Int(self.youtubePlayer.frame.height))
            self.videoDarkFilterView.subviews[0].frame = CGRect(x: 0, y: 0, width: self.youtubePlayer.frame.size.width + 100, height: self.youtubePlayer.frame.size.height)
            
            self.removeGestureRecognizer(self.dismissPanGesture)
            self.controlsSuperView.removeGestureRecognizer(self.maximizeTap)
            self.controlsSuperViewTap = UITapGestureRecognizer(target: self, action: #selector(YoutubePlayView.controlsSuperViewTapGesture(_:)))
            self.controlsSuperView.addGestureRecognizer(self.controlsSuperViewTap)
            self.currentMaxDragPoint = CGPoint(x: self.center.x, y: (self.center.y / 2))
        }, completion: { (true) in
            //do something
        })
    }
    
    func seekTo(forward: Bool, rewind: Bool) {
        let videoDuration = youtubePlayer.duration()
        let currentTime = youtubePlayer.currentTime()
        var desiredTime = 0.0
        if(forward) {
            desiredTime = Double(currentTime + Float(forwardSeek))
        } else if(rewind) {
            desiredTime = Double(currentTime - Float(rewindSeek))
        }
        
        if(desiredTime > 0 && desiredTime < videoDuration) {
            youtubePlayer.seek(toSeconds: Float(desiredTime), allowSeekAhead: true)
        } else if(rewind) {
            youtubePlayer.seek(toSeconds: Float(0.0), allowSeekAhead: true)
        }
    }
    
    func changePlayStateButton() {
        if(isPlaying) {
            isPlaying = false
            playPauseButton.setImage(UIImage(named: "ic_play"), for: UIControlState())
            youtubePlayer.pauseVideo()
        } else {
            isPlaying = true
            playPauseButton.setImage(UIImage(named: "ic_pause"), for: UIControlState())
            youtubePlayer.playVideo()
        }
    }
    
    func setVideoDurationTime() {
        let videoDurationInSeconds = youtubePlayer.duration()
        videoDurationLabel.text = ""
        let secondsText = String(format: "%02d", Int(videoDurationInSeconds) % 60)
        let minutesText = String(format: "%02d", Int(videoDurationInSeconds) / 60)
        videoDurationLabel.text = "\(minutesText):\(secondsText)"
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        switch (state) {
        case YTPlayerState.buffering:
            break
        case YTPlayerState.playing:
            hideViews(hide: true)
            if(playerView.currentTime() < 1.0) {
                setVideoDurationTime()
            }
            break;
        case YTPlayerState.paused:
            hideViews(hide: false)
            break;
        case YTPlayerState.queued:
            break;
        case YTPlayerState.unstarted:
            if posts.indices.contains(currentPostIndex + 1) {
                currentPostIndex += 1
                setVideoDurationTime()
                setVideoTitle()
                setBottomChangeVideoControlColor()
                setCurrentVideoRatioLabel()
            }
            break;
        case YTPlayerState.ended:
            isPlaying = false
            if posts.indices.contains(currentPostIndex + 1) {
                playNextVideo()
                isPlaying = true
                playPauseButton.setImage(UIImage(named: "ic_pause"), for: UIControlState())
            } else {
                cancelMedia()
            }
            break;
        default:
            break;
        }
    }
    
    func playerView(_ playerView: YTPlayerView, didPlayTime playTime: Float) {
        //move the videoSlider
        let playTimeInSeconds = CMTime(seconds: Double(playTime), preferredTimescale: 1)
        let seconds = CMTimeGetSeconds(playTimeInSeconds)
        
        let duration = CMTime(seconds: playerView.duration(), preferredTimescale: 1)
        let durationSeconds = CMTimeGetSeconds(duration)
        
        videoSlider.value = Float(seconds / durationSeconds)
    }
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        playerView.playVideo()
        isPlaying = true
        playPauseButton.setImage(UIImage(named: "ic_pause"), for: UIControlState())
        setVideoDurationTime()
        setVideoTitle()
        setCurrentVideoRatioLabel()
    }
    
    func handleMoreOptionsRowTapped(_ row: Int, _ post: BBPost) {
        switch row {
        case 0:
            //play next
            self.setVideoToPlayNext(post, row)
            break
        case 1:
            //add post to Watch Later
            if let postid = post.postid  {
                self.addPostToWatchList(postid: postid)
            }
            break
        case 2:
            //share post
            self.presentSharePostPopUp(post)
            break
        case 3:
            //cancel
            break
        default:
            break
        }
        self.darkenView(false)
        moreOptionsView.dismiss()
    }
    
    @objc func moreOptionsButtonTapped(_ sender: Any) {
        if let postid = self.posts[self.currentPostIndex].postid  {
            AppUtility.hapticOnce()
            
            let post = self.posts[self.currentPostIndex]
            moreOptionsButton.isUserInteractionEnabled = false
            moreOptionsView.post = post
            moreOptionsView.show()
            self.darkenView(true)
        }
    }
    
    
    @objc func expandContractButtonTapped(_ sender: Any) {
        if(AppUtility.currentOrientation == "portrait") {
            AppUtility.setOrientation(orientation: "landscapeRight")
            if let keyWindow = UIApplication.shared.keyWindow {
                self.frame = keyWindow.frame
                self.youtubePlayer.frame = keyWindow.frame
            }
            tableView.isHidden = true
            youtubePlayer.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            //youtubePlayer.frame.size.width = self.frame.size.width
           // youtubePlayer.frame.size.height = self.frame.size.height
            controlsSuperView.frame = CGRect(x: 0, y: 0, width: Int(youtubePlayer.frame.width), height: Int(youtubePlayer.frame.height))
            videoDarkFilterView.subviews[0].frame = CGRect(x: 0, y: 0, width: youtubePlayer.frame.size.width + 100, height: youtubePlayer.frame.size.height + 100)
            expandContractButton.setImage(UIImage(named: "ic_contract"), for: UIControlState())
            rewindBackgroundView.layer.cornerRadius = youtubePlayer.bounds.size.height / 1.6
            forwardBackgroundView.layer.cornerRadius = youtubePlayer.bounds.size.height / 1.6
            rewindBackgroundView.frame = CGRect(x: Int(-((youtubePlayer.bounds.size.width / 2) + (youtubePlayer.bounds.size.width / 5))), y: Int(-(youtubePlayer.frame.size.height * 0.20)), width: Int(UIScreen.main.bounds.size.width), height: Int(youtubePlayer.frame.size.height + (youtubePlayer.frame.size.height * 0.5)))
            forwardBackgroundView.frame = CGRect(x: Int((youtubePlayer.bounds.size.width / 2) + (youtubePlayer.bounds.size.width / 5)), y: Int(-(youtubePlayer.frame.size.height * 0.20)), width: Int(UIScreen.main.bounds.size.width), height: Int(youtubePlayer.frame.size.height + (youtubePlayer.frame.size.height * 0.5)))
            rewindBackgroundImage.frame = CGRect(x: 0, y: 0, width: youtubePlayer.bounds.size.height / 6, height: youtubePlayer.bounds.size.height / 6)
            forwardBackgroundImage.frame = CGRect(x: 0, y: 0, width: youtubePlayer.bounds.size.height / 6, height: youtubePlayer.bounds.size.height / 6)
            bottomChangeVideoControls.isHidden = true
            bottomBorderView.isHidden = true
            collectionView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 6)
            collectionView.reloadData()
            addCustomVolume()
            self.removeGestureRecognizer(self.dismissFromMaxPanGesture)
        } else if(AppUtility.currentOrientation == "landscapeRight") {
            AppUtility.setOrientation(orientation: "portrait")
            if let keyWindow = UIApplication.shared.keyWindow {
                self.frame = keyWindow.frame
            }
            youtubePlayer.translatesAutoresizingMaskIntoConstraints = true
            youtubePlayer.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = false
            youtubePlayer.frame = CGRect(x: 0, y: 0, width: Int(self.frame.size.width), height: Int(self.frame.size.width * 9 / 16))
            //youtubePlayer.frame.size.width = self.frame.size.width
            controlsSuperView.frame = CGRect(x: 0, y: 0, width: Int(youtubePlayer.frame.width), height: Int(youtubePlayer.frame.height))
            videoDarkFilterView.subviews[0].frame = CGRect(x: 0, y: 0, width: youtubePlayer.frame.size.width + 100, height: youtubePlayer.frame.size.height)
            tableView.isHidden = false
            expandContractButton.setImage(UIImage(named: "ic_expand"), for: UIControlState())
            rewindBackgroundView.layer.cornerRadius = youtubePlayer.bounds.size.height / 1.75
            forwardBackgroundView.layer.cornerRadius = youtubePlayer.bounds.size.height / 1.75
            rewindBackgroundView.frame = CGRect(x: Int(-((UIScreen.main.bounds.size.width / 2) + (UIScreen.main.bounds.size.width / 5))), y: Int(-(youtubePlayer.frame.size.height * 0.20)), width: Int(UIScreen.main.bounds.size.width), height: Int(youtubePlayer.frame.size.height + (youtubePlayer.frame.size.height * 0.5)))
            forwardBackgroundView.frame = CGRect(x: Int((UIScreen.main.bounds.size.width / 2) + (UIScreen.main.bounds.size.width / 5)), y: Int(-(youtubePlayer.frame.size.height * 0.20)), width: Int(UIScreen.main.bounds.size.width), height: Int(youtubePlayer.frame.size.height + (youtubePlayer.frame.size.height * 0.5)))
            rewindBackgroundImage.frame = CGRect(x: 0, y: 0, width: youtubePlayer.bounds.size.height / 6, height: youtubePlayer.bounds.size.height / 6)
            forwardBackgroundImage.frame = CGRect(x: 0, y: 0, width: youtubePlayer.bounds.size.height / 6, height: youtubePlayer.bounds.size.height / 6)
            bottomChangeVideoControls.isHidden = false
            bottomBorderView.isHidden = false
            collectionView.isHidden = true
            removeCustomVolume()
            self.dismissFromMaxPanGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedMaxView(_:)))
            self.isUserInteractionEnabled = true
            self.addGestureRecognizer(self.dismissFromMaxPanGesture)
        }
    }
    
    
    @objc func previousVideoButtonTapped(_ sender: Any) {
        playPreviousVideo()
        isPlaying = true
        playPauseButton.setImage(UIImage(named: "ic_pause"), for: UIControlState())
    }
    
    
    @objc func nextVideoButtonTapped(_ sender: Any) {
        playNextVideo()
        isPlaying = true
        playPauseButton.setImage(UIImage(named: "ic_pause"), for: UIControlState())
    }
    
    
    @objc func minimizeButtonTapped(_ sender: Any) {
        if(AppUtility.currentOrientation == "landscapeRight") {
            let emptyButton = UIButton()
            self.expandContractButtonTapped(emptyButton)
        }
        minimize()
    }
    
    @objc func playPauseButtonTapped(_ sender: Any) {
        changePlayStateButton()
    }
    
    @objc func forwardButtonTapped() {
        seekTo(forward: true, rewind: false)
    }
    
    @objc func rewindButtonTapped() {
        seekTo(forward: false, rewind: true)
    }
    
    func forwardDoubleTapped() {
        forwardButtonTapped()
        UIView.animate(withDuration: 0, animations: {
            self.forwardBackgroundView.alpha = 1
            self.forwardBackgroundImage.alpha = 1
        }, completion:  { (value: Bool) in
            self.forwardBackgroundView.isHidden = false
            self.forwardBackgroundImage.isHidden = false
            UIView.animate(withDuration: 1.0, animations: {
                self.forwardBackgroundView.alpha = 0
                self.forwardBackgroundImage.alpha = 0
            }, completion:  { (value: Bool) in
                self.forwardBackgroundView.isHidden = true
                self.forwardBackgroundImage.isHidden = true
            })
        })
    }
    
    func rewindDoubleTapped() {
        rewindButtonTapped()
        UIView.animate(withDuration: 0, animations: {
            self.rewindBackgroundView.alpha = 1
            self.rewindBackgroundImage.alpha = 1
        }, completion:  { (value: Bool) in
            self.rewindBackgroundView.isHidden = false
            self.rewindBackgroundImage.isHidden = false
            UIView.animate(withDuration: 1.0, animations: {
                self.rewindBackgroundView.alpha = 0
                 self.rewindBackgroundImage.alpha = 0
            }, completion:  { (value: Bool) in
                self.rewindBackgroundView.isHidden = true
                self.rewindBackgroundImage.isHidden = true
            })
        })
    }
    
    @objc func handlesSliderChange(_ sender: AnyObject?) {
        let duration = CMTime(seconds: youtubePlayer.duration(), preferredTimescale: 1)
        let totalSeconds = CMTimeGetSeconds(duration)
        
        let value = Float64(videoSlider.value) * totalSeconds
        
        let seekTime = CMTime(value: Int64(value), timescale: 1)
        youtubePlayer.seek(toSeconds: Float(CMTimeGetSeconds(seekTime)), allowSeekAhead: true)
    }
    
    
    @objc func controlsSuperViewTapGesture(_ gesture: UITapGestureRecognizer) {
        if(topControlsView.isHidden) {
            hideViews(hide: false)
            if(hideViewsTimer != nil) {
                hideViewsTimer.invalidate()
            }
            hideViewsTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(timerHideViews), userInfo: nil, repeats: false)
        } else {
            if(hideViewsTimer != nil) {
                hideViewsTimer.invalidate()
            }
            hideViews(hide: true)
        }
    }
    
    @objc func controlsSuperViewDoubleTapGesture(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        let locationX = location.x
        if locationX < (UIScreen.main.bounds.size.width / 2) {
            //rewind
            rewindDoubleTapped()
            print("rewind once")
        } else {
            //forward
            forwardDoubleTapped()
            print("forward once")
        }
        hideViews(hide: true)
    }
    
    @objc func nextVideoLabelTapGesture(_ gesture: UITapGestureRecognizer) {
        playNextVideo()
        isPlaying = true
        playPauseButton.setImage(UIImage(named: "ic_pause"), for: UIControlState())
    }
    
    func storeWatchActivity(postid: String) {
        LibraryAPI.sharedLibraryAPI.storeWatchedPostActivity(postid) {[weak self] results in
            if self != nil {
                switch results {
                case .success(let result):
                    print("SUCCESS storing watch activity \(result)")
                    break
                default:
                    print("FAILED storing watch activity")
                }
            }
        }
    }
    
    func addPostToWatchList(postid: String) {
        LibraryAPI.sharedLibraryAPI.addPostToWatchList(postid) {[weak self] results in
            if self != nil {
                switch results {
                case .success(let result):
                    print("SUCCESS storing post to WatchLater \(result)")
                    break
                default:
                    print("FAILED storing post to WatchLater")
                }
            }
        }
    }
    
    func removePostFromWatchList(postid: String) {
        LibraryAPI.sharedLibraryAPI.removePostFromWatchList(postid) {[weak self] results in
            if self != nil {
                switch results {
                case .success(let result):
                    print("SUCCESS removing post from WatchLater \(result)")
                    break
                default:
                    print("FAILED removing post from WatchLater")
                }
            }
        }
    }
    
    func removeVideoFromPlaylist(_ selectedPost: BBPost, _ row: Int) {
        print("removing post at row: \(row)")
        self.posts.removeObject(selectedPost)
        self.tableView.reloadData()
    }
    
    func setVideoToPlayNext(_ selectedPost: BBPost, _ row: Int) {
        var orderedVideoPosts = [BBPost]()
        let currentPostPlaying = self.posts[currentPostIndex]
        var count = 0
        let selectedIndexPath = row
        var beforeVideos = [BBPost]()
        var afterVideos = [BBPost]()
        for post in posts {
            if(post.postid == selectedPost.postid) {
                continue
            }
            if count < currentPostIndex {
                beforeVideos.append(post)
            } else if count > currentPostIndex {
                afterVideos.append(post)
            }
            count += 1
        }
        
        orderedVideoPosts.append(contentsOf: beforeVideos)
        orderedVideoPosts.append(currentPostPlaying)
        orderedVideoPosts.append(selectedPost)
        orderedVideoPosts.append(contentsOf: afterVideos)
        
        self.posts = orderedVideoPosts
        tableView.reloadData()
    }
    
    // MARK: - Table View DataSource
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        if (posts.count > 0) {
            return 1
        }
        return 0
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (posts.count > 0) {
            return posts.count
        }
        return 0
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    // MARK: - Table View Delegates
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getYoutubeVideoListCellForIndexpath(indexPath)
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        
        if(section == 0) {
            return
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    open func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let section = indexPath.section
        if(section == 0) {
            return false
        } else {
            return true
        }
    }
    
    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //empty method
    }
    
    func getYoutubeVideoListCellForIndexpath(_ indexPath: IndexPath) -> BBYoutubeVideoListCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "YoutubeVideoListCell", for: indexPath) as! BBYoutubeVideoListCell
        let selectedVideo = posts[indexPath.row]
        if let postid = selectedVideo.postid {
            cell.post = selectedVideo
        }
        if let link = selectedVideo.youtubeLink {
            let thumbnailPath = "http://img.youtube.com/vi/\(link)/mqdefault.jpg"
            cell.youtubeThumbnailView.sd_setImage(with: URL(string: thumbnailPath), placeholderImage: nil, options: [.continueInBackground])
        }
        
        if let postTitle = selectedVideo.comment {
            cell.youtubeTitle.text = postTitle
        }
        
        cell.cellLongPressed = {[weak self] selectedVideoPost in
            if self != nil {
                AppUtility.hapticOnce()
                self?.darkenView(true)
                self?.moreOptionsView.post = selectedVideoPost
                self?.moreOptionsView.show()
            }
        }
        
        cell.videoPressed = {[weak self] in
            if let weakSelf = self {
                weakSelf.darkenView(false)
                weakSelf.moreOptionsView.dismiss()
                weakSelf.moreOptionsButton.isUserInteractionEnabled = true
                
                let row = indexPath.row
                weakSelf.currentPostIndex = row
                if let linkToPlay = weakSelf.posts[weakSelf.currentPostIndex].youtubeLink {
                    weakSelf.youtubePlayer.loadVideo(byId: linkToPlay, startSeconds: 0.0, suggestedQuality: YTPlaybackQuality.auto)
                    let rowForRatio = row + 1
                    weakSelf.currentVideoRatioLabel.text = "\(rowForRatio)/\(weakSelf.posts.count)"
                    weakSelf.setVideoDurationTime()
                    weakSelf.setVideoTitle()
                    weakSelf.setBottomChangeVideoControlColor()
                }
            }}
        
        return cell
    }
    
    // MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return Int(UIScreen.main.bounds.size.width / (UIScreen.main.bounds.size.width / 12))
        return Int(volumeNumberOfItems)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return getYouTubeVolumeCellForIndexpath(indexPath)
    }
    
    func getYouTubeVolumeCellForIndexpath(_ indexPath: IndexPath) -> YouTubeVolumeCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "YouTubeVolumeCell", for: indexPath) as! YouTubeVolumeCell
        return cell
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "outputVolume"{
            guard let dict = change, let temp = dict[NSKeyValueChangeKey.newKey] as? Float else {return}
            volumeNumberOfItems = temp * Float((UIScreen.main.bounds.size.width / (UIScreen.main.bounds.size.width / 12)))
            collectionView.reloadData()
            if(AppUtility.currentOrientation == "landscapeRight") {
                if(collectionView.isHidden) {
                    self.hideCustomVolume(hide: false)
                }
            }
        }
    }
    
    func resetYoutubePlaylist(row: Int) {
        var beforeVideoIDs = [String]()
        var afterVideoIDs = [String]()
        var playlistVideoIDs = [String]()
        let postsCount = [Int](0..<self.posts.count)
        for count in postsCount {
            let post = self.posts[count]
            if(count >= row) {
                //add selected and after videos
                if let youtubeLink = post.youtubeLink {
                    if(!youtubeLink.isEmpty){
                        afterVideoIDs.append(youtubeLink)
                    }
                }
            } else {
                // add before videos
                if let youtubeLink = post.youtubeLink {
                    if(!youtubeLink.isEmpty){
                        beforeVideoIDs.append(youtubeLink)
                    }
                }
            }
        }
        playlistVideoIDs.append(contentsOf: afterVideoIDs)
        playlistVideoIDs.append(contentsOf: beforeVideoIDs)
        
        youtubePlayer.loadPlaylist(byVideos: playlistVideoIDs, index: 0, startSeconds: 0, suggestedQuality: YTPlaybackQuality.auto)
        youtubePlayer.playVideo()
        currentPostIndex = row - 1
        currentVideoRatioLabel.text = "\(row)/\(posts.count)"
    }
    
    @objc func draggedView(_ sender: UIPanGestureRecognizer){
        let translation = sender.translation(in: self)
        if sender.state == UIGestureRecognizerState.ended {
            if(self.center.x < UIScreen.main.bounds.size.width*0.5) {
                //dismiss view
                self.center = CGPoint(x: self.center.x + translation.x, y: self.center.y)
                sender.setTranslation(CGPoint.zero, in: self)
                cancelMedia()
                return
            } else {
                //back to original point
                if let keyWindow = UIApplication.shared.keyWindow {
                    self.center = CGPoint(x: keyWindow.frame.width - (youtubePlayerMinWidth / 2), y: keyWindow.frame.height - (youtubePlayerMinHeight / 2))
                }
                self.alpha = 1
            }
        } else if sender.state == UIGestureRecognizerState.changed {
            //fade view when moving away from original point
            if(self.center.x < self.currentDragPoint.x) {
                self.alpha -= 0.01
            } else {
                self.alpha += 0.01
            }
            self.currentDragPoint = self.center
            
            //set center of view to new dragged point
            self.center = CGPoint(x: self.center.x + translation.x, y: self.center.y)
            sender.setTranslation(CGPoint.zero, in: self)
        }
    }
    
    @objc func draggedMaxView(_ sender: UIPanGestureRecognizer){
        let translation = sender.translation(in: self)
        print("self origin x:\(self.center.x) y: \(self.center.y)")
        if sender.state == UIGestureRecognizerState.began {
            darkenView(false)
            moreOptionsView.dismiss()
        } else if sender.state == UIGestureRecognizerState.ended {
            if((self.center.y / 2) > UIScreen.main.bounds.size.height*0.3333) {
                //minimize view
                self.center = CGPoint(x: self.center.x, y: self.center.y + translation.y)
                sender.setTranslation(CGPoint.zero, in: self)
                minimize()
                return
            } else {
                //back to original point
                self.center = CGPoint(x: UIScreen.main.bounds.size.width*0.5,y: UIScreen.main.bounds.size.height*0.5)
                self.tableView.alpha = 1
                self.videoTitleLabel.alpha = 1
                self.bottomChangeVideoControls.alpha = 1
                self.bottomBorderView.alpha = 1
                self.shareView.alpha = 1
                self.moreOptionsView.alpha = 1
                self.backgroundColor = UIColor.white
            }
        } else if sender.state == UIGestureRecognizerState.changed {
            //fade view when moving away from original point
            if((self.center.y + translation.y) < (UIScreen.main.bounds.size.height / 2)) {
                return
            } else if((self.center.y / 2) > self.currentMaxDragPoint.y) {
                self.tableView.alpha -= 0.02
                self.videoTitleLabel.alpha -= 0.02
                self.bottomChangeVideoControls.alpha -= 0.02
                self.bottomBorderView.alpha -= 0.02
                self.shareView.alpha -= 0.02
                self.moreOptionsView.alpha -= 0.02
                self.backgroundColor = UIColor.white.withAlphaComponent(videoTitleLabel.alpha)
            } else {
                self.tableView.alpha += 0.02
                self.videoTitleLabel.alpha += 0.02
                self.bottomChangeVideoControls.alpha += 0.02
                self.bottomBorderView.alpha += 0.02
                self.shareView.alpha += 0.02
                self.moreOptionsView.alpha += 0.02
                self.backgroundColor = UIColor.white.withAlphaComponent(videoTitleLabel.alpha)
            }
            self.currentMaxDragPoint = CGPoint(x: self.center.x, y: (self.center.y / 2))
            
            //set center of view to new dragged point
            self.center = CGPoint(x: self.center.x, y: self.center.y + translation.y)
            sender.setTranslation(CGPoint.zero, in: self)
        }
    }
    
    func presentSharePostPopUp(_ post: BBPost!) {
        //track to Branch Metrics that the user initially started to share post
        Branch.getInstance().userCompletedAction(BNCShareInitiatedEvent)
        let postDebateText = post!.question ?? ""
        let postReactText = post?.comment ?? ""
        let postLinkID = post!.youtubeLink ?? ""
        let youtubeThumb = "http://img.youtube.com/vi/\(postLinkID)/mqdefault.jpg"
        var postMediaPath = post!.mediaPath ?? ""
        let creatorName = post!.creatorName ?? ""
        let postID = post!.postid ?? ""
        var postInfo = ""
        
        if post!.postType == BBPostType.Debate {
            //it's a debate post
            //get array of debate options
            let g = post!.options!.debateArrayInfo
            let debateTeamOne = g![0].teamName ?? ""
            let debateTeamTwo = g![1].teamName ?? ""
            if postLinkID != "" {
                //post has a youtube video
                postInfo = "\(postDebateText) \(debateTeamOne) \(BBConstants.Strings.or) \(debateTeamTwo)? \(BBConstants.Strings.checkOutVideo)"
                postMediaPath = youtubeThumb
            } else if postMediaPath != "" {
                //post has a photo
                postInfo = "\(postDebateText) \(debateTeamOne) \(BBConstants.Strings.or) \(debateTeamTwo)? \(BBConstants.Strings.checkOutPhoto)"
            }else {
                postInfo = "\(postDebateText) \(debateTeamOne) \(BBConstants.Strings.or) \(debateTeamTwo)?"
            }
            
            //set up Branch Metrics deep linking of post
            let branchUniversalObject: BranchUniversalObject = BranchUniversalObject(canonicalIdentifier: post.postid!)
            branchUniversalObject.title = "\(creatorName) \(BBConstants.Strings.branchDebateShareTitle)"
            branchUniversalObject.contentDescription = postInfo
            branchUniversalObject.imageUrl = postMediaPath
            branchUniversalObject.addMetadataKey("postID", value: postID)
            branchUniversalObject.addMetadataKey("postType", value: "debate")
            
            let linkProperties: BranchLinkProperties = BranchLinkProperties()
            linkProperties.feature = "sharing"
            linkProperties.channel = "facebook"
            
            branchUniversalObject.getShortUrl(with: linkProperties, andCallback: { (url, error) in
                if error == nil {
                    NSLog("got my Branch link to share: %@", url)
                    print("Post ID sent to Branch Metrics \(postID)")
                    //Get post Link (created by Branch Metrics) and allow user to share externally
                    //We can do this without Branch Metrics. Just add the following notes and remove Branch Metrics
                    /*
                     BBMainFeedVC.sharedInstance.postData = postInfo
                     let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                     appDelegate.logActionEventWithName("button_press", value: "share_app")
                     let activityVC = UIActivityViewController(activityItems: [BBShareString(), BBShareImage()], applicationActivities: nil)
                     //Excluded Activities Code
                     activityVC.excludedActivityTypes = [UIActivityTypeAirDrop, UIActivityTypeAddToReadingList]
                     */
                    
                    
                    //Google Event Analytics
                    //        let tracker = GAI.sharedInstance().defaultTracker
                    //        let builder = GAIDictionaryBuilder.createEventWithCategory("ui_action", action: "button_press", label: "share_post", value: nil)
                    //        tracker.send(builder.build() as [NSObject : AnyObject])
                    let contentToSend = "\(BBConstants.Strings.branchDebateShareMessage) \(url)"
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.logActionEventWithName("button_press", value: "share_app")
                    let activityVC = UIActivityViewController(activityItems: [contentToSend], applicationActivities: nil)
                    //Excluded Activities Code
                    activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
                    
                    //Do something when the user completes the share action
                    activityVC.completionWithItemsHandler = {activity, success, items, error in
                        if !success{
                            print("Shared cancelled")
                            return
                        }
                        if success{
                            print("Share Post successfull")
                            //Track to Branch Metrics that user successfully shared the post
                            Branch.getInstance().userCompletedAction(BNCShareCompletedEvent    )
                        }
                        
                        if activity == UIActivityType.postToTwitter {
                            print("Shared to Twitter")
                            postInfo = "twitter"
                        }
                        
                        if activity == UIActivityType.postToFacebook {
                            print("Shared to Facebook")
                            postInfo = "facebook"
                        }
                    }
                    //self.currentController.present(activityVC, animated: true, completion: nil)
                    self.darkenView(true)
                    self.shareView.linkToShare = url
                    self.shareView.post = post
                    self.shareView.show()
                }
            })
            
        } else {
            //it's a react post
            if postLinkID != "" {
                //post has a youtube video
                postInfo = "\(postReactText) \(BBConstants.Strings.checkOutVideo)"
                postMediaPath = youtubeThumb
            } else if postMediaPath != "" {
                //post has a photo
                postInfo = "\(postReactText) \(BBConstants.Strings.checkOutPhoto)!"
            }else {
                postInfo = "\(postReactText)"
            }
            
            //set up Branch Metrics deep linking of post
            let branchUniversalObject: BranchUniversalObject = BranchUniversalObject(canonicalIdentifier: post.postid!)
            branchUniversalObject.title = "\(creatorName) \(BBConstants.Strings.branchReactShareTitle)"
            branchUniversalObject.contentDescription = postInfo
            branchUniversalObject.imageUrl = postMediaPath
            branchUniversalObject.addMetadataKey("postID", value: postID)
            branchUniversalObject.addMetadataKey("postType", value: "react")
            
            let linkProperties: BranchLinkProperties = BranchLinkProperties()
            linkProperties.feature = "sharing"
            linkProperties.channel = "facebook"
            
            branchUniversalObject.getShortUrl(with: linkProperties, andCallback: { (url, error) in
                if error == nil {
                    NSLog("got my Branch link to share: %@", url)
                    print("Post ID sent to Branch Metrics \(postID)")
                    //Google Event Analytics
                    //        let tracker = GAI.sharedInstance().defaultTracker
                    //        let builder = GAIDictionaryBuilder.createEventWithCategory("ui_action", action: "button_press", label: "share_post", value: nil)
                    //        tracker.send(builder.build() as [NSObject : AnyObject])
                    let contentToSend = "\(BBConstants.Strings.branchReactShareMessage) \(url)"
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.logActionEventWithName("button_press", value: "share_app")
                    let activityVC = UIActivityViewController(activityItems: [contentToSend], applicationActivities: nil)
                    //Excluded Activities Code
                    activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
                    
                    //Do something when the user completes the share action
                    activityVC.completionWithItemsHandler = {activity, success, items, error in
                        if !success{
                            print("Shared cancelled")
                            return
                        }
                        if success{
                            print("Share Post successfull")
                            //Track to Branch Metrics that user successfully shared the post
                            Branch.getInstance().userCompletedAction(BNCShareCompletedEvent    )
                        }
                        
                        if activity == UIActivityType.postToTwitter {
                            print("Shared to Twitter")
                            postInfo = "twitter"
                        }
                        
                        if activity == UIActivityType.postToFacebook {
                            print("Shared to Facebook")
                            postInfo = "facebook"
                        }
                    }
                    //self.currentController.present(activityVC, animated: true, completion: nil)
                    self.darkenView(true)
                    self.shareView.linkToShare = url
                    self.shareView.post = post
                    self.shareView.show()
                }
            })
            
        }
    }
    
    func handleShareViewRowTapped(_ title: String, _ post: BBPost, _ linkToShare: String) {
        switch title {
        case "Copy Link":
            UIPasteboard.general.string = linkToShare
            break
        case "Facebook":
            if let vc = SLComposeViewController(forServiceType: SLServiceTypeFacebook) {
                minimize()
                vc.add(URL(string: linkToShare))
                currentController.present(vc, animated: true, completion: nil)
            }
            break
        case "Twitter":
            if let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter) {
                minimize()
                vc.add(URL(string: linkToShare))
                currentController.present(vc, animated: true, completion: nil)
            }
            break
        case "WhatsApp":
            let escapedString = linkToShare.addingPercentEncoding(withAllowedCharacters:CharacterSet.urlQueryAllowed)
            let url  = URL(string: "whatsapp://send?text=\(escapedString!)")
            
            if UIApplication.shared.canOpenURL(url! as URL) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                }
            }
            break
        case "Messages":
            minimize()
            let messageVC = MFMessageComposeViewController()
            messageVC.body = linkToShare
            messageVC.messageComposeDelegate = self
            currentController.present(messageVC, animated: false, completion: nil)
            break
        default:
            break
        }
        darkenView(false)
        shareView.dismiss()
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch (result) {
        case .cancelled:
            print("Message was cancelled")
            controller.dismiss(animated: true, completion: nil)
        case .failed:
            print("Message failed")
            controller.dismiss(animated: true, completion: nil)
        case .sent:
            print("Message was sent")
            controller.dismiss(animated: true, completion: nil)
        }
    }
}
