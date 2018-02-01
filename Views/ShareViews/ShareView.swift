//
//  ShareView.swift
//  bitbat
//
//  Created by Roberto Guzman on 1/3/18.
//  Copyright © 2018 fortyTwoSports. All rights reserved.
//

import UIKit

class ShareView: BaseUIView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Share Video Link"
        label.textColor = BBTheme.Colors.textPrimary.color
        label.font = BBTheme.Fonts.boldTitleFont.font
        label.textAlignment = .center
        label.contentMode = .center
        return label
    }()
    let cancelLabel: UILabel = {
        let label = UILabel()
        label.text = "Cancel"
        label.textColor = BBTheme.Colors.textPrimary.color
        label.font = BBTheme.Fonts.primaryTextFont.font
        label.textAlignment = .center
        label.contentMode = .center
        label.isUserInteractionEnabled = true
        return label
    }()
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 2
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.isPagingEnabled = false
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    let lineView: UIView = {
        let view = UIView()
        view.frame = CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 0.7)
        view.backgroundColor = UIColor.groupTableViewBackground
        return view
    }()
    var post = BBPost()
    var linkToShare = String()
    var itemPressed : ((_ title: String, _ post: BBPost, _ linkToShare: String) -> Void)?
    var cancelTapped : (() -> Void)?
    let shareItemCellId = "ShareItemCellId"
    var optionsToShare: [ShareItem] = [ShareItem(category: .external, title: "Copy Link", imagePath: "copyLinkIcon"), ShareItem(category: .external, title: "Facebook", imagePath: "facebookIcon"), ShareItem(category: .external, title: "Twitter", imagePath: "twitterIcon"), ShareItem(category: .external, title: "WhatsApp", imagePath: "whatsAppIcon"), ShareItem(category: .external, title: "Messages", imagePath: "messagesIcon")]

    override func setupSubViews() {
        
        setInitialFrame()
        
        addSubview(titleLabel)
        addConstraintsWithFormat(format: "H:[v0(150)]", views: titleLabel)
        addConstraintsWithFormat(format: "V:[v0(25)]", views: titleLabel)
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 10))
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        
        addSubview(collectionView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: collectionView)
        addConstraintsWithFormat(format: "V:[v0(120)]", views: collectionView)
        collectionView.register(ShareItemCell.self, forCellWithReuseIdentifier: shareItemCellId)
        addConstraint(NSLayoutConstraint(item: collectionView, attribute: .top, relatedBy: .equal, toItem: titleLabel, attribute: .bottom, multiplier: 1, constant: 10))
        
        addSubview(lineView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: lineView)
        addConstraintsWithFormat(format: "V:[v0(0.7)]", views: lineView)
        addConstraint(NSLayoutConstraint(item: lineView, attribute: .top, relatedBy: .equal, toItem: collectionView, attribute: .bottom, multiplier: 1, constant: 0))

        addSubview(cancelLabel)
        addConstraintsWithFormat(format: "H:[v0(150)]", views: cancelLabel)
        addConstraintsWithFormat(format: "V:[v0]", views: cancelLabel)
        addConstraint(NSLayoutConstraint(item: cancelLabel, attribute: .top, relatedBy: .equal, toItem: lineView, attribute: .bottom, multiplier: 1, constant: 20))
        addConstraint(NSLayoutConstraint(item: cancelLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.cancelLabelTapped(_ :)))
        cancelLabel.addGestureRecognizer(tapGesture)
    }
    
    func setInitialFrame() {
        frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: 0)
    }
    
    func show() {
        UIView.animate(withDuration: 0.3, animations: {
            let constantsHeight = CGFloat(60)
            let height = -(self.collectionView.frame.height + self.titleLabel.frame.height + self.cancelLabel.frame.height + constantsHeight)
            print("heightForView ----> \(height)")
            self.frame.size.height = height
            self.layoutIfNeeded()
        })
    }
    
    func dismiss() {
        UIView.animate(withDuration: 0.3, animations: {
            self.setInitialFrame()
            self.layoutIfNeeded()
            self.post = BBPost()
            self.linkToShare = String()
        })
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return optionsToShare.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let size = CGSize(width: 100, height: 100)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return getShareItemCellForIndexPath(indexPath)
    }
    
    func getShareItemCellForIndexPath(_ indexPath: IndexPath) -> ShareItemCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: shareItemCellId, for: indexPath) as! ShareItemCell
        let selectedItem = optionsToShare[indexPath.row]
        cell.titleLabel.text = selectedItem.title
        if let image = selectedItem.imagePath {
            cell.shareImageView.image = UIImage(named: image)
        }
        cell.itemPressed = {[weak self] title in
            if self != nil {
                if self?.itemPressed != nil {
                    if let post = self?.post {
                        if let linkToShare = self?.linkToShare {
                            self?.itemPressed!(title, post, linkToShare)
                        }
                    }
                }
                
            }
        }
        return cell
    }
    
    @objc func cancelLabelTapped(_ sender: Any) {
        if cancelTapped != nil {
            self.cancelTapped!()
        }
    }

}
