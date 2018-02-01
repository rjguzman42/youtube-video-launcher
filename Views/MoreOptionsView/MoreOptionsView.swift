//
//  MoreVideoOptionsView.swift
//  bitbat
//
//  Created by Roberto Guzman on 12/29/17.
//  Copyright © 2017 fortyTwoSports. All rights reserved.
//

import UIKit

class MoreOptionsView: BaseUIView, UITableViewDelegate, UITableViewDataSource {
    
    lazy var tableView: UITableView = {
        let tv = UITableView(frame: frame, style: .grouped)
        tv.frame = CGRect(x: 0, y: Int(self.bounds.minY), width: Int(UIScreen.main.bounds.size.width), height: 54)
        tv.backgroundColor = .white
        tv.bounces = false
        tv.isScrollEnabled = false
        tv.separatorStyle = .none
        tv.separatorColor = .clear
        tv.separatorInset = UIEdgeInsets(top: 0, left: 55, bottom: 0, right: 0)
        tv.allowsSelection = true
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()
    let moreOptionsTableCellId = "moreOptionsTableCellId"
    var rowHeight = 54.0
    var sections = [BBSettingItem.SettingCategory.administrative]
    var optionItems: [BBSettingItem.SettingCategory :[BBSettingItem]] = {
        let options: [BBSettingItem] = [BBSettingItem(category: .administrative, title: BBConstants.Strings.watchLater, imageName: "ic_watch_later", placeholder: nil, userInputText: nil), BBSettingItem(category: .administrative, title: BBConstants.Strings.sharePost, imageName: "ic_share", placeholder: nil, userInputText: nil), BBSettingItem(category: .administrative, title: BBConstants.Strings.cancel, imageName: "ic_cancel_two", placeholder: nil, userInputText: nil)]
        return groupBy(options) { $0.category}
    }()
    var post: BBPost?
    var tableCellTapped: ((_ row: Int, _ post: BBPost) -> Void)?
    
    override func setupSubViews() {
        self.isUserInteractionEnabled = true
        
        addSubview(tableView)
        addConstraints([NSLayoutConstraint(item: tableView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)])
        addConstraints([NSLayoutConstraint(item: tableView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0)])
        addConstraints([NSLayoutConstraint(item: tableView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)])
        let category = self.sections[0]
        let optionItemCount = self.optionItems[category]?.count ?? 0
        tableView.frame.size.height = (CGFloat(Int(self.rowHeight) * optionItemCount))
        let nib = UINib(nibName: "SearchUsersSectionHeader", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "SearchUsersSectionHeader")
        tableView.register(MoreOptionsTableCell.self, forCellReuseIdentifier: moreOptionsTableCellId)
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.estimatedRowHeight = CGFloat(54)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.scrollsToTop = true
        
        setInitialFrame()
    }
    
    func setInitialFrame() {
        frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: 0)
    }
    
    func show() {
        UIView.animate(withDuration: 0.3, animations: {
            let category = self.sections[0]
            let optionItemCount = self.optionItems[category]?.count ?? 0
            self.frame.size.height = CGFloat(-(Int(self.rowHeight) * optionItemCount))
            self.tableView.frame.size.height = CGFloat((Int(self.rowHeight) * optionItemCount))
            self.layoutIfNeeded()
        })
    }
    
    @objc func dismiss() {
        UIView.animate(withDuration: 0.3, animations: {
            self.setInitialFrame()
            self.layoutIfNeeded()
        })
    }

    // MARK: - Table View Source
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(rowHeight)
    }
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let category = sections[section]
        return optionItems[category]?.count ?? 0
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return moreOptionsTableCellForRowAtIndexPath(indexPath)
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableRowSelected(row: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func moreOptionsTableCellForRowAtIndexPath(_ indexPath: IndexPath) -> MoreOptionsTableCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: moreOptionsTableCellId) as! MoreOptionsTableCell
        let category = sections[indexPath.section]
        let setting: BBSettingItem = optionItems[category]![indexPath.row]
        cell.optionTitle.text = setting.title
        if let image = setting.imageName {
            cell.optionImageView.image = UIImage(named: image)
        }
        if(indexPath.row == ((optionItems[category]?.count)! - 1)) {
            cell.lineView.isHidden = false
        }
        return cell
    }
    
    func tableRowSelected(row: Int) {
        if tableCellTapped != nil {
            if let post = self.post {
                self.tableCellTapped!(row, post)
            }
        }
    }
    
    
    

}
